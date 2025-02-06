-- DROP:
-- Apaga tabelas existentes (para cria elas do zero)
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


-- CREATE:
-- Tabela Organizador
CREATE TABLE Organizador (
    id_organizador NUMBER PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    departamento VARCHAR(50) NOT NULL,
    supervisor NUMBER,
    CONSTRAINT fk_supervisor FOREIGN KEY (supervisor) REFERENCES Organizador(id_organizador)
);

-- Tabelas Evento
CREATE TABLE Endereco (
    CEP VARCHAR(10) PRIMARY KEY,
    Rua VARCHAR(50) NOT NULL,
    Numero VARCHAR(50) NOT NULL,
    Bairro VARCHAR(50) NOT NULL,
    Estado VARCHAR(50) NOT NULL,
    Cidade VARCHAR(50) NOT NULL
);

CREATE TABLE Evento (
    id_evento NUMBER PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    CEP VARCHAR(10) NOT NULL,
    capacidade_maxima NUMBER,
    organizador NUMBER NOT NULL,
    CONSTRAINT fk_evento_endereco FOREIGN KEY (CEP) REFERENCES Endereco(CEP),
    CONSTRAINT fk_evento_organizador FOREIGN KEY (organizador) REFERENCES Organizador(id_organizador),
    CONSTRAINT ck_evento_categoria CHECK (categoria IN ('Seminário', 'Workshop', 'Congresso', 'Feira')),
    CONSTRAINT ck_evento_datas CHECK (data_fim >= data_inicio),
    CONSTRAINT ck_evento_capacidade CHECK (capacidade_maxima > 0)
);


-- Tabelas Participante
CREATE TABLE Nomes_Participantes (
    cpf VARCHAR(11) PRIMARY KEY,
    nome VARCHAR(50),
    sobrenome VARCHAR(50)
);

CREATE TABLE Participante (
    id_participante NUMBER PRIMARY KEY,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    CONSTRAINT fk_participantes_nomes FOREIGN KEY (cpf) REFERENCES Nomes_Participantes(cpf)
);

CREATE TABLE Telefone_Participante (
    participante NUMBER,
    telefone VARCHAR(15),
    PRIMARY KEY (participante, telefone),
    CONSTRAINT fk_telefone_participante FOREIGN KEY (participante) REFERENCES Participante(id_participante)
);


-- Especializações de Participante
CREATE TABLE Palestrante (
    id_participante NUMBER PRIMARY KEY,
    biografia VARCHAR(500),
    perfil_linkedin VARCHAR(200),
    CONSTRAINT fk_palestrante FOREIGN KEY (id_participante) REFERENCES Participante(id_participante)
);

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