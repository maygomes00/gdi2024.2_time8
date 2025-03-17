-- DROP:
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


-- CREATE TYPE:
-- Tipo Organizador
CREATE OR REPLACE TYPE tp_organizador AS OBJECT(
    id_organizador NUMBER,
    nome_completo VARCHAR2(100),
    cargo VARCHAR2(50),
    departamento VARCHAR2(50),
    supervisor NUMBER,
    supervisor REF tp_organizador
);

-- CREATE TABLE:
-- Tabela Organizador
CREATE OR REPLACE TABLE Organizador OF tp_organizador (
    CONSTRAINT pk_organizador PRIMARY KEY (id_organizador),
    CONSTRAINT fk_supervisor FOREIGN KEY (supervisor)
        REFERENCES Organizador(id_organizador) ON DELETE SET NULL,
    
    -- Definir os atributos obrigatórios
    nome_completo NOT NULL,
    cargo NOT NULL,
    departamento NOT NULL
);

-- CREATE TYPE:
-- Tipo Endereco
CREATE OR REPLACE TYPE tp_endereco AS OBJECT(
    CEP VARCHAR2(10),
    Rua VARCHAR2(50),
    Numero VARCHAR2(50),
    Bairro VARCHAR2(50),
    Estado VARCHAR2(50),
    Cidade VARCHAR2(50)
);
-- CREATE TABLE:
-- Tabela Endereco
CREATE OR REPLACE TABLE Endereco of tp_endereco(
    CEP PRIMARY KEY,

    -- Definir os atributos obrigatórios
    Rua NOT NULL,
    Numero NOT NULL,
    Bairro NOT NULL,
    Estado NOT NULL,
    Cidade NOT NULL
);

-- CREATE TYPE:
-- Tipo Evento
CREATE OR REPLACE TYPE tp_evento AS OBJECT(
    id_evento NUMBER,
    nome VARCHAR2(100),
    categoria VARCHAR2(50),
    data_inicio DATE,
    data_fim DATE,
    CEP REF tp_endereco,
    capacidade_maxima NUMBER,
    organizador REF tp_organizador
);
-- CREATE TABLE
-- Tabela Evento
CREATE OR REPLACE TABLE Evento OF tp_evento (
    CONSTRAINT pk_evento PRIMARY KEY(id_evento),
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

-- CREATE TYPE:
-- Tipo Nome_Participante
CREATE OR REPLACE TYPE tp_nome_participante AS OBJECT (
    cpf VARCHAR2(11),
    nome VARCHAR2(50),
    sobrenome VARCHAR2(50)
)
-- CREATE TABLE:
-- Tabelas Nome_Participante
CREATE OR REPLACE TABLE Nomes_Participantes OF tp_nome_participante(
    CONSTRAINT PRIMARY KEY(cpf)
);

-- CREATE TYPE:
-- Tipo Participante
CREATE OR REPLACE TYPE tp_participante AS OBJECT(
    id_participante NUMBER,
    cpf VARCHAR2(11),
    email VARCHAR2(100),
    nomes REF tp_nome_participante
) NOT FINAL;
-- CREATE TABLE:
-- Tabela Participante
CREATE OR REPLACE TABLE Participante OF tp_participante (
    CONSTRAINT pk_participante PRIMARY KEY(id_participante),
    CONSTRAINT fk_nomes_participante FOREIGN KEY (cpf)
        REFERENCES Nomes_Participantes(cpf) ON DELET SET NULL,
    
    -- Definir os atributos obrigatórios
    cpf UNIQUE NOT NULL,
    email NOT NULL 
);

-- CREATE TYPE:
-- Tipo Telefone_Participante
CREATE OR REPLACE TYPE tp_telefone_participante AS OBJECT(
    participante NUMBER,
    telefone VARCHAR2(15),
    telefone_participante REF tp_participante
);
-- CREATE TABLE:
-- Tabela Telefone_Participante
CREATE OR REPLACE TABLE Telefone_Participante OF tp_telefone_participante(
    CONSTRAINT pk_telefone_participante PRIMATY KEY (participante, telefone),
    CONSTRAINT fk_telefone_participante FOREIGN KEY(participante)
        REFERENCES Participante(is_participante)
);

-- CREATE SUBTYPE:
-- Subtipo Palestrate (Participante)
CREATE OR REPLACE TYPE tp_palestrante UNDER tp_palestrante(
    id_participante REF tp_participante,
    biografia VARCHAR2(500),
    perfil_linkedin VARCHAR2(200)
);
-- CREATE TABLE (SUBTYPE):
-- Tabela Palestrante (Participante)
CREATE OR REPLACE TABLE Palestrante OF tp_palestrante(
    CONSTRAINT fk_palestrante_participante FOREIGN KEY (id_participante)
        REFERENCES Participante (id_participante)
);








--------------------------------------------------

CREATE TABLE Aluno (
    id_participante NUMBER PRIMARY KEY,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    CONSTRAINT fk_aluno FOREIGN KEY (id_participante) REFERENCES Participante(id_participante)
);

CREATE TABLE Professor (
    id_participante NUMBER PRIMARY KEY,
    id_professor VARCHAR(20) UNIQUE NOT NULL,
    CONSTRAINT fk_professor FOREIGN KEY (id_participante) REFERENCES Participante(id_participante)
);

CREATE TABLE Externo (
    id_participante NUMBER PRIMARY KEY,
    instituicao VARCHAR(100) NOT NULL,
    CONSTRAINT fk_externo FOREIGN KEY (id_participante) REFERENCES Participante(id_participante)
);


-- Tabelas ingresso
CREATE TABLE Preco_Ingressos (
    evento NUMBER,
    tipo VARCHAR(50),
    preco NUMBER,
    PRIMARY KEY (evento, tipo),
    CONSTRAINT fk_preco_ingresso_evento FOREIGN KEY (evento) REFERENCES Evento(id_evento),
    CONSTRAINT ck_presso_ingresso_tipo CHECK (tipo IN ('estudante', 'geral', 'VIP'))
);

CREATE TABLE Ingresso (
    id_evento NUMBER,
    id_participante NUMBER,
    tipo VARCHAR(50),
    ingresso_status VARCHAR(50),
    data_emissao DATE NOT NULL,
    PRIMARY KEY (id_evento, id_participante),
    CONSTRAINT fk_ingresso_participante FOREIGN KEY (id_participante) REFERENCES Participante(id_participante),
    CONSTRAINT fk_ingresso_preco_ingressos FOREIGN KEY (id_evento, tipo) REFERENCES Preco_Ingressos(evento, tipo),
    CONSTRAINT ck_ingresso_status CHECK (ingresso_status IN ('ativo', 'cancelado', 'usado'))
);


-- Tabelas Sessão
CREATE TABLE Sessao (
    id_sessao NUMBER PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao VARCHAR(500) NOT NULL,
    tipo VARCHAR(50),
    duracao NUMBER,
    capacidade NUMBER,
    evento NUMBER NOT NULL,
    data_inicio_sessao DATE NOT NULL,
    data_fim_sessao DATE NOT NULL,
    CONSTRAINT fk_sessao_evento FOREIGN KEY (evento) REFERENCES Evento(id_evento),
    CONSTRAINT ck_sessao_duracao CHECK (duracao > 0),
    CONSTRAINT ck_sessao_capacidade CHECK (capacidade > 0),
    CONSTRAINT ck_sessao_datas CHECK (data_fim_sessao >= data_inicio_sessao)
);

CREATE TABLE Ministrar (
    palestrante NUMBER,
    sessao NUMBER,
    PRIMARY KEY (palestrante, sessao),
    CONSTRAINT fk_ministrar_palestrante FOREIGN KEY (palestrante) REFERENCES Palestrante(id_participante),
    CONSTRAINT fk_ministrar_sessao FOREIGN KEY (sessao) REFERENCES Sessao(id_sessao)
);

CREATE TABLE Participa (
    participante NUMBER,
    sessao NUMBER PRIMARY KEY,
    evento NUMBER,
    CONSTRAINT fk_participa_participante FOREIGN KEY (participante) REFERENCES Participante(id_participante),
    CONSTRAINT fk_participa_sessao FOREIGN KEY (sessao) REFERENCES Sessao(id_sessao),
    CONSTRAINT fk_participa_ingresso FOREIGN KEY (evento, participante) REFERENCES Ingresso(id_evento, id_participante)
);


-- Tabela Fornecedor
CREATE TABLE Fornecedor (
    id_fornecedor NUMBER PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo_servico VARCHAR(50) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100)
);


-- Tabela Contrato
CREATE TABLE Contrato (
    org_responsavel NUMBER,
    evento NUMBER,
    contratado NUMBER,
    data_contrato DATE NOT NULL,
    descricao_servico VARCHAR(500) NOT NULL,
    valor NUMBER,
    data_assinatura DATE NOT NULL,
    contrato_status VARCHAR(20),
    PRIMARY KEY (org_responsavel, evento, contratado),
    CONSTRAINT fk_contrato_organizador FOREIGN KEY (org_responsavel) REFERENCES Organizador(id_organizador),
    CONSTRAINT fk_contrato_evento FOREIGN KEY (evento) REFERENCES Evento(id_evento),
    CONSTRAINT fk_contrato_fornecedor FOREIGN KEY (contratado) REFERENCES Fornecedor(id_fornecedor),
    CONSTRAINT ck_contrato_valor CHECK (valor > 0),
    CONSTRAINT ck_contrato_datas CHECK (data_assinatura >= data_contrato),
    CONSTRAINT ck_contrato_status CHECK (contrato_status IN ('Ativo', 'Finalizado', 'Cancelado'))
);


-- Tabela Certificado
CREATE TABLE Certificado (
    numero_certificado NUMBER PRIMARY KEY,
    data_emissao DATE NOT NULL,
    carga_horaria NUMBER,
    certificado_status VARCHAR(20),
    id_evento NUMBER,
    id_participante NUMBER,
    CONSTRAINT fk_certificado_evento FOREIGN KEY (id_evento) REFERENCES Evento(id_evento),
    CONSTRAINT fk_certificado_participante FOREIGN KEY (id_participante) REFERENCES Participante(id_participante),
    CONSTRAINT ck_certificado_carga_horaria CHECK (carga_horaria > 0),
    CONSTRAINT ck_certificado_status CHECK (certificado_status IN ('Emitido', 'Pendente', 'Cancelado'))
);