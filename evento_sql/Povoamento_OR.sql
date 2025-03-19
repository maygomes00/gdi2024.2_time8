DROP SEQUENCE seq_evento;
DROP SEQUENCE seq_participante;
DROP SEQUENCE seq_organizador;
DROP SEQUENCE seq_sessao;
DROP SEQUENCE seq_fornecedor;
DROP SEQUENCE seq_certificado;

CREATE SEQUENCE seq_evento       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_participante START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_organizador  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sessao       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_fornecedor   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_certificado  START WITH 1 INCREMENT BY 1;

-- -------------------------------------------------------------
-- funcao: Adicionar Organizador 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_adicionar_organizador (
    p_nome_completo  IN Organizador.nome_completo%TYPE,
    p_cargo          IN Organizador.cargo%TYPE,
    p_departamento   IN Organizador.departamento%TYPE,
    p_supervisor     IN Organizador.supervisor%TYPE,
    p_id_criado      OUT NUMBER
)
IS
    v_id_org NUMBER;
BEGIN
    SELECT seq_organizador.NEXTVAL
      INTO v_id_org
      FROM DUAL;
      
    INSERT INTO Organizador (
      id_organizador, nome_completo, cargo, departamento, supervisor
    ) VALUES (
      v_id_org, p_nome_completo, p_cargo, p_departamento, p_supervisor
    );
    
    p_id_criado := v_id_org;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcao: Adicionar Endereco 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_adicionar_endereco (
    p_cep     IN Endereco.CEP%TYPE,
    p_rua     IN Endereco.Rua%TYPE,
    p_numero  IN Endereco.Numero%TYPE,
    p_bairro  IN Endereco.Bairro%TYPE,
    p_estado  IN Endereco.Estado%TYPE,
    p_cidade  IN Endereco.Cidade%TYPE
)
IS
BEGIN
    INSERT INTO Endereco (CEP, Rua, Numero, Bairro, Estado, Cidade)
    VALUES (p_cep, p_rua, p_numero, p_bairro, p_estado, p_cidade);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcao: Adicionar Evento 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_adicionar_evento (
    p_nome               IN Evento.nome%TYPE,
    p_categoria          IN Evento.categoria%TYPE,
    p_data_inicio        IN DATE,
    p_data_fim           IN DATE,
    p_cep                IN Evento.cep%TYPE,
    p_capacidade_max     IN Evento.capacidade_maxima%TYPE,
    p_organizador        IN Evento.organizador%TYPE,
    p_id_evento_criado   OUT NUMBER
)
IS
    v_id_evento NUMBER;
BEGIN
    SELECT seq_evento.NEXTVAL
      INTO v_id_evento
      FROM DUAL;

    INSERT INTO Evento (
      id_evento, nome, categoria, data_inicio, data_fim,
      cep, capacidade_maxima, organizador
    ) VALUES (
      v_id_evento,
      p_nome,
      p_categoria,
      p_data_inicio,
      p_data_fim,
      p_cep,
      p_capacidade_max,
      p_organizador
    );
    
    p_id_evento_criado := v_id_evento;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcao: Adicionar Preco_Ingresso 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_adicionar_preco_ingresso (
    p_id_evento IN Preco_Ingressos.evento%TYPE,
    p_tipo      IN Preco_Ingressos.tipo%TYPE,
    p_preco     IN Preco_Ingressos.preco%TYPE
)
IS
BEGIN
    INSERT INTO Preco_Ingressos (evento, tipo, preco)
    VALUES (p_id_evento, p_tipo, p_preco);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcao: Adicionar Participante (inclui Nomes_Participantes e Telefone) 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_adicionar_participante (
    p_cpf        IN  Nomes_Participantes.cpf%TYPE,
    p_nome       IN  Nomes_Participantes.nome%TYPE,
    p_sobrenome  IN  Nomes_Participantes.sobrenome%TYPE,
    p_email      IN  Participante.email%TYPE,
    p_telefone   IN  Telefone_Participante.telefone%TYPE,
    p_id_criado  OUT NUMBER
)
IS
    v_id_participante NUMBER;
BEGIN
    SELECT seq_participante.NEXTVAL 
      INTO v_id_participante
      FROM DUAL;
    
    INSERT INTO Nomes_Participantes (cpf, nome, sobrenome)
    VALUES (p_cpf, p_nome, p_sobrenome);
    
    INSERT INTO Participante (id_participante, cpf, email)
    VALUES (v_id_participante, p_cpf, p_email);
    
    INSERT INTO Telefone_Participante (participante, telefone)
    VALUES (v_id_participante, p_telefone);
    
    p_id_criado := v_id_participante;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcoes: Tipos Específicos de Participante 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_adicionar_palestrante (
    p_id_participante IN Palestrante.id_participante%TYPE,
    p_biografia       IN Palestrante.biografia%TYPE,
    p_perfil_linkedin IN Palestrante.perfil_linkedin%TYPE
)
IS
BEGIN
    INSERT INTO Palestrante (id_participante, biografia, perfil_linkedin)
    VALUES (p_id_participante, p_biografia, p_perfil_linkedin);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE sp_adicionar_aluno (
    p_id_participante IN Aluno.id_participante%TYPE,
    p_matricula       IN Aluno.matricula%TYPE
)
IS
BEGIN
    INSERT INTO Aluno (id_participante, matricula)
    VALUES (p_id_participante, p_matricula);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE sp_adicionar_professor (
    p_id_participante IN Professor.id_participante%TYPE,
    p_id_professor    IN Professor.id_professor%TYPE
)
IS
BEGIN
    INSERT INTO Professor (id_participante, id_professor)
    VALUES (p_id_participante, p_id_professor);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE sp_adicionar_externo (
    p_id_participante IN Externo.id_participante%TYPE,
    p_instituicao     IN Externo.instituicao%TYPE
)
IS
BEGIN
    INSERT INTO Externo (id_participante, instituicao)
    VALUES (p_id_participante, p_instituicao);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcao: Adicionar Sessao 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_adicionar_sessao (
    p_titulo            IN Sessao.titulo%TYPE,
    p_descricao         IN Sessao.descricao%TYPE,
    p_tipo              IN Sessao.tipo%TYPE,
    p_duracao           IN Sessao.duracao%TYPE,
    p_capacidade        IN Sessao.capacidade%TYPE,
    p_evento            IN Sessao.evento%TYPE,
    p_data_inicio       IN DATE,
    p_data_fim          IN DATE,
    p_id_sessao_criado  OUT NUMBER
)
IS
    v_id_sessao NUMBER;
BEGIN
    SELECT seq_sessao.NEXTVAL
      INTO v_id_sessao
      FROM DUAL;
    
    INSERT INTO Sessao (
      id_sessao, titulo, descricao, tipo, duracao,
      capacidade, evento, data_inicio_sessao, data_fim_sessao
    ) VALUES (
      v_id_sessao,
      p_titulo,
      p_descricao,
      p_tipo,
      p_duracao,
      p_capacidade,
      p_evento,
      p_data_inicio,
      p_data_fim
    );
    
    p_id_sessao_criado := v_id_sessao;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcao: Ministrar 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_registrar_ministracao (
    p_id_palestrante IN Ministrar.palestrante%TYPE,
    p_id_sessao      IN Ministrar.sessao%TYPE
)
IS
BEGIN
    INSERT INTO Ministrar (palestrante, sessao)
    VALUES (p_id_palestrante, p_id_sessao);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcao: Participa 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_registrar_participacao (
    p_id_participante IN Participa.participante%TYPE,
    p_id_sessao       IN Participa.sessao%TYPE,
    p_id_evento       IN Participa.evento%TYPE
)
IS
BEGIN
    INSERT INTO Participa (participante, sessao, evento)
    VALUES (p_id_participante, p_id_sessao, p_id_evento);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcao: Adicionar Fornecedor 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_adicionar_fornecedor (
    p_nome          IN Fornecedor.nome%TYPE,
    p_tipo_servico  IN Fornecedor.tipo_servico%TYPE,
    p_telefone      IN Fornecedor.telefone%TYPE,
    p_email         IN Fornecedor.email%TYPE,
    p_id_criado     OUT NUMBER
)
IS
    v_id_fornecedor NUMBER;
BEGIN
    SELECT seq_fornecedor.NEXTVAL
      INTO v_id_fornecedor
      FROM DUAL;

    INSERT INTO Fornecedor (
      id_fornecedor, nome, tipo_servico, telefone, email
    ) VALUES (
      v_id_fornecedor,
      p_nome,
      p_tipo_servico,
      p_telefone,
      p_email
    );
    
    p_id_criado := v_id_fornecedor;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- -------------------------------------------------------------
-- funcao: Adicionar Contrato 
-- -------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_adicionar_contrato (
    p_org_responsavel   IN Contrato.org_responsavel%TYPE,
    p_evento            IN Contrato.evento%TYPE,
    p_fornecedor        IN Contrato.contratado%TYPE,
    p_data_contrato     IN Contrato.data_contrato%TYPE,
    p_descricao_servico IN Contrato.descricao_servico%TYPE,
    p_valor             IN Contrato.valor%TYPE,
    p_data_assinatura   IN Contrato.data_assinatura%TYPE,
    p_contrato_status   IN Contrato.contrato_status%TYPE
)
IS
BEGIN
    INSERT INTO Contrato (
      org_responsavel, evento, contratado, data_contrato,
      descricao_servico, valor, data_assinatura, contrato_status
    ) VALUES (
      p_org_responsavel,
      p_evento,
      p_fornecedor,
      p_data_contrato,
      p_descricao_servico,
      p_valor,
      p_data_assinatura,
      p_contrato_status
    );
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
