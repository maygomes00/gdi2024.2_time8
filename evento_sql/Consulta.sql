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



--  