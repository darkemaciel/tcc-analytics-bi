-- Criando Tabelas de Dimensões Despesa

CREATE TABLE [STG].[dbo].[dim_municipio_desp] (
    surrogate_municipio_desp INT IDENTITY(1,1) PRIMARY KEY,
    esfera_administrativa VARCHAR(255),
    codigo_unidade_gestora VARCHAR(255),
    unidade_gestora VARCHAR(255)
);

CREATE TABLE [STG].[dbo].[dim_categoria_desp] (
    surrogate_categoria_desp INT IDENTITY(1,1) PRIMARY KEY,
    codigo_categoria INT,
    descricao_categoria VARCHAR(255)
);

CREATE TABLE [STG].[dbo].[dim_elemento_desp] (
    surrogate_elemento_desp INT IDENTITY(1,1) PRIMARY KEY,
    codigo_elemento INT,
    descricao_elemento VARCHAR(255)
);

CREATE TABLE [STG].[dbo].[dim_modalidade_desp] (
    surrogate_modalidade_desp INT IDENTITY(1,1) PRIMARY KEY,
    codigo_modalidade INT,
    descricao_modalidade VARCHAR(255)
);

CREATE TABLE [STG].[dbo].[dim_acao_desp] (
    surrogate_acao_desp INT IDENTITY(1,1) PRIMARY KEY,
    codigo_acao FLOAT,
    nome_acao VARCHAR(255)
);

CREATE TABLE [STG].[dbo].[dim_programa_desp] (
    surrogate_programa_desp INT IDENTITY(1,1) PRIMARY KEY,
    codigo_programa INT,
    nome_programa VARCHAR(255)
);

CREATE TABLE [STG].[dbo].[dim_funcao_desp] (
    surrogate_funcao_desp INT IDENTITY(1,1) PRIMARY KEY,
    codigo_funcao INT,
    descricao_funcao VARCHAR(255),
    codigo_sub_funcao INT,
    descricao_sub_funcao VARCHAR(255)
);

CREATE TABLE [STG].[dbo].[dim_unidade_orcamentaria_desp] (
    surrogate_unidade_orcamentaria_desp INT IDENTITY(1,1) PRIMARY KEY,
    codigo_unidade_orcamentaria INT,
    nome_unidade_orcamentaria VARCHAR(255)
);

CREATE TABLE [STG].[dbo].[dim_orgao_desp] (
    surrogate_orgao_desp INT IDENTITY(1,1) PRIMARY KEY,
    codigo_orgao INT,
    nome_orgao VARCHAR(255)
);

-- Tabela Fato Despesa

CREATE TABLE [STG].[dbo].[fato_despesa] (
    num_mes_ano NUMERIC(6),
    surrogate_municipio_desp INT,
    surrogate_categoria_desp INT,
    surrogate_elemento_desp INT,
    surrogate_modalidade_desp INT,
    surrogate_acao_desp INT,
    surrogate_programa_desp INT,
    surrogate_funcao_desp INT,
    surrogate_unidade_orcamentaria_desp INT,
    surrogate_orgao_desp INT,
	previsao_atualizada_mes DECIMAL(15, 2),
    empenhada_mes DECIMAL(15, 2),
	liquidada_mes DECIMAL(15, 2),
    paga_mes DECIMAL(15, 2),
    data_carga DATE,
    NOM_MES_ANO VARCHAR(100),
    NOM_BIMESTRE_ANO VARCHAR(100),
    NOM_TRIMESTRE_ANO VARCHAR(100),
    NOM_SEMESTRE_ANO VARCHAR(100),
    FOREIGN KEY (surrogate_municipio_desp) REFERENCES [STG].[dbo].[dim_municipio_desp](surrogate_municipio_desp),
    FOREIGN KEY (surrogate_categoria_desp) REFERENCES [STG].[dbo].[dim_categoria_desp](surrogate_categoria_desp),
    FOREIGN KEY (surrogate_elemento_desp) REFERENCES [STG].[dbo].[dim_elemento_desp](surrogate_elemento_desp),
    FOREIGN KEY (surrogate_modalidade_desp) REFERENCES [STG].[dbo].[dim_modalidade_desp](surrogate_modalidade_desp),
    FOREIGN KEY (surrogate_acao_desp) REFERENCES [STG].[dbo].[dim_acao_desp](surrogate_acao_desp),
    FOREIGN KEY (surrogate_programa_desp) REFERENCES [STG].[dbo].[dim_programa_desp](surrogate_programa_desp),
    FOREIGN KEY (surrogate_funcao_desp) REFERENCES [STG].[dbo].[dim_funcao_desp](surrogate_funcao_desp),
    FOREIGN KEY (surrogate_unidade_orcamentaria_desp) REFERENCES [STG].[dbo].[dim_unidade_orcamentaria_desp](surrogate_unidade_orcamentaria_desp),
    FOREIGN KEY (surrogate_orgao_desp) REFERENCES [STG].[dbo].[dim_orgao_desp](surrogate_orgao_desp),
    FOREIGN KEY (num_mes_ano) REFERENCES [STG].[dbo].[TB_DIM_CALENDARIO](num_mes_ano)
);


-- Para evitar inconsistências durante a carga de dados, usarei o TRANSACTION para garantir que todos os dados sejam inseridos corretamente.
-- Este processo garante que, em caso de erro, nenhuma das inserções será aplicada, mantendo o banco de dados em um estado consistente.
BEGIN TRANSACTION;

-- Inserir dados na dimensão Municipio Despesa
INSERT INTO [STG].[dbo].[dim_municipio_desp] (esfera_administrativa, codigo_unidade_gestora, unidade_gestora)
SELECT DISTINCT esfera_administrativa, codigo_unidade_gestora, unidade_gestora
FROM [STG].[dbo].[stg_despesas_processada];

-- Inserir dados na dimensão Categoria Despesa
INSERT INTO [STG].[dbo].[dim_categoria_desp] (codigo_categoria, descricao_categoria)
SELECT DISTINCT codigo_categoria, descricao_categoria
FROM [STG].[dbo].[stg_despesas_processada];

-- Inserir dados na dimensão Elemento Despesa
INSERT INTO [STG].[dbo].[dim_elemento_desp] (codigo_elemento, descricao_elemento)
SELECT DISTINCT codigo_elemento, descricao_elemento
FROM [STG].[dbo].[stg_despesas_processada];

-- Inserir dados na dimensão Modalidade Despesa
INSERT INTO [STG].[dbo].[dim_modalidade_desp] (codigo_modalidade, descricao_modalidade)
SELECT DISTINCT codigo_modalidade, descricao_modalidade
FROM [STG].[dbo].[stg_despesas_processada];

-- Inserir dados na dimensão Ação Despesa
INSERT INTO [STG].[dbo].[dim_acao_desp] (codigo_acao, nome_acao)
SELECT DISTINCT codigo_acao, nome_acao
FROM [STG].[dbo].[stg_despesas_processada];

-- Inserir dados na dimensão Programa Despesa
INSERT INTO [STG].[dbo].[dim_programa_desp] (codigo_programa, nome_programa)
SELECT DISTINCT codigo_programa, nome_programa
FROM [STG].[dbo].[stg_despesas_processada];

-- Inserir dados na dimensão Função Despesa
INSERT INTO [STG].[dbo].[dim_funcao_desp] (codigo_funcao, descricao_funcao, codigo_sub_funcao, descricao_sub_funcao)
SELECT DISTINCT codigo_funcao, descricao_funcao, codigo_sub_funcao, descricao_sub_funcao
FROM [STG].[dbo].[stg_despesas_processada];

-- Inserir dados na dimensão Unidade Orçamentária Despesa
INSERT INTO [STG].[dbo].[dim_unidade_orcamentaria_desp] (codigo_unidade_orcamentaria, nome_unidade_orcamentaria)
SELECT DISTINCT codigo_unidade_orcamentaria, nome_unidade_orcamentaria
FROM [STG].[dbo].[stg_despesas_processada];

-- Inserir dados na dimensão Órgão Despesa
INSERT INTO [STG].[dbo].[dim_orgao_desp] (codigo_orgao, nome_orgao)
SELECT DISTINCT codigo_orgao, nome_orgao
FROM [STG].[dbo].[stg_despesas_processada];


-- Inserir dados na tabela fato_despesa
INSERT INTO [STG].[dbo].[fato_despesa] (
    num_mes_ano, 
    surrogate_municipio_desp, 
    surrogate_categoria_desp, 
    surrogate_elemento_desp, 
    surrogate_modalidade_desp, 
    surrogate_acao_desp, 
    surrogate_programa_desp, 
    surrogate_funcao_desp, 
    surrogate_unidade_orcamentaria_desp, 
    surrogate_orgao_desp,
    previsao_atualizada_mes, 
    empenhada_mes, 
    liquidada_mes, 
    paga_mes, 
    data_carga, 
    NOM_MES_ANO, 
    NOM_BIMESTRE_ANO, 
    NOM_TRIMESTRE_ANO, 
    NOM_SEMESTRE_ANO
)
SELECT
    sdp.num_mes_ano,
    dm.surrogate_municipio_desp,
    dc.surrogate_categoria_desp,
    de.surrogate_elemento_desp,
    dmo.surrogate_modalidade_desp,
    da.surrogate_acao_desp,
    dp.surrogate_programa_desp,
    df.surrogate_funcao_desp,
    du.surrogate_unidade_orcamentaria_desp,
    do.surrogate_orgao_desp,
    SUM(sdp.previsao_atualizada) AS previsao_atualizada_mes,
    SUM(sdp.empenhada) AS empenhada_mes,
    SUM(sdp.liquidada) AS liquidada_mes,
    SUM(sdp.paga) AS paga_mes,
    GETDATE() AS data_carga,  -- Assume que a data de carga é a data atual
    c.NOM_MES_ANO,
    c.NOM_BIMESTRE_ANO,
    c.NOM_TRIMESTRE_ANO,
    c.NOM_SEMESTRE_ANO
FROM
    [STG].[dbo].[stg_despesas_processada] sdp
    JOIN [STG].[dbo].[dim_municipio_desp] dm ON sdp.esfera_administrativa = dm.esfera_administrativa 
        AND sdp.codigo_unidade_gestora = dm.codigo_unidade_gestora 
        AND sdp.unidade_gestora = dm.unidade_gestora
    JOIN [STG].[dbo].[dim_categoria_desp] dc ON sdp.codigo_categoria = dc.codigo_categoria 
        AND sdp.descricao_categoria = dc.descricao_categoria
    JOIN [STG].[dbo].[dim_elemento_desp] de ON sdp.codigo_elemento = de.codigo_elemento 
        AND sdp.descricao_elemento = de.descricao_elemento
    JOIN [STG].[dbo].[dim_modalidade_desp] dmo ON sdp.codigo_modalidade = dmo.codigo_modalidade 
        AND sdp.descricao_modalidade = dmo.descricao_modalidade
    JOIN [STG].[dbo].[dim_acao_desp] da ON sdp.codigo_acao = da.codigo_acao 
        AND sdp.nome_acao = da.nome_acao
    JOIN [STG].[dbo].[dim_programa_desp] dp ON sdp.codigo_programa = dp.codigo_programa 
        AND sdp.nome_programa = dp.nome_programa
    JOIN [STG].[dbo].[dim_funcao_desp] df ON sdp.codigo_funcao = df.codigo_funcao 
        AND sdp.descricao_funcao = df.descricao_funcao 
        AND sdp.codigo_sub_funcao = df.codigo_sub_funcao 
        AND sdp.descricao_sub_funcao = df.descricao_sub_funcao
    JOIN [STG].[dbo].[dim_unidade_orcamentaria_desp] du ON sdp.codigo_unidade_orcamentaria = du.codigo_unidade_orcamentaria 
        AND sdp.nome_unidade_orcamentaria = du.nome_unidade_orcamentaria
    JOIN [STG].[dbo].[dim_orgao_desp] do ON sdp.codigo_orgao = do.codigo_orgao 
        AND sdp.nome_orgao = do.nome_orgao
	JOIN [STG].[dbo].[TB_DIM_CALENDARIO] c ON sdp.num_mes_ano = c.num_mes_ano
GROUP BY
    sdp.num_mes_ano,
    dm.surrogate_municipio_desp,
    dc.surrogate_categoria_desp,
    de.surrogate_elemento_desp,
    dmo.surrogate_modalidade_desp,
    da.surrogate_acao_desp,
    dp.surrogate_programa_desp,
    df.surrogate_funcao_desp,
    du.surrogate_unidade_orcamentaria_desp,
    do.surrogate_orgao_desp,
    c.NOM_MES_ANO,
    c.NOM_BIMESTRE_ANO,
    c.NOM_TRIMESTRE_ANO,
    c.NOM_SEMESTRE_ANO;

COMMIT TRANSACTION;