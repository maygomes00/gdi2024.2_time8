-- DROP REVISAR ESSA PARTE:
-- Apaga tabelas existentes (para criar elas do zero)
DROP TABLE IF EXISTS Evento CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Endereco CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Participante CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Telefone_Participante;
DROP TABLE IF EXISTS Nomes_Participantes CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Palestrante CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Aluno;
DROP TABLE IF EXISTS Professor;
DROP TABLE IF EXISTS Externo;
DROP TABLE IF EXISTS Ingresso CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Preco_Ingressos CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Organizador CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Sessao CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Ministrar;
DROP TABLE IF EXISTS Participa;
DROP TABLE IF EXISTS Fornecedor CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Contrato;
DROP TABLE IF EXISTS Certificado;

-- ORGANIZADOR
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_organizador AS OBJECT(
    id_organizador NUMBER,
    nome_completo VARCHAR2(100),
    cargo VARCHAR2(50),
    departamento VARCHAR2(50),
    supervisor NUMBER,
    supervisor REF tp_organizador
);

-- CREATE TABLE:
CREATE OR REPLACE TABLE Organizador OF tp_organizador (
    CONSTRAINT PRIMARY KEY (id_organizador),
    CONSTRAINT fk_supervisor FOREIGN KEY (supervisor)
        REFERENCES Organizador(id_organizador) ON DELETE SET NULL,
    
    -- Definir os atributos obrigatórios
    nome_completo NOT NULL,
    cargo NOT NULL,
    departamento NOT NULL
);


-- ENDEREÇO
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_endereco AS OBJECT(
    CEP VARCHAR2(10),
    Rua VARCHAR2(50),
    Numero VARCHAR2(50),
    Bairro VARCHAR2(50),
    Estado VARCHAR2(50),
    Cidade VARCHAR2(50)
);
-- CREATE TABLE:
CREATE OR REPLACE TABLE Endereco of tp_endereco(
    CEP PRIMARY KEY,

    -- Definir os atributos obrigatórios
    Rua NOT NULL,
    Numero NOT NULL,
    Bairro NOT NULL,
    Estado NOT NULL,
    Cidade NOT NULL
);


-- EVENTO
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_evento AS OBJECT(
    id_evento NUMBER,
    nome VARCHAR2(100),
    categoria VARCHAR2(50),
    data_inicio DATE,
    data_fim DATE,
    CEP REF tp_endereco,
    capacidade_maxima NUMBER,
    organizador REF tp_organizador,
    CONSTRUCTOR FUNCTION tp_evento (id NUMBER, nome VARCHAR, categoria VARCHAR, inicio DATE, fim DATE, cep VARCHAR, capacidade NUMBER, organizador NUMBER) RETURN SELF AS RESULT
);
-- CREATE TYPE BODY
/
CREATE OR REPLACE TYPE BODY tp_evento AS
    CONSTRUCTOR FUNCTION id NUMBER, nome VARCHAR, categoria VARCHAR, inicio DATE, fim DATE, cep VARCHAR, capacidade NUMBER, organizador NUMBER) RETURN SELF AS RESULT IS
    BEGIN
        SELF.id_evento := id;
        SELF.nome := nome;
        SELF.categoria := categoria;
        SELF.data_inicio := inicio;
        SELF.data_fim := fim;
        SELF.CEP := cep;
        SELF.capacidade_maxima := capacidade;
        SELF.organizador := organizador;
    END;
    MEMBER FUNCTION getDuracao RETURN NUMBER IS
    BEGIN
        RETURN data_fim - data_inicio;
    END;
END;
/
-- ALTER TYPE
ALTER TYPE tp_evento ADD MEMBER FUNCTION getDuracao RETURN NUMBER;
-- CREATE TABLE
CREATE OR REPLACE TABLE Evento OF tp_evento (
    CONSTRAINT PRIMARY KEY(id_evento),
    CONSTRAINT fk_evento_endereco FOREIGN KEY (CEP)
        REFERENCES Endereco(CEP),
    CONSTRAINT fk_evento_organizador FOREIGN KEY (organizador)
        REFERENCES Organizador(id_organizador),
    
    -- Restrições de integridade
    CONSTRAINT ck_evento_categoria CHECK (categoria IN ('Seminário', 'Workshop', 'Congresso', 'Feira')),
    CONSTRAINT ck_evento_datas CHECK (data_fim >= data_inicio),
    CONSTRAINT ck_evento_capacidade CHECK (capacidade_maxima > 0)

    -- Definir os atributos obrigatórios
    nome NOT NULL,
    data_inicio NOT NULL,
    data_fim NOT NULL,
    CEP NOT NULL,
    organizador NOT NULL
);


-- NOME_PARTICIPANTE
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_nome_participante AS OBJECT (
    cpf VARCHAR2(11),
    nome VARCHAR2(50),
    sobrenome VARCHAR2(50)
)
-- CREATE TABLE:
CREATE OR REPLACE TABLE Nomes_Participantes OF tp_nome_participante(
    CONSTRAINT PRIMARY KEY(cpf)
);


-- PARTICIPANTE
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_participante AS OBJECT(
    id_participante NUMBER,
    cpf VARCHAR2(11),
    email VARCHAR2(100),
    nomes REF tp_nome_participante
) NOT FINAL;
-- CREATE TABLE:
CREATE OR REPLACE TABLE Participante OF tp_participante (
    CONSTRAINT PRIMARY KEY(id_participante),
    CONSTRAINT fk_nomes_participante FOREIGN KEY (cpf)
        REFERENCES Nomes_Participantes(cpf) ON DELET SET NULL,
    
    -- Definir os atributos obrigatórios
    cpf UNIQUE NOT NULL,
    email NOT NULL 
);


-- TELEFONE_PARTICIPANTE
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_telefone_participante AS OBJECT(
    participante NUMBER,
    telefone VARCHAR2(15),
    telefone_participante REF tp_participante
);
-- CREATE TABLE:
CREATE OR REPLACE TABLE Telefone_Participante OF tp_telefone_participante(
    CONSTRAINT PRIMATY KEY (participante, telefone),
    CONSTRAINT fk_telefone_participante FOREIGN KEY (participante)
        REFERENCES Participante(is_participante)
);


-- PALESTRANTE
-- CREATE SUBTYPE:
CREATE OR REPLACE TYPE tp_palestrante UNDER tp_palestrante(
    biografia VARCHAR2(500),
    perfil_linkedin VARCHAR2(200)
);
-- CREATE TABLE (SUBTYPE):
CREATE OR REPLACE TABLE Palestrante OF tp_palestrante(
    CONSTRAINT PRIMARY KEY (id_participante),
    CONSTRAINT fk_palestrante_participante PRIMARY KEY (id_participante)
        REFERENCES Participante (id_participante)
);


-- ALUNO
-- CREATE SUBTYPE:
CREATE OR REPLACE TYPE tp_aluno UNDER tp_participante (
    matricula VARCHAR2(20)
);
-- CREATE TABLE (SUBTYPE):
CREATE OR REPLACE TABLE Aluno OF tp_aluno(
    CONSTRAINT PRIMARY KEY (id_participante),
    CONSTRAINT fk_aluno_participante FOREIGN KEY (id_participante)
        REFERENCES Participante(id_participante)

    -- Definir os atributos obrigatórios
    matricula UNIQUE NOT NULL
);


-- PROFESSOR
-- CREATE SUBTYPE:
CREATE OR REPLACE TYPE tp_professor UNDER tp_participante (
    id_professor VARCHAR2(20)
);
-- CREATE TABLE (SUBTYPE):
CREATE OR REPLACE TABLE Professor OF tp_professor(
    CONSTRAINT PRIMARY KEY (id_participante),
    CONSTRAINT fk_professor_participante FOREIGN KEY (id_participante)
        REFERENCES Participante(id_participante),
    
    -- Definir os atributos obrigatórios
    id_professor UNIQUE NOT NULL
);


-- EXTERNO
-- CREATE TYPE (SUBTYPE):
CREATE OR REPLACE TYPE tp_externo UNDER tp_participante(
    intituicao VARCHAR2(100)
);
-- CREATE TABLE (SUBTYPE):
CREATE OR REPLACE TABLE Externo OF tp_externo(
    CONSTRAINT PRIMARY KEY (id_participante),
    CONSTRAINT fk_externo_participante FOREIGN KEY (is_participante)
        REFERENCES Participante (id_participante),
    
    -- Defirni os atributos obrigatórios
    instituicao NOT NULL
);


-- INGRESSO
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_ingresso AS OBJECT(
    id_evento REF tp_evento,
    id participante REF tp_participante,
    tipo VARCHAR2(50),
    ingresso_status VARCHAR2(50),
    data_emissao DATE,
);
-- CREATE TABLE:
CREATE OR REPLACE TABLE Ingresso OF tp_ingresso(
    CONSTRAINT PRIMARY KEY (id_evento, id_participante),
    CONSTRAINT fk_ingresso_evento FOREIGN KEY (if_evento)
        REFERENCES Evento (id_evento),
    CONSTRAINT fk_ingresso_participante FOREIGN KEY (id_participante)
        REFERENCES Participante(id_participante),
    CONSTRAINT fk_ingresso_preco_ingressos FOREIGN KEY (id_evento, tipo)
        REFERENCES Preco_Ingresso()
)


-- PRECO_INGRESSOS
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_preco_ingresso AS OBJECT(
    evento REF tp_evento,
    tipo VARCHAR2(50),
    preco NUMBER,
    CONSTRUCTOR FUNCTION tp_preco_ingresso (evento REF tp_evento, tipo VARCHAR, preco NUMBER) RETURN SELF AS RESULT,
    MEMBER PROCEDURE setPreco (valor NUMBER)
);
-- CREATE TYPE BODY
/
CREATE OR REPLACE TYPE BODY tp_preco_ingresso AS
    CONSTRUCTOR FUNCTION tp_preco_ingresso (evento REF tp_evento, tipo VARCHAR, preco NUMBER) RETURN SELF AS RESULT IS
    BEGIN
        SELF.evento := evento;
        SELF.tipo := tipo;
        SELF.preco := preco;
    END;
    MEMBER PROCEDURE setPreco (valor NUMBER) IS 
        SELF.preco := preco;
    END;
END;
/
-- CREATE TABLE:
CREATE OR REPLACE TABLE Preco_Ingressos OF tp_preco_ingresso(
    CONSTRAINT PRIMARY KEY(evento, tipo),
    CONSTRAINT fk_preco_ingresso_evento FOREIGN KEY (evento)
        REFERENCES Evento(id_evento),
    CONSTRAINT ck_preco_ingresso_tipo CHECK (tipo IN ('Estudante', 'Geral', 'VIP'))
);


-- SESSAO
-- CREATE TYPE
CREATE OR REPLACE TYPE tp_sessao AS OBJECT(
    id_sessao NUMBER,
    titulo VARCHAR2(100),
    descricao VARCHAR2(500),
    tipo VARCHAR2(50),
    duracao NUMBER,
    capacidade NUMBER,
    data_inicio_sessao DATE,
    data_fim_sessao DATE,
    evento REF tp_evento
);
-- CREATE TABLE
CREATE OR REPLACE TABLE Sessao OF tp_evento (
    CONSTRAINT PRIMARY KEY (id_sessao),
    CONSTRAINT fk_sessao_evento FOREIGN KEY (id_evento)
        REFERENCES Evento(id_evento),
    CONSTRAINT ck_sessao_duracao CHECK (duracao > 0),
    CONSTRAINT ck_sessao_cpacidade CHECK (capacidade > 0),
    CONSTRAINT ck_sessao_datas CHECK (data_fim_sessao >= data_inicio_sessao),

    -- Definir os atributos obrigatórios
    titulo NOT NULL,
    descricao NOT NULL,
    evento NOT NULL,
    data_inicio_sessao NOT NULL,
    data_fim_sessao NOT NULL
);


-- MINISTRAR
-- CREATE TABLE
CREATE TABLE Ministrar (
    palestrante REF tp_palestrante,
    sessao REF tp_sessao,
    CONSTRAINT PRIMARY KEY (palestrante, sessao),
    CONSTRAINT fk_ministrar_palestrante FOREIGN KEY (palestrante)
        REFERENCES Palestrante (id_palestrante),
    CONSTRAINT fk_ministrar_sessao FOREIGN KEY (sessao)
        REFERENCES Sessao (id_sessao)
);


-- PARTICIPA
-- CREATE TABLE
CREATE TABLE Participa (
    participante REF tp_participante,
    sessao REF tp_sessao,
    evento REF tp_evento,
    CONSTRAINT PRIMARY KEY (sessao)
    CONSTRAINT fk_participa_participante FOREIGN KEY (participante) 
        REFERENCES Participante(id_participante),
    CONSTRAINT fk_participa_sessao FOREIGN KEY (sessao) 
        REFERENCES Sessao(id_sessao),
    CONSTRAINT fk_participa_ingresso FOREIGN KEY (evento, participante) 
        REFERENCES Ingresso(id_evento, id_participante)
);
----------------------


-- FORNECEDOR
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_fornecedor AS OBJECT (
    id_fornecedor NUMBER,
    nome VARCHAR2(100),
    tipo_servico VARCHAR2(50),
    telefone VARCHAR2(15),
    email VARCHAR2(100)
);
-- CREATE TABLE
CREATE TABLE Fornecedor OF tp_fornecedor (
    CONSTRAINT PRIMATY KEY (id_fornecedor)
);


-- CONTRATO
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_contrato AS OBJECT (
    org_responsavel REF tp_organizador,
    evento REF tp_evento,
    contrato NUMBER,
    data_contrato DATE,
    descricao_servico VARCHAR2(500),
    valor NUMBER,
    data_assinatura DATE,
    contrato_status VARCHAR2(20)
);
-- CREATE TABLE
CREATE OR REPLACE TABLE Contrato OF tp_contrato (
    CONSTRAINT PRIMARY KEY (org_responsavel, evento, contrato),
    CONSTRAINT fk_contrato_organizador FOREIGN KEY (org_responsavel)
        REFERENCES Organizador(id_organizador),
    CONSTRAINT fk_contrato_evento FOREIGN KEY (evento)
        REFERENCES Evento(id_evento),
    CONSTRAINT fk_contrato_fornecedor FOREIGN KEY (contratado)
        REFERENCES Fornecedor (id_fornecedor),
    
    -- Restrições de integralidade
    CONSTRAINT ck_valor CHECK (valor > 0),
    CONSTRAINT ck_datas CHECK (data_assinatura >= data_contrato),
    CONSTRAINT ck_status_contrato CHECK (contrato_status IN ('Ativo', 'Finalizado', 'Cancelado'))
);


-- CERTIFICADO
-- CREATE TYPE
CREATE OR REPLACE TYPE tp_certificado AS OBJECT (
    numero_certificado NUMBER,
    data_emissao DATE,
    carga_horaria NUMBER,
    certificado_status VARCHAR2 (20),
    id_evento REF tp_evento,
    id_participante REF tp_participante
);
-- CREATE TABLE
CREATE OR REPLACE TABLE Certificado OF tp_certificado (
    CONSTRAINT PRIMARY KEY (numero_certificado),
    CONSTRAINT fk_certificado_evento FOREIGN KEY (id_evento)
        REFERENCES Evento(id_evento),
    CONSTRAINT fk_certificado_participante FOREIGN KEY (id_participante)
        REFERENCES Participante (id_participante),

    -- Restriçõs de integralidade
    CONSTRAINT ck_certificado_carga_horaria CHECK (carga_horaria > 0),
    CONSTRAINT ck_certificado_status CHECK (certificado_status IN ('Emitido', 'Pendente', 'Cancelado'))
);