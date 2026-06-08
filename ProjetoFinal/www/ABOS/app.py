from flask import Flask, request, jsonify
from flask_cors import CORS
import oracledb
import os
from datetime import datetime, date
from dotenv import load_dotenv
from contextlib import contextmanager

load_dotenv('/var/www/ABOS/.env')

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    "user": os.getenv("ORACLE_USER"),
    "password": os.getenv("ORACLE_PASSWORD"),
    "dsn": os.getenv("ORACLE_DSN")
}


# ============================================
# DB Helpers
# ============================================
@contextmanager
def get_db():
    conn = None
    try:
        conn = oracledb.connect(**DB_CONFIG)
        yield conn
    except oracledb.Error as e:
        if conn:
            conn.rollback()
        raise e
    finally:
        if conn:
            conn.close()


def rows_to_dict(cursor):
    """Convert cursor results to list of dicts, handling dates"""
    columns = [col[0].lower() for col in cursor.description]
    results = []
    for row in cursor.fetchall():
        d = {}
        for i, val in enumerate(row):
            if isinstance(val, (datetime, date)):
                d[columns[i]] = val.isoformat()
            else:
                d[columns[i]] = val
        results.append(d)
    return results


def next_id(cursor, table, id_column):
    """Get next ID by querying MAX(id) + 1"""
    cursor.execute(f"SELECT NVL(MAX({id_column}), 0) + 1 FROM {table}")
    return cursor.fetchone()[0]


def parse_date(date_str):
    """Parse YYYY-MM-DD string to date, return None if empty"""
    if not date_str:
        return None
    return datetime.strptime(date_str, '%Y-%m-%d').date()


# ============================================
# Root & Health Check
# ============================================
@app.route('/')
def index():
    return jsonify({"app": "ABOS", "status": "running"})


@app.route('/db/test', methods=['GET'])
def test_db():
    """Test Oracle DB connection"""
    try:
        with get_db() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT SYSDATE FROM DUAL")
            return jsonify({
                "status": "ok",
                "message": "Connected to Oracle DB",
                "server_time": str(cursor.fetchone()[0])
            })
    except oracledb.Error as e:
        return jsonify({"status": "error", "error": str(e)}), 500


# ============================================
# DOAÇÕES
# ============================================

@app.route('/doacoes', methods=['GET'])
def listar_doacoes():
    """List all donations with donor info"""
    try:
        with get_db() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT 
                    d.id_doacao, 
                    d.tipo, 
                    d.quantidade, 
                    d.data_recebimento, 
                    d.descricao, 
                    d.fk_pessoa_idpessoas,
                    p.nome AS nome_pessoa,
                    doador.id_doador,
                    doador.nome AS nome_doador,
                    doador.email AS email_doador
                FROM tb_doacao_abos d
                LEFT JOIN tb_pessoa_abos p 
                    ON d.fk_pessoa_idpessoas = p.idpessoas
                LEFT JOIN tb_realiza_abos r 
                    ON d.id_doacao = r.fk_doacao_id_doacao
                LEFT JOIN tb_doador_abos doador 
                    ON r.fk_doador_id_doador = doador.id_doador
                ORDER BY d.data_recebimento DESC
            """)
            return jsonify(rows_to_dict(cursor))
    except oracledb.Error as e:
        return jsonify({"error": str(e)}), 500

@app.route('/doacoes/<int:doacao_id>', methods=['GET'])
def get_doacao(doacao_id):
    """Get a single donation by ID"""
    try:
        with get_db() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT d.id_doacao, d.tipo, d.quantidade, d.data_recebimento, 
                       d.descricao, d.fk_pessoa_idpessoas, 
                       p.nome AS nome_pessoa
                FROM tb_doacao_abos d
                LEFT JOIN tb_pessoa_abos p ON d.fk_pessoa_idpessoas = p.idpessoas
                WHERE d.id_doacao = :id
            """, {"id": doacao_id})
            
            result = rows_to_dict(cursor)
            if not result:
                return jsonify({"error": "Doação não encontrada"}), 404
            return jsonify(result[0])
    except oracledb.Error as e:
        return jsonify({"error": str(e)}), 500



@app.route('/doacoes', methods=['POST'])
def criar_doacao():
    """Create a new donation"""
    data = request.get_json()
    
    if not data:
        return jsonify({"error": "Envie JSON"}), 400
    
    print(f"📥 Received: {data}", flush=True)
    
    required = ['tipo', 'quantidade', 'fk_pessoa_idpessoas']
    missing = [f for f in required if not data.get(f)]
    if missing:
        return jsonify({"error": f"Campos obrigatórios: {missing}"}), 400
    
    try:
        quantidade = int(data['quantidade'])
        if quantidade <= 0:
            return jsonify({"error": "Quantidade deve ser maior que zero"}), 400
    except (ValueError, TypeError):
        return jsonify({"error": "Quantidade deve ser um número"}), 400
    
    try:
        with get_db() as conn:
            cursor = conn.cursor()
            
            # Ensure pessoa exists
            cursor.execute("""
                SELECT COUNT(*) FROM tb_pessoa_abos WHERE idpessoas = :p_id
            """, {"p_id": data['fk_pessoa_idpessoas']})
            
            if cursor.fetchone()[0] == 0:
                cursor.execute("""
                    INSERT INTO tb_pessoa_abos 
                    (idpessoas, nome, cpf, sexo, administrador)
                    VALUES (:p_id, 'Admin Sistema', '00000000000', 'O', 'S')
                """, {"p_id": data['fk_pessoa_idpessoas']})
                print(f"✅ Created pessoa {data['fk_pessoa_idpessoas']}", flush=True)
            
            # Get next donation ID
            cursor.execute("SELECT NVL(MAX(id_doacao), 0) + 1 FROM tb_doacao_abos")
            new_id = cursor.fetchone()[0]
            
            # Parse date
            data_receb = datetime.now().date()
            if data.get('data_recebimento'):
                try:
                    data_receb = datetime.strptime(data['data_recebimento'], '%Y-%m-%d').date()
                except ValueError:
                    pass
            
            descricao = (data.get('descricao') or '')[:50]
            tipo = data['tipo'][:20]
            
            # ⚠️ RENAMED bind variables to avoid Oracle reserved words
            cursor.execute("""
                INSERT INTO tb_doacao_abos 
                (id_doacao, tipo, quantidade, data_recebimento, descricao, fk_pessoa_idpessoas)
                VALUES (:p_id, :p_tipo, :p_qtd, :p_data, :p_desc, :p_fk_pessoa)
            """, {
                "p_id": new_id,
                "p_tipo": tipo,
                "p_qtd": quantidade,
                "p_data": data_receb,
                "p_desc": descricao,
                "p_fk_pessoa": data['fk_pessoa_idpessoas']
            })
            
            # Optional: link donor
            doador_id = data.get('fk_doador_id_doador')
            if doador_id:
                try:
                    cursor.execute("""
                        SELECT COUNT(*) FROM tb_doador_abos WHERE id_doador = :p_id
                    """, {"p_id": doador_id})
                    
                    if cursor.fetchone()[0] > 0:
                        cursor.execute("""
                            INSERT INTO tb_realiza_abos (fk_doador_id_doador, fk_doacao_id_doacao)
                            VALUES (:p_doador, :p_doacao)
                        """, {"p_doador": doador_id, "p_doacao": new_id})
                        print(f"✅ Linked donor {doador_id}", flush=True)
                except oracledb.Error as e:
                    print(f"⚠️ Could not link donor: {e}", flush=True)
            
            conn.commit()
            print(f"✅ Donation {new_id} created", flush=True)
            
            return jsonify({
                "status": "ok",
                "message": "Doação cadastrada com sucesso",
                "id": new_id
            }), 201
            
    except oracledb.Error as e:
        error_obj, = e.args
        print(f"❌ Oracle Error: {error_obj.message}", flush=True)
        return jsonify({
            "error": str(error_obj.message),
            "code": error_obj.code if hasattr(error_obj, 'code') else None
        }), 500
    except Exception as e:
        print(f"❌ Unexpected error: {e}", flush=True)
        return jsonify({"error": str(e)}), 500



@app.route('/doacoes/<int:doacao_id>', methods=['PUT'])
def atualizar_doacao(doacao_id):
    """Update an existing donation"""
    data = request.get_json()
    
    if not data:
        return jsonify({"error": "Envie JSON"}), 400
    
    try:
        with get_db() as conn:
            cursor = conn.cursor()
            
            fields = []
            params = {"id": doacao_id}
            
            if 'tipo' in data:
                fields.append("tipo = :tipo")
                params['tipo'] = data['tipo']
            if 'quantidade' in data:
                fields.append("quantidade = :qtd")
                params['qtd'] = data['quantidade']
            if 'descricao' in data:
                fields.append("descricao = :desc")
                params['desc'] = data['descricao']
            if 'data_recebimento' in data:
                fields.append("data_recebimento = :data")
                params['data'] = parse_date(data['data_recebimento'])
            
            if not fields:
                return jsonify({"error": "Nenhum campo para atualizar"}), 400
            
            sql = f"UPDATE tb_doacao_abos SET {', '.join(fields)} WHERE id_doacao = :id"
            cursor.execute(sql, params)
            
            if cursor.rowcount == 0:
                return jsonify({"error": "Doação não encontrada"}), 404
            
            conn.commit()
            return jsonify({"status": "ok", "updated_id": doacao_id})
    except oracledb.Error as e:
        return jsonify({"error": str(e)}), 500


@app.route('/doacoes/<int:doacao_id>', methods=['DELETE'])
def deletar_doacao(doacao_id):
    """Delete a donation"""
    try:
        with get_db() as conn:
            cursor = conn.cursor()
            
            # Delete dependent records first to avoid FK violations
            cursor.execute("DELETE FROM tb_realiza_abos WHERE fk_doacao_id_doacao = :id", {"id": doacao_id})
            cursor.execute("DELETE FROM tb_alimento_abos WHERE fk_doacao_id_doacao = :id", {"id": doacao_id})
            cursor.execute("DELETE FROM tb_equipamento_abos WHERE fk_doacao_id_doacao = :id", {"id": doacao_id})
            
            # Delete the donation
            cursor.execute("DELETE FROM tb_doacao_abos WHERE id_doacao = :id", {"id": doacao_id})
            
            if cursor.rowcount == 0:
                return jsonify({"error": "Doação não encontrada"}), 404
            
            conn.commit()
            return jsonify({"status": "ok", "deleted_id": doacao_id})
    except oracledb.Error as e:
        return jsonify({"error": str(e)}), 500

#==================================================
#DOADORES
#==================================================


@app.route('/doadores', methods=['GET'])
def listar_doadores():
    """List all donors"""
    try:
        with get_db() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT id_doador, nome, email, telefone, fk_pessoa_idpessoas
                FROM tb_doador_abos
                ORDER BY nome
            """)
            return jsonify(rows_to_dict(cursor))
    except oracledb.Error as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
