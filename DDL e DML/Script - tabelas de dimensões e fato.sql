-- Tabela de Dimensões

CREATE TABLE [STG].[dbo].dim_municipio (
    surrogate_municipio INT IDENTITY(1,1) PRIMARY KEY,
    esfera_administrativa VARCHAR(255),
    codigo_unidade_gestora VARCHAR(255),
    unidade_gestora VARCHAR(255)
);

CREATE TABLE [STG].[dbo].dim_categoria (
    surrogate_categoria INT IDENTITY(1,1) PRIMARY KEY,
    codigo_categoria FLOAT,
    nome_categoria VARCHAR(255),
    codigo_origem FLOAT,
    nome_origem VARCHAR(255)
);

CREATE TABLE [STG].[dbo].dim_especie (
    surrogate_especie INT IDENTITY(1,1) PRIMARY KEY,
    codigo_especie FLOAT,
    nome_especie VARCHAR(255)
);

CREATE TABLE [STG].[dbo].dim_grupo (
    surrogate_grupo INT IDENTITY(1,1) PRIMARY KEY,
    codigo_grupo FLOAT,
    nome_grupo VARCHAR(255),
    codigo_fonte_reduzida FLOAT,
    nome_fonte_reduzida VARCHAR(255)
);


-- Tabela Fato

CREATE TABLE [STG].[dbo].fato_receita (
	num_mes_ano NUMERIC(6),
    surrogate_municipio INT,
    surrogate_categoria INT,
    surrogate_especie INT,
    surrogate_grupo INT,
    arrecadada_mes DECIMAL(15, 2),
    arrecadada_fundeb_mes DECIMAL(15, 2),
    data_carga DATE,
    FOREIGN KEY (surrogate_municipio) REFERENCES [STG].[dbo].dim_municipio(surrogate_municipio),
    FOREIGN KEY (surrogate_categoria) REFERENCES [STG].[dbo].dim_categoria(surrogate_categoria),
    FOREIGN KEY (surrogate_especie) REFERENCES [STG].[dbo].dim_especie(surrogate_especie),
    FOREIGN KEY (surrogate_grupo) REFERENCES [STG].[dbo].dim_grupo(surrogate_grupo),
    FOREIGN KEY (num_mes_ano) REFERENCES [STG].[dbo].[TB_DIM_CALENDARIO](num_mes_ano)
);


-- Ingestão de dados em dim_municipio

INSERT INTO [STG].[dbo].dim_municipio (esfera_administrativa, codigo_unidade_gestora, unidade_gestora)
SELECT DISTINCT esfera_administrativa, codigo_unidade_gestora, unidade_gestora
FROM [STG].[dbo].[stg_receitas_processada];

-- Ingestão de dados em dim_categoria

INSERT INTO [STG].[dbo].dim_categoria (codigo_categoria, nome_categoria, codigo_origem, nome_origem)
SELECT DISTINCT codigo_categoria, nome_categoria, codigo_origem, nome_origem
FROM [STG].[dbo].[stg_receitas_processada];

-- Ingestão de dados em dim_especie

INSERT INTO [STG].[dbo].dim_especie (codigo_especie, nome_especie)
SELECT DISTINCT codigo_especie, nome_especie
FROM [STG].[dbo].[stg_receitas_processada];

-- Ingestão de dados em dim_grupo

INSERT INTO [STG].[dbo].dim_grupo (codigo_grupo, nome_grupo, codigo_fonte_reduzida, nome_fonte_reduzida)
SELECT DISTINCT codigo_grupo, nome_grupo, codigo_fonte_reduzida, nome_fonte_reduzida
FROM [STG].[dbo].[stg_receitas_processada];



-- Ingestão de dados na tabela fato_receita

INSERT INTO [STG].[dbo].fato_receita (
	num_mes_ano,
    surrogate_municipio,
    surrogate_categoria,
    surrogate_especie,
    surrogate_grupo,
    arrecadada_mes,
    arrecadada_fundeb_mes,
    data_carga
)
SELECT 
	s.num_mes_ano,
    (SELECT surrogate_municipio 
     FROM [STG].[dbo].dim_municipio 
     WHERE esfera_administrativa = s.esfera_administrativa 
       AND codigo_unidade_gestora = s.codigo_unidade_gestora 
       AND unidade_gestora = s.unidade_gestora) AS surrogate_municipio,

    (SELECT surrogate_categoria 
     FROM [STG].[dbo].dim_categoria 
     WHERE codigo_categoria = s.codigo_categoria 
       AND nome_categoria = s.nome_categoria 
       AND codigo_origem = s.codigo_origem 
       AND nome_origem = s.nome_origem) AS surrogate_categoria,

    (SELECT surrogate_especie 
     FROM [STG].[dbo].dim_especie 
     WHERE codigo_especie = s.codigo_especie 
       AND nome_especie = s.nome_especie) AS surrogate_especie,

    (SELECT surrogate_grupo 
     FROM [STG].[dbo].dim_grupo 
     WHERE codigo_grupo = s.codigo_grupo 
       AND nome_grupo = s.nome_grupo 
       AND codigo_fonte_reduzida = s.codigo_fonte_reduzida 
       AND nome_fonte_reduzida = s.nome_fonte_reduzida) AS surrogate_grupo,
    
    SUM(s.arrecadada) AS arrecadada_mes,
    SUM(s.arrecadada_fundeb) AS arrecadada_fundeb_mes,
    GETDATE() AS data_carga
FROM [STG].[dbo].[stg_receitas_processada] s
GROUP BY 
    s.num_mes_ano,
    s.esfera_administrativa,
    s.codigo_unidade_gestora,
    s.unidade_gestora,
    s.codigo_categoria,
    s.nome_categoria,
    s.codigo_origem,
    s.nome_origem,
    s.codigo_especie,
    s.nome_especie,
    s.codigo_grupo,
    s.nome_grupo,
    s.codigo_fonte_reduzida,
    s.nome_fonte_reduzida;