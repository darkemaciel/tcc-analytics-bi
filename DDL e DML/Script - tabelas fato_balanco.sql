-- Criando nova tabela fato_balanco

CREATE TABLE [STG].[dbo].[fato_balanco] (
    num_mes_ano NUMERIC(6),
    esfera_administrativa VARCHAR(255),
    receita_total_mes DECIMAL(15, 2),
    despesa_total_mes DECIMAL(15, 2),
    saldo_mes DECIMAL(15, 2),
    empenhada_mes DECIMAL(15, 2),
    liquidada_mes DECIMAL(15, 2),
    previsao_atualizada_mes DECIMAL(15, 2),
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
        SUM(r.arrecadada_mes) AS receita_total_mes,
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
        SUM(d.paga_mes) AS despesa_total_mes,
        SUM(d.empenhada_mes) AS empenhada_mes,
        SUM(d.liquidada_mes) AS liquidada_mes,
        SUM(d.previsao_atualizada_mes) AS previsao_atualizada_mes,
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
        ISNULL(r.receita_total_mes, 0) AS receita_total_mes,
        ISNULL(d.despesa_total_mes, 0) AS despesa_total_mes,
        ISNULL(r.receita_total_mes, 0) - ISNULL(d.despesa_total_mes, 0) AS saldo_mes,
        ISNULL(d.empenhada_mes, 0) AS empenhada_mes,
        ISNULL(d.liquidada_mes, 0) AS liquidada_mes,
        ISNULL(d.previsao_atualizada_mes, 0) AS previsao_atualizada_mes,
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
        receita_total_mes, 
        despesa_total_mes, 
        saldo_mes, 
        empenhada_mes, 
        liquidada_mes, 
        previsao_atualizada_mes, 
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
        target.receita_total_mes = source.receita_total_mes,
        target.despesa_total_mes = source.despesa_total_mes,
        target.saldo_mes = source.saldo_mes,
        target.empenhada_mes = source.empenhada_mes,
        target.liquidada_mes = source.liquidada_mes,
        target.previsao_atualizada_mes = source.previsao_atualizada_mes,
        target.data_carga = source.data_carga,
        target.NOM_MES_ANO = source.NOM_MES_ANO,
        target.NOM_BIMESTRE_ANO = source.NOM_BIMESTRE_ANO,
        target.NOM_TRIMESTRE_ANO = source.NOM_TRIMESTRE_ANO,
        target.NOM_SEMESTRE_ANO = source.NOM_SEMESTRE_ANO
WHEN NOT MATCHED THEN 
    INSERT (num_mes_ano, esfera_administrativa, receita_total_mes, despesa_total_mes, saldo_mes, empenhada_mes, liquidada_mes, previsao_atualizada_mes, data_carga, NOM_MES_ANO, NOM_BIMESTRE_ANO, NOM_TRIMESTRE_ANO, NOM_SEMESTRE_ANO)
    VALUES (source.num_mes_ano, source.esfera_administrativa, source.receita_total_mes, source.despesa_total_mes, source.saldo_mes, source.empenhada_mes, source.liquidada_mes, source.previsao_atualizada_mes, source.data_carga, source.NOM_MES_ANO, source.NOM_BIMESTRE_ANO, source.NOM_TRIMESTRE_ANO, source.NOM_SEMESTRE_ANO);
