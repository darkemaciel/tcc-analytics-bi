-- Certifique-se de que a tabela TB_STG_CALENDARIO esteja vazia antes de inserir novos dados
TRUNCATE TABLE STG.DBO.TB_DIM_CALENDARIO;

-- Inserir dados na tabela STG.DBO.TB_DIM_CALENDARIO
INSERT INTO STG.DBO.TB_DIM_CALENDARIO (
    NUM_MES_ANO,
    NUM_MES,
    NOM_MES,
    NOM_MES_ANO,
    NOM_BIMESTRE,
    NOM_BIMESTRE_ANO,
    NOM_TRIMESTRE,
    NOM_TRIMESTRE_ANO,
    NOM_SEMESTRE,
    NOM_SEMESTRE_ANO
)
SELECT 
    YEAR(data) * 100 + MONTH(data) AS NUM_MES_ANO,
    MONTH(data) AS NUM_MES,
    DATENAME(MONTH, data) AS NOM_MES,
    DATENAME(MONTH, data) + '/' + CAST(YEAR(data) AS VARCHAR(4)) AS NOM_MES_ANO,
    'Bimestre ' + CAST((MONTH(data) + 1) / 2 AS VARCHAR) AS NOM_BIMESTRE,
    'Bimestre ' + CAST((MONTH(data) + 1) / 2 AS VARCHAR) + '/' + CAST(YEAR(data) AS VARCHAR(4)) AS NOM_BIMESTRE_ANO,
    'Trimestre ' + CAST((MONTH(data) + 2) / 3 AS VARCHAR) AS NOM_TRIMESTRE,
    'Trimestre ' + CAST((MONTH(data) + 2) / 3 AS VARCHAR) + '/' + CAST(YEAR(data) AS VARCHAR(4)) AS NOM_TRIMESTRE_ANO,
    'Semestre ' + CAST((MONTH(data) + 5) / 6 AS VARCHAR) AS NOM_SEMESTRE,
    'Semestre ' + CAST((MONTH(data) + 5) / 6 AS VARCHAR) + '/' + CAST(YEAR(data) AS VARCHAR(4)) AS NOM_SEMESTRE_ANO
FROM 
    STG.DBO.stg_despesas_processada
GROUP BY 
    YEAR(data), MONTH(data), DATENAME(MONTH, data)
ORDER BY 
    YEAR(data), MONTH(data);