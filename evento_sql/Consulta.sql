-- Custo total dos serviços contratados para cada evento ordenados de maior para menor
-- SQL: SELECT-FROM-WHERE, GROUP BY, ORDER BY
SELECT c.evento, SUM(valor) AS custo_evento
FROM Contrato c
WHERE contrato_status != 'Cancelado'
GROUP BY c.evento
ORDER BY custo_evento DESC;



-- Quantidade de participantes que tem ingresso para cada evento
-- SQL: LEFT JOIN
SELECT e.id_evento, COUNT(i.id_participante) AS numero_participantes
from Evento e
LEFT JOIN Ingresso i ON i.id_evento = e.id_evento AND ingresso_status != 'cancelado'
GROUP BY e.id_evento;



-- Função que informa quantidade de participantes de um tipo especifico em um evento
-- SQL: COUNT , INNER JOIN, IS NOT NULL
-- PL: CREATE FUNCTION, SELECT INTO
CREATE OR REPLACE FUNCTION ContaParticipanteTipo
(
    f_id_evento NUMBER, 
    f_participante_tipo VARCHAR2
)
RETURN INT
AS result_value NUMBER;
BEGIN
    SELECT COUNT(p.id_participante)
    INTO result_value
    FROM Ingresso i
    INNER JOIN Participante p ON i.id_participante = p.id_participante -- Filtra participantes que tem um ingresso.
-- Mantem id do Palestrante caso id do palestrante = id do participante, deixa nulo caso contrario. 
    LEFT JOIN Palestrante pal ON p.id_participante = pal.id_participante
-- Mantem id do Aluno caso id do Aluno = id do participante, deixa nulo caso contrario.
    LEFT JOIN Aluno alu ON p.id_participante = alu.id_participante
-- Mantem id do Professor caso id do Professor = id do participante, deixa nulo caso contrario.
    LEFT JOIN Professor prof ON p.id_participante = prof.id_participante
-- Mantem id do Externo caso id do Externo = id do participante, deixa nulo caso contrario.
    LEFT JOIN Externo ext ON p.id_participante = ext.id_participante
    WHERE i.id_evento = f_id_evento AND
    i.ingresso_status != 'cancelado' AND
-- De acordo com o tipo de participante especificado, faz com que ele só seja contado se valor não for nulo.  
    (
        (f_participante_tipo = 'Palestrante' AND pal.id_participante IS NOT NULL) OR
        (f_participante_tipo = 'Aluno' AND alu.id_participante IS NOT NULL) OR
        (f_participante_tipo = 'Professor' AND prof.id_participante IS NOT NULL) OR
        (f_participante_tipo = 'Externo' AND ext.id_participante IS NOT NULL) 
    );

    RETURN result_value;
END ContaParticipanteTipo;
/
-- Testando Função ContaParticipanteTipo: obtendo o numero de participantes em cada evento, separados por tipo.
SELECT e.id_evento, 
ContaParticipanteTipo(e.id_evento, 'Palestrante') AS Num_Palestrantes,
ContaParticipanteTipo(e.id_evento, 'Aluno') AS Num_Alunos,
ContaParticipanteTipo(e.id_evento, 'Professor') AS Num_Professores,
ContaParticipanteTipo(e.id_evento, 'Externo') AS Num_Externos
FROM Evento e
GROUP BY e.id_evento;



-- Adicionar Participante
-- SQL: INSERT INTO
-- PL: CREATE PROCEDURE, IF ELSIF, EXCEPTION WHEN
CREATE OR REPLACE PROCEDURE adicionar_participante 
(
    -- Dados gerais de Participantes
    p_cpf VARCHAR2,
    p_nome VARCHAR2,
    p_sobrenome VARCHAR2,
    p_email VARCHAR2,
    p_telefone VARCHAR2 DEFAULT NULL,
    p_tipo VARCHAR2,
    -- Dados de tipo Palestrante
    p_bibliografia VARCHAR2 DEFAULT NULL, 
    p_perfil_linkedin VARCHAR2 DEFAULT NULL,
    -- Dados de tipo Aluno
    p_matricula VARCHAR2 DEFAULT NULL,
    -- Dados de tipo Professor
    p_id_professor VARCHAR2 DEFAULT NULL,
    -- Dados de tipo Externo
    p_instituicao VARCHAR2 DEFAULT NULL
) 
-- Variavel que contem o id do participante
IS v_id_participante NUMBER := seq_participante.NEXTVAL;
BEGIN
    -- Guarda id participante na variavel
    SELECT seq_participante.NEXTVAL INTO v_id_participante FROM dual;

    -- Adiciona participante em Nomes_Participantes
    INSERT INTO Nomes_Participantes (cpf, nome, sobrenome)
    VALUES (p_cpf, p_nome, p_sobrenome);

    -- Adiciona participante em Participante
    INSERT INTO Participante (id_participante, cpf, email)
    VALUES (v_id_participante, p_cpf, p_email);

    -- Adiciona participante em Telefone_Participante
    INSERT INTO Telefone_Participante (participante, telefone)
    VALUES (v_id_participante, p_telefone);

    -- Adiciona participante se for Palestrante
    IF p_tipo = 'Palestrante' THEN
    INSERT INTO Palestrante (id_participante, biografia, perfil_linkedin)
    VALUES (v_id_participante, p_bibliografia, p_perfil_linkedin);
    -- Adiciona participante se for Aluno
    ELSIF p_tipo = 'Aluno' AND p_matricula IS NOT NULL THEN
    INSERT INTO Aluno (id_participante, matricula)
    VALUES (v_id_participante, p_matricula);
    ELSIF p_tipo = 'Professor' AND p_id_professor IS NOT NULL THEN
    INSERT INTO Professor (id_participante, id_professor)
    VALUES (v_id_participante, p_id_professor);
    ELSIF p_tipo = 'Externo' AND p_instituicao IS NOT NULL THEN
    INSERT INTO Externo (id_participante, instituicao)
    VALUES (v_id_participante, p_instituicao);
    ELSE 
        RAISE_APPLICATION_ERROR(-20004, 'Erro: Tipo de participante inválido pro algum motivo.');
    END IF;

    COMMIT;
EXCEPTION
    -- Erro em caso de Chave principal duplicada
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Erro: Participante já cadastrado.');

    -- Outros erros
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Erro desconhecido: ' || SQLERRM);

END adicionar_participante;
/
-- Adicionando novo participante do tipo Aluno
BEGIN
    adicionar_participante (
        '51551435105', 'Everton', 'Moura', 'EMoura@gmail.com', '(46) 91245-2037',
        'Aluno', NULL, NULL, 'M2187239', NULL, NULL
    );
END;
/
-- Exibe participantes
SELECT * FROM PARTICIPANTE;
SELECT * FROM NOMES_PARTICIPANTES;
SELECT * FROM PALESTRANTE;
SELECT * FROM ALUNO;
SELECT * FROM PROFESSOR;
SELECT * FROM EXTERNO;



-- Participantes que tem nome que começa com a letra "a"
-- SQL: LIKE
SELECT p.id_participante, p.cpf, np.nome, np.sobrenome, p.email
from Participante p
LEFT JOIN Nomes_Participantes np ON np.cpf = p.cpf
WHERE np.nome LIKE 'A%';



-- Mudar preço de ingressos
--




-- Obtem evento que arrecadou mais com venda de ingressos
-- SQL: SUBCONSULTA COM OPERADOR RELACIONAL, MAX
SELECT e.id_evento, e.nome, a.valor_arrecadado
FROM Evento e
JOIN (
-- Obtem soma do preço de todos os ingressos que não foram cancelados, separados por evento. 
    SELECT i.id_evento, SUM(pi.preco) AS valor_arrecadado 
    FROM Ingresso i
    JOIN Preco_Ingressos pi ON i.id_evento = pi.evento AND i.tipo = pi.tipo
    WHERE i.ingresso_status != 'cancelado'
    GROUP BY i.id_evento
) a ON a.id_evento = e.id_evento
-- Repete o processo para obter a soma dos ingressos, mas faz com que o evento que será exibido seja o que tem o valor maximo.
WHERE a.valor_arrecadado = (SELECT MAX(valor_arrecadado_max) FROM 
(
    SELECT i.id_evento, SUM(pi.preco) AS valor_arrecadado_max 
    FROM Ingresso i
    JOIN Preco_Ingressos pi ON i.id_evento = pi.evento AND i.tipo = pi.tipo
    WHERE i.ingresso_status != 'cancelado'
    GROUP BY i.id_evento
));



-- Obter evento que arrecadou menos com venda de ingressos
-- SQL: MIN
SELECT e.id_evento, e.nome, a.valor_arrecadado
FROM Evento e
JOIN (
-- Obtem soma do preço de todos os ingressos que não foram cancelados, separados por evento. 
    SELECT i.id_evento, SUM(pi.preco) AS valor_arrecadado 
    FROM Ingresso i
    JOIN Preco_Ingressos pi ON i.id_evento = pi.evento AND i.tipo = pi.tipo
    WHERE i.ingresso_status != 'cancelado'
    GROUP BY i.id_evento
) a ON a.id_evento = e.id_evento
-- Repete o processo para obter a soma dos ingressos, mas faz com que o evento que será exibido seja o que tem o valor minimo.
WHERE a.valor_arrecadado = (SELECT MIN(valor_arrecadado_max) FROM 
(
    SELECT i.id_evento, SUM(pi.preco) AS valor_arrecadado_max 
    FROM Ingresso i
    JOIN Preco_Ingressos pi ON i.id_evento = pi.evento AND i.tipo = pi.tipo
    WHERE i.ingresso_status != 'cancelado'
    GROUP BY i.id_evento
));



-- Alterar a tabela de contratos para adicionar um novo campo de data
-- SQL: ALTER TABLE
ALTER TABLE Contrato ADD data_termino DATE;



-- Criar um bloco anônimo para atualizar status de eventos passados
-- SQL/PL: BLOCO ANÔNIMO, UPDATE
BEGIN
    UPDATE Evento
    SET categoria = 'Finalizado'
    WHERE data_fim < SYSDATE;
END;
/

-- Atualizar status de ingresso para "usado" quando o evento já ocorreu
-- SQL: UPDATE, SUBCONSULTA COM IN
UPDATE Ingresso
SET ingresso_status = 'usado'
WHERE id_evento IN (SELECT id_evento FROM Evento WHERE data_fim < SYSDATE);



-- Consultar quais eventos já estão com a capacidade máxima 
-- SQL: BETWEEN
SELECT 
    e.id_evento, 
    e.nome, 
    e.capacidade_maxima, 
    NVL(COUNT(i.id_ingresso), 0) AS ingressos_vendidos,
    ROUND((COUNT(i.id_ingresso) / e.capacidade_maxima) * 100, 2) AS percentual_ocupacao
FROM Evento e
LEFT JOIN Ingresso i ON e.id_evento = i.evento
GROUP BY e.id_evento, e.nome, e.capacidade_maxima
HAVING ROUND((COUNT(i.id_ingresso) / e.capacidade_maxima) * 100, 2) 
        BETWEEN 50 AND 100
ORDER BY percentual_ocupacao DESC;



-- Trigger para evitar que contratos sejam excluídos se estiverem ativos
-- PL: CREATE OR REPLACE TRIGGER (LINHA)
CREATE OR REPLACE TRIGGER trg_prevent_delete_contrato
BEFORE DELETE ON Contrato
FOR EACH ROW
BEGIN
    IF :OLD.contrato_status = 'Ativo' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Não é permitido excluir contratos ativos.');
    END IF;
END;
/



-- Trigger para evitar que fornecedores sejam excluídos se tiverem com com contratos ativos
-- PL: CREATE OR REPLACE TRIGGER (COMANDO)
CREATE OR REPLACE TRIGGER trg_prevent_delete_fornecedor
BEFORE DELETE ON Fornecedor
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Contrato WHERE contratado = :OLD.id_fornecedor;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Não é permitido remover fornecedores com contratos ativos.');
    END IF;
END;
/



-- Preço médio dos ingressos por evento ordenados do maior para o menor
-- SQL: AVG, GROUP BY, ORDER BY
SELECT i.id_evento, AVG(pi.preco) AS preco_medio
FROM Ingresso i
JOIN Preco_Ingressos pi ON i.id_evento = pi.evento AND i.tipo = pi.tipo
WHERE i.ingresso_status != 'cancelado'
GROUP BY i.id_evento
ORDER BY preco_medio DESC;

-- Eventos que arrecadaram mais de 1000 com venda de ingressos
-- SQL: HAVING
SELECT i.id_evento, SUM(pi.preco) AS total_arrecadado
FROM Ingresso i
JOIN Preco_Ingressos pi ON i.id_evento = pi.evento AND i.tipo = pi.tipo
WHERE i.ingresso_status != 'cancelado'
GROUP BY i.id_evento
HAVING SUM(pi.preco) > 1000;

-- Participantes com ingressos para eventos com mais de 100 pessoas
SELECT p.id_participante, np.nome, np.sobrenome
FROM Participante p
JOIN Nomes_Participantes np ON p.cpf = np.cpf
WHERE p.id_participante IN (
    SELECT i.id_participante
    FROM Ingresso i
    JOIN Evento e ON i.id_evento = e.id_evento
    WHERE e.capacidade_maxima > 200 AND i.ingresso_status != 'cancelado'
);

-- Participantes que são palestrantes ou alunos
--SQL: UNION
SELECT p.id_participante, np.nome, np.sobrenome, 'Palestrante' AS tipo
FROM Participante p
JOIN Nomes_Participantes np ON p.cpf = np.cpf
JOIN Palestrante pal ON p.id_participante = pal.id_participante
UNION
SELECT p.id_participante, np.nome, np.sobrenome, 'Aluno' AS tipo
FROM Participante p
JOIN Nomes_Participantes np ON p.cpf = np.cpf
JOIN Aluno alu ON p.id_participante = alu.id_participante;

-- Eventos com pelo menos uma sessão de duração acima da média
--SQL: Subconsulta com ANY (a subconsulta calcula a duração média das sessões para cada evento.)
SELECT e.id_evento, e.nome
FROM Evento e
JOIN Sessao s ON e.id_evento = s.evento
WHERE s.duracao > ANY (
    SELECT AVG(duracao)
    FROM Sessao
    GROUP BY evento
)
GROUP BY e.id_evento, e.nome;

-- Eventos onde todas as sessões têm duração acima da média
--SQL: Subconsulta com ALL (a subconsulta calcula a duração média das sessões para cada evento.)
SELECT e.id_evento, e.nome
FROM Evento e
JOIN Sessao s ON e.id_evento = s.evento
WHERE s.duracao > ALL (
    SELECT AVG(duracao)
    FROM Sessao
    GROUP BY evento
)
GROUP BY e.id_evento, e.nome;

-- Criar um índice para otimizar buscas por status do ingresso
-- SQL: CREATE INDEX
CREATE INDEX idx_ingresso_status
ON Ingresso (ingresso_status);



-- Criar uma view para um relatório de eventos com a receita total
-- SQL: CREATE VIEW
CREATE VIEW vw_receita_eventos AS
SELECT e.id_evento, e.nome, SUM(p.preco) AS receita_total
FROM Evento e
JOIN Ingresso i ON e.id_evento = i.id_evento
JOIN Preco_Ingressos p ON i.id_evento = p.evento AND i.tipo = p.tipo
GROUP BY e.id_evento, e.nome;



-- Criar um procedimento para remover um participante completamente do sistema
-- SQL/PL: DELETE, CASE WHEN, %TYPE
CREATE OR REPLACE PROCEDURE remover_participante (
    p_id Participante.id_participante%TYPE
) AS
BEGIN
    -- Removendo todos os registros dependentes (tabelas relacionadas)
    DELETE FROM Telefone_Participante WHERE participante = p_id;
    DELETE FROM Externo WHERE id_participante = p_id;
    DELETE FROM Professor WHERE id_participante = p_id;
    DELETE FROM Aluno WHERE id_participante = p_id;
    DELETE FROM Ministrar WHERE palestrante = p_id;
    DELETE FROM Participa WHERE participante = p_id;
    DELETE FROM Ingresso WHERE id_participante = p_id;

    -- Por último, excluindo o participante
    DELETE FROM Participante WHERE id_participante = p_id;

    DBMS_OUTPUT.PUT_LINE('Participante removido com sucesso.');
END;
/



-- Criar um cursor para listar os participantes de um evento específico (id_evento = 1; Tech Summit)
-- PL: CURSOR (OPEN, FETCH, CLOSE), LOOP EXIT WHEN
DECLARE
    CURSOR cur_participantes IS
        SELECT p.nome, p.email FROM Participante p
        JOIN Ingresso i ON p.id_participante = i.id_participante
        WHERE i.id_evento = 1;
    v_nome Participante.email%TYPE;
    v_email Participante.email%TYPE;
BEGIN
    OPEN cur_participantes;
    LOOP
        FETCH cur_participantes INTO v_nome, v_email;
        EXIT WHEN cur_participantes%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_nome || ' - ' || v_email);
    END LOOP;
    CLOSE cur_participantes;
END;
/



-- Criar um package para gestão de contratos
-- PL: CREATE OR REPLACE PACKAGE, CREATE OR REPLACE PACKAGE BODY
CREATE OR REPLACE PACKAGE Contrato_Pkg AS
    PROCEDURE finalizar_contrato(p_id Contrato.org_responsavel%TYPE);
END Contrato_Pkg;
/
    
CREATE OR REPLACE PACKAGE BODY Contrato_Pkg AS
    PROCEDURE finalizar_contrato(p_id Contrato.org_responsavel%TYPE) IS
    BEGIN
        -- Atualizando o status do contrato
        UPDATE Contrato 
        SET contrato_status = 'Finalizado' 
        WHERE org_responsavel = p_id;

        -- Mensagem de confirmação
        DBMS_OUTPUT.PUT_LINE('Contrato finalizado com sucesso.');

        -- Garantir que a alteração seja persistida
        COMMIT;
    END finalizar_contrato;
END Contrato_Pkg;
/




-- Criar um loop para listar os eventos futuros
-- PL: WHILE LOOP, FOR IN LOOP, %ROWTYPE
DECLARE
    CURSOR cur_eventos IS SELECT * FROM Evento WHERE data_inicio > SYSDATE;
    v_evento cur_eventos%ROWTYPE;
BEGIN
    OPEN cur_eventos;
    WHILE TRUE LOOP
        FETCH cur_eventos INTO v_evento;
        EXIT WHEN cur_eventos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_evento.nome || ' - ' || v_evento.data_inicio);
    END LOOP;
    CLOSE cur_eventos;
END;
/



-- Criar uma estrutura RECORD e TABLE para armazenar dados temporários (Participante)
-- PL: USO DE RECORD, USO DE ESTRUTURA DE DADOS DO TIPO TABLE
DECLARE
    -- Definição de um RECORD com mais informações úteis
    TYPE ParticipanteRecord IS RECORD (
        id Participante.id_participante%TYPE,
        nome Nomes_Participantes.nome%TYPE,
        tipo VARCHAR2(20)
    );

    -- Definição de uma TABLE para armazenar múltiplos registros
    TYPE ParticipanteTable IS TABLE OF ParticipanteRecord INDEX BY PLS_INTEGER;
    v_participantes ParticipanteTable;

    -- Cursor para buscar os participantes e seus tipos
    CURSOR c_participantes IS
        SELECT p.id_participante, np.nome, 
               CASE 
                   WHEN e.id_participante IS NOT NULL THEN 'Externo'
                   WHEN pr.id_participante IS NOT NULL THEN 'Professor'
                   WHEN a.id_participante IS NOT NULL THEN 'Aluno'
                   ELSE 'Desconhecido'
               END AS tipo
        FROM Participante p
        JOIN Nomes_Participantes np ON p.id_participante = np.id_participante
        LEFT JOIN Externo e ON p.id_participante = e.id_participante
        LEFT JOIN Professor pr ON p.id_participante = pr.id_participante
        LEFT JOIN Aluno a ON p.id_participante = a.id_participante;

BEGIN
    -- Buscar dados para a estrutura TABLE
    FOR rec IN c_participantes LOOP
        v_participantes(v_participantes.COUNT + 1) := rec;
    END LOOP;

    -- Exibir os dados armazenados na estrutura TABLE
    FOR i IN 1 .. v_participantes.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_participantes(i).id ||
                             ' | Nome: ' || v_participantes(i).nome ||
                             ' | Tipo: ' || v_participantes(i).tipo);
    END LOOP;
END;
/




-- Conceder permissões para um usuário Organizador
-- SQL: GRANT / REVOKE
GRANT SELECT, INSERT, UPDATE, DELETE ON Certificado TO Organizador;
GRANT SELECT ON Evento TO Organizador;

-- Caso precise revogar permissões:
-- REVOKE SELECT, INSERT, UPDATE, DELETE ON Certificado TO Organizador;



