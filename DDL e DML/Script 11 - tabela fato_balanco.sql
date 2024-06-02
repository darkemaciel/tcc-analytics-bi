-- Criando nova tabela fato_balanco

CREATE TABLE [STG].[dbo].[fato_balanco] (
    num_mes_ano NUMERIC(6),
    esfera_administrativa VARCHAR(255),
    receita_total DECIMAL(15, 2),
    despesa_total DECIMAL(15, 2),
    saldo_total DECIMAL(15, 2),
    empenhada_total DECIMAL(15, 2),
    liquidada_total DECIMAL(15, 2),
    previsao_atualizada_total DECIMAL(15, 2),
    data_carga DATE,
    NOM_MES_ANO VARCHAR(100),
    NOM_BIMESTRE_ANO VARCHAR(100),
    NOM_TRIMESTRE_ANO VARCHAR(100),
    NOM_SEMESTRE_ANO VARCHAR(100),
    FOREIGN KEY (num_mes_ano) REFERENCES [STG].[dbo].[TB_DIM_CALENDARIO](num_mes_ano),
    CONSTRAINT UQ_fato_balanco UNIQUE (num_mes_ano, esfera_administrativa)
);


-- Ingestão de dados na fato_balanco usando CTE's

-- Para Receita
WITH ReceitaMunicipio AS (
    SELECT 
        r.num_mes_ano,
        m.esfera_administrativa,
        SUM(r.arrecadada_total) AS receita_total,
        r.NOM_MES_ANO,
        r.NOM_BIMESTRE_ANO,
        r.NOM_TRIMESTRE_ANO,
        r.NOM_SEMESTRE_ANO
    FROM 
        [STG].[dbo].fato_receita r
    JOIN 
        [STG].[dbo].dim_municipio m
    ON 
        r.surrogate_municipio = m.surrogate_municipio
    GROUP BY 
        r.num_mes_ano, m.esfera_administrativa, r.NOM_MES_ANO, r.NOM_BIMESTRE_ANO, r.NOM_TRIMESTRE_ANO, r.NOM_SEMESTRE_ANO
),

-- Para Despesa
DespesaMunicipio AS (
    SELECT 
        d.num_mes_ano,
        m.esfera_administrativa,
        SUM(d.paga_total) AS despesa_total,
        SUM(d.empenhada_total) AS empenhada,
        SUM(d.liquidada_total) AS liquidada,
        SUM(d.previsao_atualizada_total) AS previsao_atualizada_total,
        d.NOM_MES_ANO,
        d.NOM_BIMESTRE_ANO,
        d.NOM_TRIMESTRE_ANO,
        d.NOM_SEMESTRE_ANO
    FROM 
        [STG].[dbo].[fato_despesa] d
    JOIN 
        [STG].[dbo].dim_municipio_desp m
    ON 
        d.surrogate_municipio_desp = m.surrogate_municipio_desp
    GROUP BY 
        d.num_mes_ano, m.esfera_administrativa, d.NOM_MES_ANO, d.NOM_BIMESTRE_ANO, d.NOM_TRIMESTRE_ANO, d.NOM_SEMESTRE_ANO
)

-- Combinando os Dados de Receita e Despesa
, Combined AS (
    SELECT 
        COALESCE(r.num_mes_ano, d.num_mes_ano) AS num_mes_ano,
        COALESCE(r.esfera_administrativa, d.esfera_administrativa) AS esfera_administrativa,
        ISNULL(r.receita_total, 0) AS receita_total,
        ISNULL(d.despesa_total, 0) AS despesa_total,
        ISNULL(r.receita_total, 0) - ISNULL(d.despesa_total, 0) AS saldo_total,
        ISNULL(d.empenhada_total, 0) AS empenhada_total,
        ISNULL(d.liquidada_total, 0) AS liquidada_total,
        ISNULL(d.previsao_atualizada_total, 0) AS previsao_atualizada_total,
        GETDATE() AS data_carga,
        COALESCE(r.NOM_MES_ANO, d.NOM_MES_ANO) AS NOM_MES_ANO,
        COALESCE(r.NOM_BIMESTRE_ANO, d.NOM_BIMESTRE_ANO) AS NOM_BIMESTRE_ANO,
        COALESCE(r.NOM_TRIMESTRE_ANO, d.NOM_TRIMESTRE_ANO) AS NOM_TRIMESTRE_ANO,
        COALESCE(r.NOM_SEMESTRE_ANO, d.NOM_SEMESTRE_ANO) AS NOM_SEMESTRE_ANO
    FROM 
        ReceitaMunicipio r
    FULL OUTER JOIN 
        DespesaMunicipio d
    ON 
        r.num_mes_ano = d.num_mes_ano AND r.esfera_administrativa = d.esfera_administrativa
)

-- Garantindo que não haja duplicatas
, FinalCombined AS (
    SELECT DISTINCT
        num_mes_ano, 
        esfera_administrativa, 
        receita_total, 
        despesa_total, 
        saldo_total, 
        empenhada_total, 
        liquidada_total, 
        previsao_atualizada_total, 
        data_carga, 
        NOM_MES_ANO, 
        NOM_BIMESTRE_ANO, 
        NOM_TRIMESTRE_ANO, 
        NOM_SEMESTRE_ANO
    FROM Combined
)

-- Inserindo ou Atualizando os Dados na Tabela fato_balanco
MERGE INTO [STG].[dbo].[fato_balanco] AS target
USING FinalCombined AS source
ON (target.num_mes_ano = source.num_mes_ano AND target.esfera_administrativa = source.esfera_administrativa)
WHEN MATCHED THEN 
    UPDATE SET 
        target.receita_total = source.receita_total,
        target.despesa_total = source.despesa_total,
        target.saldo_total = source.saldo_total,
        target.empenhada_total = source.empenhada_total,
        target.liquidada_total = source.liquidada_total,
        target.previsao_atualizada_total = source.previsao_atualizada_total,
        target.data_carga = source.data_carga,
        target.NOM_MES_ANO = source.NOM_MES_ANO,
        target.NOM_BIMESTRE_ANO = source.NOM_BIMESTRE_ANO,
        target.NOM_TRIMESTRE_ANO = source.NOM_TRIMESTRE_ANO,
        target.NOM_SEMESTRE_ANO = source.NOM_SEMESTRE_ANO
WHEN NOT MATCHED THEN 
    INSERT (num_mes_ano, esfera_administrativa, receita_total, despesa_total, saldo_total, empenhada_total, liquidada_total, previsao_atualizada_total, data_carga, NOM_MES_ANO, NOM_BIMESTRE_ANO, NOM_TRIMESTRE_ANO, NOM_SEMESTRE_ANO)
    VALUES (source.num_mes_ano, source.esfera_administrativa, source.receita_total, source.despesa_total, source.saldo_total, source.empenhada_total, source.liquidada_total, source.previsao_atualizada_total, source.data_carga, source.NOM_MES_ANO, source.NOM_BIMESTRE_ANO, source.NOM_TRIMESTRE_ANO, source.NOM_SEMESTRE_ANO);
