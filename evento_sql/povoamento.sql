-- SEQUENCES
DROP SEQUENCE IF EXISTS seq_evento;
DROP SEQUENCE IF EXISTS seq_participante;
DROP SEQUENCE IF EXISTS seq_organizador;
DROP SEQUENCE IF EXISTS seq_sessao;
DROP SEQUENCE IF EXISTS seq_fornecedor;
DROP SEQUENCE IF EXISTS seq_certificado;

CREATE SEQUENCE seq_evento START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_participante START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_organizador START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sessao START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_fornecedor START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_certificado START WITH 1 INCREMENT BY 1;


-- ORGANIZADORES

INSERT INTO Organizador (id_organizador, nome_completo, cargo, departamento, supervisor)
VALUES (seq_organizador.NEXTVAL, 'Carlos Silva', 'Diretor', 'Eventos', NULL);

INSERT INTO Organizador (id_organizador, nome_completo, cargo, departamento, supervisor)
VALUES (seq_organizador.NEXTVAL, 'Mariana Souza', 'Coordenadora', 'Marketing', 1);

INSERT INTO Organizador (id_organizador, nome_completo, cargo, departamento, supervisor)
VALUES (seq_organizador.NEXTVAL, 'Rafael Lima', 'Analista', 'Eventos', 2);


-- ENDEREÇOS

INSERT INTO Endereco (CEP, Rua, Numero, Bairro, Estado, Cidade)
VALUES ('12345-678', 'Rua A', '100', 'Bairro Central', 'SP', 'São Paulo');

INSERT INTO Endereco (CEP, Rua, Numero, Bairro, Estado, Cidade)
VALUES ('87654-321', 'Avenida B', '200', 'Bairro Sul', 'RJ', 'Rio de Janeiro');


-- EVENTOS (garantir que os eventos sejam inseridos antes de Preco_Ingressos)

INSERT INTO Evento (
  id_evento, nome, categoria, data_inicio, data_fim, CEP,
  capacidade_maxima, organizador
) VALUES (
  seq_evento.NEXTVAL,
  'Tech Summit',
  'Congresso',
  TO_DATE('2025-06-01','YYYY-MM-DD'),
  TO_DATE('2025-06-02','YYYY-MM-DD'),
  '12345-678',
  300,
  1
);

INSERT INTO Evento (
  id_evento, nome, categoria, data_inicio, data_fim, CEP,
  capacidade_maxima, organizador
) VALUES (
  seq_evento.NEXTVAL,
  'Startup Workshop',
  'Workshop',
  TO_DATE('2025-07-10','YYYY-MM-DD'),
  TO_DATE('2025-07-12','YYYY-MM-DD'),
  '87654-321',
  150,
  2
);


-- PRECOS INGRESSOS (após inserção dos eventos)

INSERT INTO Preco_Ingressos (evento, tipo, preco)
VALUES (1, 'geral', 120.00);

INSERT INTO Preco_Ingressos (evento, tipo, preco)
VALUES (1, 'VIP', 300.00);

INSERT INTO Preco_Ingressos (evento, tipo, preco)
VALUES (1, 'estudante', 60.00);

INSERT INTO Preco_Ingressos (evento, tipo, preco)
VALUES (2, 'geral', 100.00);

INSERT INTO Preco_Ingressos (evento, tipo, preco)
VALUES (2, 'VIP', 250.00);

INSERT INTO Preco_Ingressos (evento, tipo, preco)
VALUES (2, 'estudante', 50.00);


-- NOMES_Participantes

INSERT INTO Nomes_Participantes (cpf, nome, sobrenome)
VALUES ('11111111100', 'Ana', 'Pereira');

INSERT INTO Nomes_Participantes (cpf, nome, sobrenome)
VALUES ('22222222200', 'Bruno', 'Oliveira');

INSERT INTO Nomes_Participantes (cpf, nome, sobrenome)
VALUES ('33333333300', 'Carla', 'Moraes');

INSERT INTO Nomes_Participantes (cpf, nome, sobrenome)
VALUES ('44444444400', 'Diego', 'Lima');


-- PARTICIPANTES

INSERT INTO Participante (id_participante, cpf, email)
VALUES (seq_participante.NEXTVAL, '11111111100', 'ana.pereira@email.com');

INSERT INTO Participante (id_participante, cpf, email)
VALUES (seq_participante.NEXTVAL, '22222222200', 'bruno.oliveira@email.com');

INSERT INTO Participante (id_participante, cpf, email)
VALUES (seq_participante.NEXTVAL, '33333333300', 'carla.moraes@email.com');

INSERT INTO Participante (id_participante, cpf, email)
VALUES (seq_participante.NEXTVAL, '44444444400', 'diego.lima@email.com');


-- TELEFONE_PARTICIPANTE

INSERT INTO Telefone_Participante (participante, telefone)
VALUES (1, '(11) 90000-0101');

INSERT INTO Telefone_Participante (participante, telefone)
VALUES (2, '(11) 90000-0102');

INSERT INTO Telefone_Participante (participante, telefone)
VALUES (3, '(21) 91111-0103');

INSERT INTO Telefone_Participante (participante, telefone)
VALUES (4, '(21) 91111-0104');


-- ESPECIALIZAÇÕES DE PARTICIPANTE

-- Palestrante
INSERT INTO Palestrante (id_participante, biografia, perfil_linkedin)
VALUES (
  1,
  'Engenheira de Software especializada em IA e palestrante internacional.',
  'linkedin.com/in/ana-pereira'
);

-- Aluno 
INSERT INTO Aluno (id_participante, matricula)
VALUES (2, 'M2025001');

-- Professor 
INSERT INTO Professor (id_participante, id_professor)
VALUES (3, 'PRF-001-2025');

-- Externo 
INSERT INTO Externo (id_participante, instituicao)
VALUES (4, 'Empresa Consultoria XYZ');


-- INGRESSO 

INSERT INTO Ingresso (id_evento, id_participante, tipo, ingresso_status, data_emissao)
VALUES (1, 1, 'geral', 'ativo', TO_DATE('2025-05-01','YYYY-MM-DD'));

INSERT INTO Ingresso (id_evento, id_participante, tipo, ingresso_status, data_emissao)
VALUES (1, 2, 'estudante', 'ativo', TO_DATE('2025-05-02','YYYY-MM-DD'));

INSERT INTO Ingresso (id_evento, id_participante, tipo, ingresso_status, data_emissao)
VALUES (2, 3, 'VIP', 'ativo', TO_DATE('2025-06-01','YYYY-MM-DD'));

INSERT INTO Ingresso (id_evento, id_participante, tipo, ingresso_status, data_emissao)
VALUES (2, 4, 'geral', 'ativo', TO_DATE('2025-06-02','YYYY-MM-DD'));


-- SESSAO 

INSERT INTO Sessao (
  id_sessao, titulo, descricao, tipo, duracao, capacidade,
  evento, data_inicio_sessao, data_fim_sessao
) VALUES (
  seq_sessao.NEXTVAL,
  'Abertura Tech Summit',
  'Palestra e abertura oficial do congresso',
  'Palestra',
  90,
  200,
  1,
  TO_DATE('2025-06-01 09:00','YYYY-MM-DD HH24:MI'),
  TO_DATE('2025-06-01 10:30','YYYY-MM-DD HH24:MI')
);

INSERT INTO Sessao (
  id_sessao, titulo, descricao, tipo, duracao, capacidade,
  evento, data_inicio_sessao, data_fim_sessao
) VALUES (
  seq_sessao.NEXTVAL,
  'Mentoria de Startups',
  'Workshop prático para desenvolvimento de ideias',
  'Workshop',
  120,
  50,
  2,
  TO_DATE('2025-07-10 14:00','YYYY-MM-DD HH24:MI'),
  TO_DATE('2025-07-10 16:00','YYYY-MM-DD HH24:MI')
);


-- MINISTRAR

INSERT INTO Ministrar (palestrante, sessao)
VALUES (1, 1);


-- PARTICIPA 

INSERT INTO Participa (participante, sessao, evento)
VALUES (2, 1, 1);

INSERT INTO Participa (participante, sessao, evento)
VALUES (3, 2, 2);


-- FORNECEDOR

INSERT INTO Fornecedor (id_fornecedor, nome, tipo_servico, telefone, email)
VALUES (seq_fornecedor.NEXTVAL, 'Tech Sound', 'Audio e Vídeo', '(11) 99999-0001', 'contato@techsound.com');

INSERT INTO Fornecedor (id_fornecedor, nome, tipo_servico, telefone, email)
VALUES (seq_fornecedor.NEXTVAL, 'Catering Gourmet', 'Buffet', '(11) 99999-0002', 'gourmet@catering.com');


-- CONTRATO

INSERT INTO Contrato (
  org_responsavel, evento, contratado,
  data_contrato, descricao_servico, valor, data_assinatura, contrato_status
) VALUES (
  1,
  1,
  1,
  TO_DATE('2025-04-01','YYYY-MM-DD'),
  'Serviço de som e iluminação para Tech Summit',
  20000,
  TO_DATE('2025-04-05','YYYY-MM-DD'),
  'Ativo'
);

INSERT INTO Contrato (
  org_responsavel, evento, contratado,
  data_contrato, descricao_servico, valor, data_assinatura, contrato_status
) VALUES (
  2,
  2,
  2,
  TO_DATE('2025-05-01','YYYY-MM-DD'),
  'Buffet completo para Workshop',
  8000,
  TO_DATE('2025-05-10','YYYY-MM-DD'),
  'Ativo'
);


-- CERTIFICADO

INSERT INTO Certificado (
  numero_certificado, data_emissao, carga_horaria, certificado_status,
  id_evento, id_participante
) VALUES (
  1001,
  TO_DATE('2025-06-03','YYYY-MM-DD'),
  8,
  'Emitido',
  1,
  2
);

INSERT INTO Certificado (
  numero_certificado, data_emissao, carga_horaria, certificado_status,
  id_evento, id_participante
) VALUES (
  1002,
  TO_DATE('2025-07-13','YYYY-MM-DD'),
  4,
  'Emitido',
  2,
  3
);
