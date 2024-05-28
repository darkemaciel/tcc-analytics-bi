-- Excluindo coluna rank que foi utilizada para criação das tabelas processadas.

ALTER TABLE [STG].[dbo].[stg_despesas_processada] DROP COLUMN rank;

ALTER TABLE [STG].[dbo].[stg_receitas_processada] DROP COLUMN rank;


-- Alteração na estrutura das tabelas de receita e despesa, convertendo de string para numérico.

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