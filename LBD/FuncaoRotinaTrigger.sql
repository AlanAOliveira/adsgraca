CREATE OR REPLACE FUNCTION fn_locacao_atrasada_abos(
    p_id_locacao IN NUMBER
) RETURN VARCHAR2
IS
    v_data_planejada  DATE;
    v_data_real       DATE;
BEGIN
    SELECT data_retorno_planejado, data_retorno_real
    INTO v_data_planejada, v_data_real
    FROM tb_locacao_abos
    WHERE id_locacao = p_id_locacao;

    -- Se ainda não devolveu, compara com hoje
    IF v_data_real IS NULL THEN
        IF SYSDATE > v_data_planejada THEN
            RETURN 'S';
        ELSE
            RETURN 'N';
        END IF;
    END IF;

    -- Se já devolveu, verifica se foi após o planejado
    IF v_data_real > v_data_planejada THEN
        RETURN 'S';
    ELSE
        RETURN 'N';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'LOCACAO NAO ENCONTRADA';
END;

CREATE OR REPLACE FUNCTION fn_alimento_vencido_abos(
    p_id_alimento IN NUMBER
) RETURN VARCHAR2
IS
    v_validade DATE;
BEGIN
    SELECT validade
    INTO v_validade
    FROM tb_alimento_abos
    WHERE id_alimento = p_id_alimento;

    IF v_validade IS NULL THEN
        RETURN 'SEM VALIDADE';
    END IF;

    IF SYSDATE > v_validade THEN
        RETURN 'S';
    ELSE
        RETURN 'N';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'ALIMENTO NAO ENCONTRADO';
END;

CREATE OR REPLACE TRIGGER trg_locacao_datas_abos
BEFORE INSERT OR UPDATE ON tb_locacao_abos
FOR EACH ROW
BEGIN
    -- Retorno planejado deve ser após retirada
    IF :NEW.data_retorno_planejado <= :NEW.data_retirada THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Data de retorno planejado deve ser posterior à data de retirada.');
    END IF;

    -- Retorno real (se informado) deve ser após retirada
    IF :NEW.data_retorno_real IS NOT NULL AND :NEW.data_retorno_real < :NEW.data_retirada THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Data de retorno real não pode ser anterior à data de retirada.');
    END IF;
END;

CREATE OR REPLACE TRIGGER trg_locacao_datas_abos
BEFORE INSERT OR UPDATE ON tb_locacao_abos
FOR EACH ROW
BEGIN
    -- Retorno planejado deve ser após retirada
    IF :NEW.data_retorno_planejado <= :NEW.data_retirada THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Data de retorno planejado deve ser posterior à data de retirada.');
    END IF;

    -- Retorno real (se informado) deve ser após retirada
    IF :NEW.data_retorno_real IS NOT NULL AND :NEW.data_retorno_real < :NEW.data_retirada THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Data de retorno real não pode ser anterior à data de retirada.');
    END IF;
END;


CREATE OR REPLACE TRIGGER trg_pessoa_cpf_abos
BEFORE INSERT OR UPDATE ON tb_pessoa_abos
FOR EACH ROW
BEGIN
    -- Verifica se CPF tem 11 dígitos numéricos
    IF NOT REGEXP_LIKE(:NEW.cpf, '^\d{11}$') THEN
        RAISE_APPLICATION_ERROR(-20005, 
            'CPF deve conter exatamente 11 dígitos numéricos.');
    END IF;

    -- Verifica CPFs inválidos (todos dígitos iguais)
    IF REGEXP_LIKE(:NEW.cpf, '^(\d)\1{10}$') THEN
        RAISE_APPLICATION_ERROR(-20006, 
            'CPF inválido: todos os dígitos são iguais.');
    END IF;
END;


CREATE TABLE tb_log_doacao_abos (
    id_log      NUMBER GENERATED ALWAYS AS IDENTITY,
    id_doacao   NUMBER,
    operacao    VARCHAR2(10),
    usuario     VARCHAR2(50),
    data_log    DATE,
    descricao   VARCHAR2(200)
);

CREATE OR REPLACE TRIGGER trg_log_doacao_abos
AFTER INSERT OR UPDATE OR DELETE ON tb_doacao_abos
FOR EACH ROW
DECLARE
    v_operacao VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_operacao := 'INSERT';
        INSERT INTO tb_log_doacao_abos (id_doacao, operacao, usuario, data_log, descricao)
        VALUES (:NEW.id_doacao, v_operacao, USER, SYSDATE, 
                'Nova doação: ' || :NEW.tipo || ' - Qtd: ' || :NEW.quantidade);

    ELSIF UPDATING THEN
        v_operacao := 'UPDATE';
        INSERT INTO tb_log_doacao_abos (id_doacao, operacao, usuario, data_log, descricao)
        VALUES (:NEW.id_doacao, v_operacao, USER, SYSDATE, 
                'Doação atualizada. Tipo: ' || :OLD.tipo || ' -> ' || :NEW.tipo);

    ELSIF DELETING THEN
        v_operacao := 'DELETE';
        INSERT INTO tb_log_doacao_abos (id_doacao, operacao, usuario, data_log, descricao)
        VALUES (:OLD.id_doacao, v_operacao, USER, SYSDATE, 
                'Doação removida: ' || :OLD.tipo);
    END IF;
END;

-- Teste: inserir pessoa com CPF inválido
INSERT INTO tb_pessoa_abos (nome, cpf, sexo, administrador)
VALUES ('João', '00000000000', 'M', 'N');
-- Erro: CPF inválido

-- Teste: locação com data inválida
INSERT INTO tb_locacao_abos (data_retirada, data_retorno_planejado, 
    fk_equipamento_id_equipamento, fk_pessoa_idpessoas, fk_paciente_id_paciente)
VALUES (SYSDATE, SYSDATE - 5, 1, 1, 1);
-- Erro: Data de retorno deve ser posterior

-- Teste: locar equipamento indisponível
-- (equipamento com status 'Em uso')
INSERT INTO tb_locacao_abos (data_retirada, data_retorno_planejado,
    fk_equipamento_id_equipamento, fk_pessoa_idpessoas, fk_paciente_id_paciente)
VALUES (SYSDATE, SYSDATE + 7, 1, 1, 1);
-- Erro: Equipamento não disponível
