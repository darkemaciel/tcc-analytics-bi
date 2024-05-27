-- Excluindo coluna rank que foi utilizada para criação das tabelas processadas.

ALTER TABLE [STG].[dbo].[stg_despesas_processada] DROP COLUMN rank;

ALTER TABLE [STG].[dbo].[stg_receitas_processada] DROP COLUMN rank;

-- Alteração na estrutura das tabelas de receita e despesa, convertendo de string para numérico.

