-- Tabela de Dimensões Receita

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


-- Tabela Fato Receita

CREATE TABLE [STG].[dbo].fato_receita (
	num_mes_ano NUMERIC(6),
    surrogate_municipio INT,
    surrogate_categoria INT,
    surrogate_especie INT,
    surrogate_grupo INT,
    arrecadada_mes DECIMAL(15, 2),
    arrecadada_fundeb_mes DECIMAL(15, 2),
    data_carga DATE,
	NOM_MES_ANO VARCHAR(100),
	NOM_BIMESTRE_ANO VARCHAR(100),
	NOM_TRIMESTRE_ANO VARCHAR(100),
	NOM_SEMESTRE_ANO VARCHAR(100),
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
    data_carga,
    NOM_MES_ANO,
    NOM_BIMESTRE_ANO,
    NOM_TRIMESTRE_ANO,
    NOM_SEMESTRE_ANO
)
SELECT 
    s.num_mes_ano,
    dm.surrogate_municipio,
    dc.surrogate_categoria,
    de.surrogate_especie,
    dg.surrogate_grupo,
    SUM(s.arrecadada) AS arrecadada_mes,
    SUM(s.arrecadada_fundeb) AS arrecadada_fundeb_mes,
    GETDATE() AS data_carga,
    c.NOM_MES_ANO,
    c.NOM_BIMESTRE_ANO,
    c.NOM_TRIMESTRE_ANO,
    c.NOM_SEMESTRE_ANO
FROM 
    [STG].[dbo].[stg_receitas_processada] s
JOIN 
    [STG].[dbo].[TB_DIM_CALENDARIO] c ON s.num_mes_ano = c.num_mes_ano
JOIN 
    [STG].[dbo].dim_municipio dm ON s.esfera_administrativa = dm.esfera_administrativa 
                                 AND s.codigo_unidade_gestora = dm.codigo_unidade_gestora 
                                 AND s.unidade_gestora = dm.unidade_gestora
JOIN 
    [STG].[dbo].dim_categoria dc ON s.codigo_categoria = dc.codigo_categoria 
                                AND s.nome_categoria = dc.nome_categoria 
                                AND s.codigo_origem = dc.codigo_origem 
                                AND s.nome_origem = dc.nome_origem
JOIN 
    [STG].[dbo].dim_especie de ON s.codigo_especie = de.codigo_especie 
                              AND s.nome_especie = de.nome_especie
JOIN 
    [STG].[dbo].dim_grupo dg ON s.codigo_grupo = dg.codigo_grupo 
                            AND s.nome_grupo = dg.nome_grupo 
                            AND s.codigo_fonte_reduzida = dg.codigo_fonte_reduzida 
                            AND s.nome_fonte_reduzida = dg.nome_fonte_reduzida
GROUP BY 
    s.num_mes_ano,
    dm.surrogate_municipio,
    dc.surrogate_categoria,
    de.surrogate_especie,
    dg.surrogate_grupo,
    c.NOM_MES_ANO,
    c.NOM_BIMESTRE_ANO,
    c.NOM_TRIMESTRE_ANO,
    c.NOM_SEMESTRE_ANO;