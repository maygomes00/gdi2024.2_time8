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
CREATE OR REPLACE TYPE BODY tp_evento AS
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
    PRIMARY KEY (id_organizador),
    CONSTRAINT fk_supervisor FOREIGN KEY (supervisor)
        REFERENCES Organizador(id_organizador) ON DELETE SET NULL,
    
    -- Definir os atributos obrigatórios
    nome_completo NOT NULL,
    cargo NOT NULL,
    departamento NOT NULL
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
    PRIMARY KEY(id_evento),
    CONSTRAINT fk_evento_endereco FOREIGN KEY (CEP)
        REFERENCES Endereco(CEP),
    CONSTRAINT fk_evento_organizador FOREIGN KEY (organizador)
        REFERENCES Organizador(id_organizador),
    
    -- Restrições de integridade
    CONSTRAINT ck_evento_categoria CHECK (categoria IN ('Seminário', 'Workshop', 'Congresso', 'Feira')),
    CONSTRAINT ck_evento_datas CHECK (data_fim >= data_inicio),
    CONSTRAINT ck_evento_capacidade CHECK (capacidade_maxima > 0),

    -- Definir os atributos obrigatórios
    nome NOT NULL,
    data_inicio NOT NULL,
    data_fim NOT NULL,
    CEP NOT NULL,
    organizador NOT NULL
);



-- INGRESSO
-- CREATE TYPE:
CREATE OR REPLACE TYPE tp_ingresso AS OBJECT(
    id_evento REF tp_evento,
    id_participante REF tp_participante,
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
    PRIMARY KEY (id_evento, id_participante),
    CONSTRAINT fk_ingresso_evento FOREIGN KEY (id_evento)
        REFERENCES Evento (id_evento),
    CONSTRAINT fk_ingresso_participante FOREIGN KEY (id_participante)
        REFERENCES Participante(id_participante),
    CONSTRAINT fk_ingresso_preco_ingressos FOREIGN KEY (id_evento, tipo)
        REFERENCES Preco_Ingresso(evento, tipo),
    CONSTRAINT ck_status_ingresso CHECK (ingresso_status IN ('ativo', 'cancelado', 'usado'))
);



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
    PRIMARY KEY(evento, tipo),
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