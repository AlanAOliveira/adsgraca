/* ============================================================
   SCRIPT DE INSERTS - MODELO LÓGICO ABOS
   PADRÃO: tb_nome_abos
   ============================================================ */


/* ============================================================
   1. INSERTS - TB_PESSOA_ABOS
   ============================================================ */

INSERT INTO tb_pessoa_abos VALUES
(1, 'M', 'S', '1234567890', TO_DATE('2005-03-15','YYYY-MM-DD'), 'Miguel Ribeiro', '11111111111');

INSERT INTO tb_pessoa_abos VALUES
(2, 'F', 'N', '2345678901', TO_DATE('1998-09-20','YYYY-MM-DD'), 'Ana Souza', '22222222222');

INSERT INTO tb_pessoa_abos VALUES
(3, 'M', 'N', '3456789012', TO_DATE('1987-01-10','YYYY-MM-DD'), 'Carlos Mendes', '33333333333');


/* ============================================================
   2. INSERTS - TB_DOADOR_ABOS
   ============================================================ */

INSERT INTO tb_doador_abos VALUES
(1, 'Mercado Bom Preco', 'contato@bompreco.com', '15999991111', '18000100', 'Rua Central', '120', 1);

INSERT INTO tb_doador_abos VALUES
(2, 'Farmacia Vida', 'doacoes@farmacia.com', '15988882222', '18000200', 'Av Saude', '450', 2);

INSERT INTO tb_doador_abos VALUES
(3, 'Joao Pereira', 'joao@gmail.com', '15977773333', '18000300', 'Rua Flores', '88', 3);


/* ============================================================
   3. INSERTS - TB_PACIENTE_ABOS
   ============================================================ */

INSERT INTO tb_paciente_abos VALUES
(1, 'Jose Santos', '15955551111', 'Rua Esperanca, 100', '44444444444');

INSERT INTO tb_paciente_abos VALUES
(2, 'Fernanda Lima', '15955552222', 'Av Brasil, 200', '55555555555');

INSERT INTO tb_paciente_abos VALUES
(3, 'Ricardo Alves', '15955553333', 'Rua da Paz, 300', '66666666666');


/* ============================================================
   4. INSERTS - TB_TIPO_EQUIPAMENTO_ABOS
   ============================================================ */

INSERT INTO tb_tipo_equipamento_abos VALUES
(1, 'Cadeira de Rodas');

INSERT INTO tb_tipo_equipamento_abos VALUES
(2, 'Muleta');

INSERT INTO tb_tipo_equipamento_abos VALUES
(3, 'Andador');


/* ============================================================
   5. INSERTS - TB_TIPO_ALIMENTO_ABOS
   ============================================================ */

INSERT INTO tb_tipo_alimento_abos VALUES
(1, 'Cesta Basica');

INSERT INTO tb_tipo_alimento_abos VALUES
(2, 'Nao Perecivel');

INSERT INTO tb_tipo_alimento_abos VALUES
(3, 'Higiene e Limpeza');


/* ============================================================
   6. INSERTS - TB_DOACAO_ABOS
   ============================================================ */

INSERT INTO tb_doacao_abos VALUES
(1, 'Alimento', 50, TO_DATE('2026-01-10','YYYY-MM-DD'), 'Doacao de cestas basicas', 1);

INSERT INTO tb_doacao_abos VALUES
(2, 'Equipamento', 3, TO_DATE('2026-02-15','YYYY-MM-DD'), 'Doacao de cadeiras', 2);

INSERT INTO tb_doacao_abos VALUES
(3, 'Alimento', 120, TO_DATE('2026-03-05','YYYY-MM-DD'), 'Alimentos nao pereciveis', 1);

INSERT INTO tb_doacao_abos VALUES
(4, 'Equipamento', 2, TO_DATE('2026-03-20','YYYY-MM-DD'), 'Doacao de muletas', 3);


/* ============================================================
   7. INSERTS - TB_REALIZA_ABOS
   Relação entre doador e doação
   ============================================================ */

INSERT INTO tb_realiza_abos VALUES (1, 1);
INSERT INTO tb_realiza_abos VALUES (2, 2);
INSERT INTO tb_realiza_abos VALUES (3, 3);
INSERT INTO tb_realiza_abos VALUES (1, 4);


/* ============================================================
   8. INSERTS - TB_ALIMENTO_ABOS
   ============================================================ */

INSERT INTO tb_alimento_abos VALUES
(1, 1, 'Basico', TO_DATE('2026-08-01','YYYY-MM-DD'), TO_DATE('2026-01-15','YYYY-MM-DD'), 1, 1);

INSERT INTO tb_alimento_abos VALUES
(2, 3, 'Graos', TO_DATE('2027-01-10','YYYY-MM-DD'), TO_DATE('2026-03-10','YYYY-MM-DD'), 3, 2);


/* ============================================================
   9. INSERTS - TB_EQUIPAMENTO_ABOS
   ============================================================ */

INSERT INTO tb_equipamento_abos VALUES
(1, 'Cadeira de Rodas Modelo A', 'Em uso', 2, 1);

INSERT INTO tb_equipamento_abos VALUES
(2, 'Cadeira de Rodas Modelo B', 'Disponivel', 2, 1);

INSERT INTO tb_equipamento_abos VALUES
(3, 'Muleta Ajustavel', 'Em uso', 4, 2);

INSERT INTO tb_equipamento_abos VALUES
(4, 'Andador Adulto', 'Disponivel', 4, 3);


/* ============================================================
   10. INSERTS - TB_LOCACAO_ABOS
   ============================================================ */

INSERT INTO tb_locacao_abos VALUES
(1, TO_DATE('2026-04-01','YYYY-MM-DD'), TO_DATE('2026-05-01','YYYY-MM-DD'), NULL, 1, 1, 1);

INSERT INTO tb_locacao_abos VALUES
(2, TO_DATE('2026-04-10','YYYY-MM-DD'), TO_DATE('2026-05-10','YYYY-MM-DD'), TO_DATE('2026-05-08','YYYY-MM-DD'), 3, 2, 2);


/* ============================================================
   11. CONFIRMAÇÃO DAS TRANSAÇÕES
   ============================================================ */

commit;

select * from tb_alimento_abos;
select * from tb_doador_abos;

/* ============================================================
   FIM DO SCRIPT DE INSERTS
   ============================================================ */