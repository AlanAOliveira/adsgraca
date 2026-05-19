/* ============================================================
   SCRIPT DE CRIAÇÃO - MODELO LÓGICO ABOS
   PADRÃO: tb_nome_abos
   Banco: Oracle
   ============================================================ */


/* ============================================================
   1. CRIAÇÃO DAS TABELAS
   ============================================================ */

CREATE TABLE tb_pessoa_abos (
    idpessoas      NUMBER,
    sexo           CHAR(1),
    administrador  CHAR(1),
    rg             VARCHAR2(10),
    dt_nasce       DATE,
    nome           VARCHAR2(30),
    cpf            VARCHAR2(11)
);

CREATE TABLE tb_doador_abos (
    id_doador              NUMBER,
    nome                   VARCHAR2(50),
    email                  VARCHAR2(50),
    telefone               VARCHAR2(15),
    cep                    VARCHAR2(8),
    rua                    VARCHAR2(30),
    numero                 VARCHAR2(6),
    fk_pessoa_idpessoas    NUMBER
);

CREATE TABLE tb_paciente_abos (
    id_paciente  NUMBER,
    nome         VARCHAR2(50),
    telefone     VARCHAR2(15),
    endereco     VARCHAR2(50),
    cpf          VARCHAR2(11)
);

CREATE TABLE tb_doacao_abos (
    id_doacao              NUMBER,
    tipo                   VARCHAR2(20),
    quantidade             NUMBER,
    data_recebimento       DATE,
    descricao              VARCHAR2(50),
    fk_pessoa_idpessoas    NUMBER
);

CREATE TABLE tb_tipo_equipamento_abos (
    id_tipo    NUMBER,
    descricao  VARCHAR2(50)
);

CREATE TABLE tb_tipo_alimento_abos (
    id_tipo    NUMBER,
    descricao  VARCHAR2(50)
);

CREATE TABLE tb_equipamento_abos (
    id_equipamento              NUMBER,
    nome                        VARCHAR2(50),
    status                      VARCHAR2(25),
    fk_doacao_id_doacao         NUMBER,
    fk_tipo_equipamento_id_tipo NUMBER
);

CREATE TABLE tb_alimento_abos (
    id_alimento              NUMBER,
    id_doacao                NUMBER,
    categoria                VARCHAR2(15),
    validade                 DATE,
    data_uso                 DATE,
    fk_doacao_id_doacao      NUMBER,
    fk_tipo_alimento_id_tipo NUMBER
);

CREATE TABLE tb_locacao_abos (
    id_locacao                  NUMBER,
    data_retirada               DATE,
    data_retorno_planejado      DATE,
    data_retorno_real           DATE,
    fk_equipamento_id_equipamento NUMBER,
    fk_pessoa_idpessoas         NUMBER,
    fk_paciente_id_paciente     NUMBER
);

CREATE TABLE tb_realiza_abos (
    fk_doador_id_doador    NUMBER,
    fk_doacao_id_doacao    NUMBER
);


/* ============================================================
   2. PRIMARY KEYS
   ============================================================ */

ALTER TABLE tb_pessoa_abos
ADD CONSTRAINT pk_tb_pessoa_abos
PRIMARY KEY (idpessoas);

ALTER TABLE tb_doador_abos
ADD CONSTRAINT pk_tb_doador_abos
PRIMARY KEY (id_doador);

ALTER TABLE tb_paciente_abos
ADD CONSTRAINT pk_tb_paciente_abos
PRIMARY KEY (id_paciente);

ALTER TABLE tb_doacao_abos
ADD CONSTRAINT pk_tb_doacao_abos
PRIMARY KEY (id_doacao);

ALTER TABLE tb_tipo_equipamento_abos
ADD CONSTRAINT pk_tb_tipo_equipamento_abos
PRIMARY KEY (id_tipo);

ALTER TABLE tb_tipo_alimento_abos
ADD CONSTRAINT pk_tb_tipo_alimento_abos
PRIMARY KEY (id_tipo);

ALTER TABLE tb_equipamento_abos
ADD CONSTRAINT pk_tb_equipamento_abos
PRIMARY KEY (id_equipamento);

ALTER TABLE tb_alimento_abos
ADD CONSTRAINT pk_tb_alimento_abos
PRIMARY KEY (id_alimento);

ALTER TABLE tb_locacao_abos
ADD CONSTRAINT pk_tb_locacao_abos
PRIMARY KEY (id_locacao);

ALTER TABLE tb_realiza_abos
ADD CONSTRAINT pk_tb_realiza_abos
PRIMARY KEY (fk_doador_id_doador, fk_doacao_id_doacao);


/* ============================================================
   3. FOREIGN KEYS
   ============================================================ */

ALTER TABLE tb_doador_abos
ADD CONSTRAINT fk_tb_doador_pessoa_abos
FOREIGN KEY (fk_pessoa_idpessoas)
REFERENCES tb_pessoa_abos (idpessoas);

ALTER TABLE tb_doacao_abos
ADD CONSTRAINT fk_tb_doacao_pessoa_abos
FOREIGN KEY (fk_pessoa_idpessoas)
REFERENCES tb_pessoa_abos (idpessoas);

ALTER TABLE tb_equipamento_abos
ADD CONSTRAINT fk_tb_equipamento_doacao_abos
FOREIGN KEY (fk_doacao_id_doacao)
REFERENCES tb_doacao_abos (id_doacao);

ALTER TABLE tb_equipamento_abos
ADD CONSTRAINT fk_tb_equipamento_tipo_abos
FOREIGN KEY (fk_tipo_equipamento_id_tipo)
REFERENCES tb_tipo_equipamento_abos (id_tipo);

ALTER TABLE tb_alimento_abos
ADD CONSTRAINT fk_tb_alimento_doacao_abos
FOREIGN KEY (fk_doacao_id_doacao)
REFERENCES tb_doacao_abos (id_doacao);

ALTER TABLE tb_alimento_abos
ADD CONSTRAINT fk_tb_alimento_tipo_abos
FOREIGN KEY (fk_tipo_alimento_id_tipo)
REFERENCES tb_tipo_alimento_abos (id_tipo);

ALTER TABLE tb_locacao_abos
ADD CONSTRAINT fk_tb_locacao_equipamento_abos
FOREIGN KEY (fk_equipamento_id_equipamento)
REFERENCES tb_equipamento_abos (id_equipamento);

ALTER TABLE tb_locacao_abos
ADD CONSTRAINT fk_tb_locacao_pessoa_abos
FOREIGN KEY (fk_pessoa_idpessoas)
REFERENCES tb_pessoa_abos (idpessoas);

ALTER TABLE tb_locacao_abos
ADD CONSTRAINT fk_tb_locacao_paciente_abos
FOREIGN KEY (fk_paciente_id_paciente)
REFERENCES tb_paciente_abos (id_paciente);

ALTER TABLE tb_realiza_abos
ADD CONSTRAINT fk_tb_realiza_doador_abos
FOREIGN KEY (fk_doador_id_doador)
REFERENCES tb_doador_abos (id_doador);

ALTER TABLE tb_realiza_abos
ADD CONSTRAINT fk_tb_realiza_doacao_abos
FOREIGN KEY (fk_doacao_id_doacao)
REFERENCES tb_doacao_abos (id_doacao);


/* ============================================================
   4. UNIQUE
   ============================================================ */

ALTER TABLE tb_pessoa_abos
ADD CONSTRAINT uk_tb_pessoa_cpf_abos
UNIQUE (cpf);

ALTER TABLE tb_doador_abos
ADD CONSTRAINT uk_tb_doador_email_abos
UNIQUE (email);

ALTER TABLE tb_paciente_abos
ADD CONSTRAINT uk_tb_paciente_cpf_abos
UNIQUE (cpf);


/* ============================================================
   5. CHECK CONSTRAINTS
   ============================================================ */

ALTER TABLE tb_pessoa_abos
ADD CONSTRAINT ck_tb_pessoa_sexo_abos
CHECK (sexo IN ('M', 'F', 'O'));

ALTER TABLE tb_pessoa_abos
ADD CONSTRAINT ck_tb_pessoa_admin_abos
CHECK (administrador IN ('S', 'N'));

ALTER TABLE tb_doacao_abos
ADD CONSTRAINT ck_tb_doacao_quantidade_abos
CHECK (quantidade > 0);

ALTER TABLE tb_equipamento_abos
ADD CONSTRAINT ck_tb_equipamento_status_abos
CHECK (status IN ('Disponivel', 'Em uso', 'Manutencao', 'Indisponivel'));


/* ============================================================
   6. NOT NULL
   ============================================================ */

ALTER TABLE tb_pessoa_abos MODIFY idpessoas NOT NULL;
ALTER TABLE tb_pessoa_abos MODIFY nome NOT NULL;
ALTER TABLE tb_pessoa_abos MODIFY cpf NOT NULL;

ALTER TABLE tb_doador_abos MODIFY id_doador NOT NULL;
ALTER TABLE tb_doador_abos MODIFY nome NOT NULL;
ALTER TABLE tb_doador_abos MODIFY fk_pessoa_idpessoas NOT NULL;

ALTER TABLE tb_paciente_abos MODIFY id_paciente NOT NULL;
ALTER TABLE tb_paciente_abos MODIFY nome NOT NULL;
ALTER TABLE tb_paciente_abos MODIFY cpf NOT NULL;

ALTER TABLE tb_doacao_abos MODIFY id_doacao NOT NULL;
ALTER TABLE tb_doacao_abos MODIFY tipo NOT NULL;
ALTER TABLE tb_doacao_abos MODIFY quantidade NOT NULL;
ALTER TABLE tb_doacao_abos MODIFY data_recebimento NOT NULL;
ALTER TABLE tb_doacao_abos MODIFY fk_pessoa_idpessoas NOT NULL;

ALTER TABLE tb_tipo_equipamento_abos MODIFY id_tipo NOT NULL;
ALTER TABLE tb_tipo_equipamento_abos MODIFY descricao NOT NULL;

ALTER TABLE tb_tipo_alimento_abos MODIFY id_tipo NOT NULL;
ALTER TABLE tb_tipo_alimento_abos MODIFY descricao NOT NULL;

ALTER TABLE tb_equipamento_abos MODIFY id_equipamento NOT NULL;
ALTER TABLE tb_equipamento_abos MODIFY nome NOT NULL;
ALTER TABLE tb_equipamento_abos MODIFY status NOT NULL;
ALTER TABLE tb_equipamento_abos MODIFY fk_doacao_id_doacao NOT NULL;
ALTER TABLE tb_equipamento_abos MODIFY fk_tipo_equipamento_id_tipo NOT NULL;

ALTER TABLE tb_alimento_abos MODIFY id_alimento NOT NULL;
ALTER TABLE tb_alimento_abos MODIFY fk_doacao_id_doacao NOT NULL;
ALTER TABLE tb_alimento_abos MODIFY fk_tipo_alimento_id_tipo NOT NULL;

ALTER TABLE tb_locacao_abos MODIFY id_locacao NOT NULL;
ALTER TABLE tb_locacao_abos MODIFY fk_equipamento_id_equipamento NOT NULL;
ALTER TABLE tb_locacao_abos MODIFY fk_pessoa_idpessoas NOT NULL;
ALTER TABLE tb_locacao_abos MODIFY fk_paciente_id_paciente NOT NULL;

ALTER TABLE tb_realiza_abos MODIFY fk_doador_id_doador NOT NULL;
ALTER TABLE tb_realiza_abos MODIFY fk_doacao_id_doacao NOT NULL;


/* ============================================================
   FIM DO SCRIPT
   ============================================================ */