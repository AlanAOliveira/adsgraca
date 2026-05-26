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
    -- trocar se a devolução esta atrasada com base na data real ou na data do sistema
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


CREATE OR REPLACE PROCEDURE prc_registrar_doacao_abos (
    p_id_doacao           IN NUMBER,
    p_tipo                IN VARCHAR2,
    p_quantidade          IN NUMBER,
    p_data_recebimento    IN DATE,
    p_descricao           IN VARCHAR2,
    p_fk_pessoa_idpessoas IN NUMBER,
    p_id_doador           IN NUMBER
) IS
    v_count NUMBER;
BEGIN
    IF p_quantidade <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Quantidade deve ser maior que zero.');
    END IF;

    -- Valida doador
    SELECT COUNT(*) INTO v_count
    FROM tb_doador_abos
    WHERE id_doador = p_id_doador;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Doador não encontrado.');
    END IF;

    -- Insere doação
    INSERT INTO tb_doacao_abos (
        id_doacao, tipo, quantidade, data_recebimento, descricao, fk_pessoa_idpessoas
    ) VALUES (
        p_id_doacao, p_tipo, p_quantidade, p_data_recebimento, p_descricao, p_fk_pessoa_idpessoas
    );

    -- Relaciona doador à doação
    INSERT INTO tb_realiza_abos (fk_doador_id_doador, fk_doacao_id_doacao)
    VALUES (p_id_doador, p_id_doacao);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Doação registrada com sucesso! ID: ' || p_id_doacao);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao registrar doação: ' || SQLERRM);
        ROLLBACK;
END;

-- Teste: registrar doação válida
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TESTE 1: Doação válida ---');
    prc_registrar_doacao_abos(
        p_id_doacao           => 1001,
        p_tipo                => 'Alimento',
        p_quantidade          => 50,
        p_data_recebimento    => SYSDATE,
        p_descricao           => 'Cestas básicas',
        p_fk_pessoa_idpessoas => 2,
        p_id_doador           => 100
    );
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
