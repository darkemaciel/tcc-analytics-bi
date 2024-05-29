-- Excluindo coluna rank que foi utilizada para criação das tabelas processadas.

ALTER TABLE [STG].[dbo].[stg_despesas_processada] DROP COLUMN rank;

ALTER TABLE [STG].[dbo].[stg_receitas_processada] DROP COLUMN rank;


-- Alteração na estrutura das tabelas de receita, convertendo de string para numérico.

ALTER TABLE [STG].[dbo].[stg_receitas_processada]
ADD num_mes_ano NUMERIC(6, 0)

UPDATE [STG].[dbo].[stg_receitas_processada]
SET num_mes_ano = CAST(FORMAT(CAST(data_arquivo AS DATE), 'yyyyMM') AS NUMERIC)

UPDATE [STG].[dbo].[stg_receitas_processada]
SET arrecadada = CAST(REPLACE(arrecadada, ',', '.') AS decimal(15, 2))

ALTER TABLE [STG].[dbo].[stg_receitas_processada]
ALTER COLUMN arrecadada DECIMAL(15,2)

UPDATE [STG].[dbo].[stg_receitas_processada]
SET arrecadada_fundeb = CAST(REPLACE(arrecadada_fundeb, ',', '.') AS decimal(15, 2))

ALTER TABLE [STG].[dbo].[stg_receitas_processada]
ALTER COLUMN arrecadada_fundeb DECIMAL(15,2)


-- Alteração na estrutura das tabelas de despesa, convertendo de string para numérico.

ALTER TABLE [STG].[dbo].[stg_despesas_processada]
ADD num_mes_ano NUMERIC(6, 0)

UPDATE [STG].[dbo].[stg_despesas_processada]
SET num_mes_ano = CAST(FORMAT(CAST(data AS DATE), 'yyyyMM') AS NUMERIC)

UPDATE [STG].[dbo].[stg_despesas_processada]
SET previsao_atualizada = CAST(REPLACE(previsao_atualizada, ',', '.') AS decimal(15, 2))

ALTER TABLE [STG].[dbo].[stg_despesas_processada]
ALTER COLUMN previsao_atualizada DECIMAL(15,2)

UPDATE [STG].[dbo].[stg_despesas_processada]
SET empenhada = CAST(REPLACE(empenhada, ',', '.') AS decimal(15, 2))

ALTER TABLE [STG].[dbo].[stg_despesas_processada]
ALTER COLUMN empenhada DECIMAL(15,2)

UPDATE [STG].[dbo].[stg_despesas_processada]
SET liquidada = CAST(REPLACE(liquidada, ',', '.') AS decimal(15, 2))

ALTER TABLE [STG].[dbo].[stg_despesas_processada]
ALTER COLUMN liquidada DECIMAL(15,2)

UPDATE [STG].[dbo].[stg_despesas_processada]
SET paga = CAST(REPLACE(paga, ',', '.') AS decimal(15, 2))

ALTER TABLE [STG].[dbo].[stg_despesas_processada]
ALTER COLUMN paga DECIMAL(15,2)