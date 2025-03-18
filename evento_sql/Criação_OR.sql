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
    supervisor REF tp_organizador,
    ORDER MEMBER FUNCTION comparaGanho (outro tp_organizador) RETURN INTEGER 
);
/
-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY tp_organizador AS
    -- Compra o ganho com outro organizador retornando 1 caso o ganho seja maior, 0  caso seja igual, e -1 caso seja menor que o do outro organizador. 
    ORDER MEMBER FUNCTION comparaGanho (outro tp_organizador) RETURN INTEGER IS
        self_ganho NUMBER := 0;
        outro_ganho NUMBER := 0;
    BEGIN
        FOR evento IN (SELECT * FROM Evento e WHERE e.organizador = SELF.id_organizador) LOOP
            self_ganho := self_ganho + evento.ganhos;
        END LOOP;

        FOR evento IN (SELECT * FROM Evento e WHERE e.organizador = outro.id_organizador) LOOP
            outro_ganho := outro_ganho + evento.ganhos;
        END LOOP;

        IF self_ganho > outro_ganho THEN
            RETURN 1;
        ELSIF self_ganho < outro_ganho THEN
            RETURN -1;
        ELSE
            RETURN 0;
        END IF;
    END comparaGanho;
END;
/
-- CREATE TABLE:
CREATE TABLE Organizador OF tp_organizador (
    id_organizador PRIMARY KEY,
    supervisor WITH ROWID REFERENCES Organizador,
    
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
CREATE TABLE Endereco of tp_endereco(
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
    CONSTRUCTOR FUNCTION tp_evento (id NUMBER, nome VARCHAR2, categoria VARCHAR2, inicio DATE, fim DATE, cep VARCHAR2, capacidade NUMBER, organizador REF tp_organizador) RETURN SELF AS RESULT,
    MEMBER FUNCTION ganhos RETURN NUMBER
);
/
-- ALTER TYPE
ALTER TYPE tp_evento ADD MEMBER FUNCTION getDuracao RETURN NUMBER;
/
-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY tp_evento AS
    CONSTRUCTOR FUNCTION tp_evento (id NUMBER, nome VARCHAR2, categoria VARCHAR2, inicio DATE, fim DATE, cep REF tp_endereco, capacidade NUMBER, organizador REF tp_organizador) RETURN SELF AS RESULT IS
    BEGIN
        SELF.id_evento := id;
        SELF.nome := nome;
        SELF.categoria := categoria;
        SELF.data_inicio := inicio;
        SELF.data_fim := fim;
        SELF.CEP := cep;
        SELF.capacidade_maxima := capacidade;
        SELF.organizador := organizador;
        RETURN SELF;
    END; 

    -- Calcula o ganho com a venda de ingressos de um evento
    MEMBER FUNCTION ganhos RETURN NUMBER IS
        valor_ganho NUMBER := 0;
    BEGIN
        FOR ingresso IN (SELECT * FROM Ingresso i WHERE i.id_evento = SELF.id_evento) LOOP
            valor_ganho := valor_ganho + ingresso.getPreco;
        END LOOP;
        
        -- Retorna o total de ganhos
        RETURN valor_ganho;
    END ganhos;
    
    MEMBER FUNCTION getDuracao RETURN NUMBER IS
    BEGIN
        RETURN data_fim - data_inicio;
    END getDuracao;
END;
/
-- CREATE TABLE
CREATE TABLE Evento OF tp_evento (
    id_eveNto PRIMARY KEY,
    CEP WITH ROWID REFERENCES Endereco NOT NULL,
    organizador WITH ROWID REFERENCES Organizador NOT NULL,
    
    -- Restrições de integridade
    CONSTRAINT ck_evento_categoria CHECK (categoria IN ('Seminário', 'Workshop', 'Congresso', 'Feira')),
    CONSTRAINT ck_evento_datas CHECK (data_fim >= data_inicio),
    CONSTRAINT ck_evento_capacidade CHECK (capacidade_maxima > 0),

    -- Definir os atributos obrigatórios
    nome NOT NULL,
    data_inicio NOT NULL,
    data_fim NOT NULL
);



-- NOME_PARTICIPANTE
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_nome_participante AS OBJECT (
    cpf VARCHAR2(11),
    nome VARCHAR2(50),
    sobrenome VARCHAR2(50)
);
-- CREATE TABLE:
CREATE TABLE Nomes_Participantes OF tp_nome_participante(
    cpf PRIMARY KEY
);



-- PARTICIPANTE
-- CREATE TYPE TELEFONE:
CREATE OR REPLACE TYPE tp_telefone_participante AS OBJECT(
    telefone VARCHAR2(15)
);
-- CREATE VARRAY PARA TELEFONE (NO MÁXIMO, 2 TELEFONES):
CREATE OR REPLACE TYPE v_telefone_participante AS VARRAY (2) OF REF tp_telefone_participante;
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_participante AS OBJECT(
    id_participante NUMBER,
    cpf REF tp_nome_participante,
    email VARCHAR2(100),
    telefone REF tp_telefone_participante,

    NOT INSTANTIABLE MEMBER PROCEDURE getParticipantesInfo
) NOT FINAL;
-- CREATE TABLE:
CREATE TABLE Participante OF tp_participante (
    id_participante PRIMARY KEY,
    cpf WITH ROWID REFERENCES Nomes_Participantes NOT NULL,
   
    -- Definir os atributos obrigatórios
    email NOT NULL
);



-- PALESTRANTE
-- CREATE SUBTYPE:
CREATE OR REPLACE TYPE tp_palestrante UNDER tp_participante(
    biografia VARCHAR2(500),
    perfil_linkedin VARCHAR2(200),

    CONSTRUCTOR FUNCTION tp_palestrante (id_participante NUMBER, nome VARCHAR2) RETURN SELF AS RESULT,
    OVERRIDING MEMBER PROCEDURE getParticipantesInfo
);
-- CREATE TYPE BODY
/
CREATE OR REPLACE TYPE BODY tp_palestrante AS 
    CONSTRUCTOR FUNCTION tp_participante (id_participante NUMBER, nome VARCHAR2, biografia VARCHAR2, perfil_linkedin VARCHAR2) RETURN SELF AS RESULT IS
    BEGIN
        SELF.id_participante := id_participante;
        SELF.nome := nome;
        SELF.biografia := biografia;
        SELF.perfil_linkedin := perfil_linkedin;
        RETURN;
    END;
    OVERRIDING MEMBER PROCEDURE getParticipantesInfo IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Palestrante: ' || SELF.nome || ' Biografia: ' || SELF.nome || ' Biografia: ' || SELF.biografia || ' Linkedin: ' || SELF.perfil_linkedin);
    END;
END;
/
-- CREATE TABLE (SUBTYPE):
CREATE TABLE Palestrante OF tp_palestrante(
    id_participante PRIMARY KEY
);



-- ALUNO
-- CREATE SUBTYPE:
CREATE OR REPLACE TYPE tp_aluno UNDER tp_participante (
    matricula VARCHAR2(20),

    CONSTRUCTOR FUNCTION tp_aluno (id_participante NUMBER, nome VARCHAR2, matricula VARCHAR2) RETURN SELF AS RESULT,
    OVERRIDING MEMBER PROCEDURE getParticipantesInfo
);
-- CREATE TYPE BODY
/
CREATE OR REPLACE TYPE BODY tp_aluno AS
    CONSTRUCTOR FUNCTION tp_aluno (id_participante NUMBER, nome VARCHAR2, matricula VARCHAR2) RETURN SELF AS RESULT IS
    BEGIN
        SELF.id_participante := id_participante;
        SELF.nome := nome;
        SELF.matricula := matricula;
        RETURN;
    END;
    OVERRIDING MEMBER PROCEDURE getParticipanteInfo IS 
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || SELF.nome || ' Matrícula: ' || SELF.matricula);
    END;
END;
/
-- CREATE TABLE (SUBTYPE):
CREATE TABLE Aluno OF tp_aluno(
    id_participante PRIMARY KEY,

    -- Definir os atributos obrigatórios
    matricula UNIQUE NOT NULL
);



-- PROFESSOR
-- CREATE SUBTYPE:
CREATE OR REPLACE TYPE tp_professor UNDER tp_participante (
    id_professor VARCHAR2(20),

    CONSTRUCTOR FUNCTION tp_professor (id_participante NUMBER, nome VARCHAR2) RETURN SELF AS RESULT,
    OVERRIDING MEMBER PROCEDURE getParticipantesInfo
);
-- CREAT TYPE BODY
/
CREATE OR REPLACE TYPE BODY tp_professor AS
    CONSTRUCTOR FUNCTION tp_professor (id_participante NUMBER, nome VARCHAR2, id_professor VARCHAR2) RETURN SELF AS RESULT IS
    BEGIN
        SELF.id_participante := id_participante;
        SELF.nome := nome;
        SELF. is_professor := id_professor;
        RETURN;
    END;
    OVERRIDING MEMBER PROCEDURE getParticipantesInfo IS 
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Professor: ' || SELF.nome);
    END;
END;
/
-- CREATE TABLE (SUBTYPE):
CREATE TABLE Professor OF tp_professor(
    id_participante PRIMARY KEY,
    
    -- Definir os atributos obrigatórios
    id_professor UNIQUE NOT NULL
);



-- EXTERNO
-- CREATE TYPE (SUBTYPE):
CREATE OR REPLACE TYPE tp_externo UNDER tp_participante(
    instituicao VARCHAR2(100),

    CONSTRUCTOR FUNCTION tp_externo (id_participante NUMBER, nome VARCHAR2, instituicao VARCHAR2) RETURN SELF AS RESULT,
    OVERRIDING MEMBER PROCEDURE getParticipantesInfo
);
-- CREATE TYPE BODY
/
CREATE OR REPLACE TYPE BODY tp_externo AS
    CONSTRUCTOR FUNCTION tp_extreno (id_participante NUMBER, nome VARCHAR2, instituicao VARCHAR2) RETURN SELF AS RESULT IS
    BEGIN
        SELF.id_participante := id_participante;
        SELF.nome := nome;
        SELF.instituicao := instituicao;
        RETURN;
    END;
    OVERRIDING MEMBER PROCEDURE getParticipantesInfo IS 
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Participante Externo: ' || SELF.nome || ' Instituição: ' || SELF.instituicao);
    END;
END;
/
-- CREATE TABLE (SUBTYPE):
CREATE TABLE Externo OF tp_externo(
    id_participante PRIMARY KEY,
    
    -- Definir os atributos obrigatórios
    instituicao NOT NULL
);



-- PRECO_INGRESSOS
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_preco_ingresso AS OBJECT(
    evento NUMBER,
    tipo VARCHAR2(50),
    preco NUMBER,
    CONSTRUCTOR FUNCTION tp_preco_ingresso (evento REF tp_evento, tipo VARCHAR, preco NUMBER) RETURN SELF AS RESULT,
    MEMBER PROCEDURE setPreco (valor NUMBER)
);
-- CREATE TYPE BODY
/
CREATE OR REPLACE TYPE BODY tp_preco_ingresso AS
    CONSTRUCTOR FUNCTION tp_preco_ingresso (evento NUMBER, tipo VARCHAR, preco NUMBER) RETURN SELF AS RESULT IS
    BEGIN
        SELF.evento := evento;
        SELF.tipo := tipo;
        SELF.preco := preco;
        RETURN SELF;
    END;
    MEMBER PROCEDURE setPreco (valor NUMBER) IS 
    BEGIN
        SELF.preco := valor;
    END;
END;
/
-- CREATE TABLE:
CREATE TABLE Preco_Ingressos OF tp_preco_ingresso(
    CONSTRAINT pk_preco_ingresso PRIMARY KEY(evento, tipo),
    CONSTRAINT fk_preco_ingresso_evento FOREIGN KEY (evento)
        REFERENCES Evento(id_evento),

    CONSTRAINT ck_preco_ingresso_tipo CHECK (tipo IN ('Estudante', 'Geral', 'VIP'))
);
-- Trigger que adiciona objetos de preço de ingresso toda vez que um novo evento é adicionado em tb_evento. 
CREATE OR REPLACE TRIGGER trg_preco_ingresso
AFTER INSERT ON Evento
FOR EACH ROW
DECLARE
    e tp_preco_ingresso;
    v tp_preco_ingresso;
    g tp_preco_ingresso;
BEGIN
    -- Define 3 objetos para os tipos de ingresso que um evento pode ter, com um valor padrão inicial.
    e := tp_preco_ingresso (:NEW.id_evento, 'estudante', 0.00);
    g := tp_preco_ingresso (:NEW.id_evento, 'geral', 0.00);
    v := tp_preco_ingresso (:NEW.id_evento, 'VIP', 0.00);

    -- Insere o preço dos ingressos do novo evento inserido na tabela tb_preco_ingresso.
    INSERT INTO Preco_Ingressos VALUES (e);
    INSERT INTO Preco_Ingressos VALUES (g);
    INSERT INTO Preco_Ingressos VALUES (v);
END;
/



-- INGRESSO
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_ingresso AS OBJECT(
    id_evento NUMBER,
    id_participante NUMBER,
    tipo VARCHAR2(50),
    ingresso_status VARCHAR2(50),
    data_emissao DATE,
    MAP MEMBER FUNCTION ingressoEValido RETURN NUMBER,
    MEMBER FUNCTION getPreco RETURN NUMBER
);
/
-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY tp_ingresso AS
    -- Verifica se ingresso ainda pode ser usado, 1 == sim e 0 == não.
    MAP MEMBER FUNCTION ingressoEValido RETURN NUMBER IS
        i_evento tp_evento;
    BEGIN
        SELECT e INTO i_evento FROM Evento e WHERE id_evento = SELF.id_evento;

        IF i_evento.data_fim < SYSDATE OR SELF.ingresso_status = "cancelado"
         OR SELF.ingresso_status = "usado" THEN
            RETURN 0;
        ELSE
            RETURN 1;
        END IF;
    END ingressoEValido;

    -- Retorna o preço do ingreço.
    MEMBER FUNCTION getPreco RETURN NUMBER IS
        ingresso_preco NUMBER; 
    BEGIN
        SELECT p.preco INTO ingresso_preco FROM Preco_Ingressos p WHERE p.evento = SELF.id_evento AND p.tipo = SELF.tipo;
        RETURN ingresso_preco;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END getPreco;
END;
/
-- CREATE TABLE:
CREATE TABLE Ingresso OF tp_ingresso(
    CONSTRAINT pk_ingresso PRIMARY KEY (id_evento, id_participante),
    CONSTRAINT fk_ingresso_evento FOREIGN KEY (id_evento)
        REFERENCES Evento (id_evento),
    CONSTRAINT fk_ingresso_participante FOREIGN KEY (id_participante)
        REFERENCES Participante(id_participante),
    CONSTRAINT fk_ingresso_preco_ingressos FOREIGN KEY (id_evento, tipo)
        REFERENCES Preco_Ingresso(evento, tipo),
    CONSTRAINT ck_status_ingresso CHECK (ingresso_status IN ('ativo', 'cancelado', 'usado'))
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
CREATE TABLE Sessao OF tp_evento (
    id_sessao PRIMARY KEY,
    evento WITH ROWID REFERENCES Evento NOT NULL,
    
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
    ppalestrante NUMBER,
    sessao NUMBER,
    PRIMARY KEY (palestrante, sessao),
    CONSTRAINT fk_ministrar_palestrante FOREIGN KEY (palestrante)
        REFERENCES Palestrante (id_palestrante),
    CONSTRAINT fk_ministrar_sessao FOREIGN KEY (sessao)
        REFERENCES Sessao (id_sessao)
);


-- PARTICIPA
-- CREATE TABLE
CREATE TABLE Participa (
    participante NUMBER,
    sessao NUMBER,
    evento NUMBER,
    CONSTRAINT pk_participa PRIMARY KEY (sessao),
    CONSTRAINT fk_participa_participante FOREIGN KEY (participante) 
        REFERENCES Participante(id_participante),
    CONSTRAINT fk_participa_sessao FOREIGN KEY (sessao) 
        REFERENCES Sessao(id_sessao),
    CONSTRAINT fk_participa_ingresso FOREIGN KEY (evento, participante) 
        REFERENCES Ingresso(id_evento, id_participante)
);


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
    id_fornecedor PRIMARY KEY
);


-- CONTRATO
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_contrato AS OBJECT (
    org_responsavel NUMBER,
    evento NUMBER,
    contrato NUMBER,
    data_contrato DATE,
    descricao_servico VARCHAR2(500),
    valor NUMBER,
    data_assinatura DATE,
    contrato_status VARCHAR2(20)
);
-- CREATE TABLE
CREATE TABLE Contrato OF tp_contrato (
    CONSTRAINT pk_contrato PRIMARY KEY (org_responsavel, evento, contrato),
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
CREATE TABLE Certificado OF tp_certificado (
    numero_certificado PRIMARY KEY,
    id_evento WITH ROWID REFERENCES Evento,
    id_participante WITH ROWID REFERENCES Participante,

    -- Restriçõs de integralidade
    CONSTRAINT ck_certificado_carga_horaria CHECK (carga_horaria > 0),
    CONSTRAINT ck_certificado_status CHECK (certificado_status IN ('Emitido', 'Pendente', 'Cancelado'))
);