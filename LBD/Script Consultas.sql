/* ============================================================
   3. CONSULTAS SIGNIFICATIVAS PARA A APLICAÇÃO
   MODELO LÓGICO ABOS
   ============================================================ */


/* ============================================================
   a) Consulta usando junção de mais de 2 tabelas

   Objetivo:
   Listar as locações realizadas, exibindo o paciente,
   o equipamento emprestado e o usuário/pessoa responsável
   pelo registro da locação.
   ============================================================ */

SELECT
    l.id_locacao,
    p.nome AS nome_paciente,
    e.nome AS nome_equipamento,
    pe.nome AS usuario_responsavel,
    l.data_retirada,
    l.data_retorno_planejado,
    l.data_retorno_real
FROM tb_locacao_abos l
INNER JOIN tb_paciente_abos p
    ON l.fk_paciente_id_paciente = p.id_paciente
INNER JOIN tb_equipamento_abos e
    ON l.fk_equipamento_id_equipamento = e.id_equipamento
INNER JOIN tb_pessoa_abos pe
    ON l.fk_pessoa_idpessoas = pe.idpessoas;


/* ============================================================
   b) Consulta útil para a lógica de negócios usando totalização
      e uma função de data

   Objetivo:
   Exibir o total de doações recebidas por mês e ano,
   ajudando a ONG a acompanhar o volume de doações.
   ============================================================ */

SELECT
    EXTRACT(YEAR FROM data_recebimento) AS ano,
    EXTRACT(MONTH FROM data_recebimento) AS mes,
    COUNT(id_doacao) AS total_doacoes,
    SUM(quantidade) AS quantidade_total
FROM tb_doacao_abos
GROUP BY
    EXTRACT(YEAR FROM data_recebimento),
    EXTRACT(MONTH FROM data_recebimento)
ORDER BY
    ano,
    mes;


/* ============================================================
   c) Consulta usando junção externa LEFT JOIN

   Objetivo:
   Listar todos os doadores cadastrados, mesmo aqueles que
   ainda não possuem doações vinculadas.
   ============================================================ */

SELECT
    d.id_doador,
    d.nome AS nome_doador,
    d.email,
    doa.id_doacao,
    doa.tipo,
    doa.quantidade,
    doa.data_recebimento
FROM tb_doador_abos d
LEFT JOIN tb_realiza_abos r
    ON d.id_doador = r.fk_doador_id_doador
LEFT JOIN tb_doacao_abos doa
    ON r.fk_doacao_id_doacao = doa.id_doacao
ORDER BY
    d.nome;


/* ============================================================
   d) Consulta usando o operador UNION

   Objetivo:
   Criar uma lista única de contatos da aplicação,
   unindo os dados de doadores e pacientes.
   ============================================================ */

SELECT
    nome,
    telefone,
    'Doador' AS tipo_contato
FROM tb_doador_abos

UNION

SELECT
    nome,
    telefone,
    'Paciente' AS tipo_contato
FROM tb_paciente_abos;


/* ============================================================
   e) Consulta usando o operador MINUS

   Objetivo:
   Identificar equipamentos cadastrados que ainda nunca
   foram locados para nenhum paciente.
   ============================================================ */

SELECT
    id_equipamento,
    nome
FROM tb_equipamento_abos

MINUS

SELECT
    e.id_equipamento,
    e.nome
FROM tb_equipamento_abos e
INNER JOIN tb_locacao_abos l
    ON e.id_equipamento = l.fk_equipamento_id_equipamento;


/* ============================================================
   f) Consulta usando o operador INTERSECT

   Objetivo:
   Identificar CPFs que aparecem tanto no cadastro de Pessoa
   quanto no cadastro de Paciente.
   ============================================================ */

SELECT
    cpf
FROM tb_pessoa_abos

INTERSECT

SELECT
    cpf
FROM tb_paciente_abos;


/* ============================================================
   FIM DAS CONSULTAS
   ============================================================ */