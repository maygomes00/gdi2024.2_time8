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
-- 




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
    SELECT i.id_evento, SUM(pi.preco) AS valor_arrecadado 
    FROM Ingresso i
    JOIN Preco_Ingressos pi ON i.id_evento = pi.evento AND i.tipo = pi.tipo
    WHERE i.ingresso_status != 'cancelado'
    GROUP BY i.id_evento
) a ON a.id_evento = e.id_evento
WHERE a.valor_arrecadado = (SELECT MAX(valor_arrecadado_max) FROM 
(
    SELECT i.id_evento, SUM(pi.preco) AS valor_arrecadado_max 
    FROM Ingresso i
    JOIN Preco_Ingressos pi ON i.id_evento = pi.evento AND i.tipo = pi.tipo
    WHERE i.ingresso_status != 'cancelado'
    GROUP BY i.id_evento
));