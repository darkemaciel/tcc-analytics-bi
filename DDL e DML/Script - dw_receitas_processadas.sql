USE DW;

CREATE TABLE dbo.dw_receitas_processadas (id varchar(255), ano int, mes int, codigo_unidade_gestora varchar(255),
unidade_gestora varchar(255), esfera_administrativa varchar(255), classificacao_receita int, codigo_categoria float,
nome_origem varchar(255), codigo_especie float, nome_especie varchar(255), codigo_grupo float, nome_grupo varchar(255),
codigo_fonte_reduzida float, nome_fonte_reduzida varchar(255), codigo_detalhamento float, nome_detalhamento varchar(255),
previsao_inicial varchar(255), previsao_atualizada varchar(255), arrecadada varchar(255), previsao_inicial_fundeb varchar(255),
previsao_atualizada_fundeb varchar(255), arrecadada_fundeb varchar(255), data_arquivo varchar(255), data_carga varchar(255), rank bigint)

INSERT INTO DW.dbo.dw_receitas_processadas (id, ano, mes, codigo_unidade_gestora,
unidade_gestora, esfera_administrativa, classificacao_receita, codigo_categoria,
nome_origem, codigo_especie, nome_especie, codigo_grupo, nome_grupo,
codigo_fonte_reduzida, nome_fonte_reduzida, codigo_detalhamento, nome_detalhamento,
previsao_inicial, previsao_atualizada, arrecadada, previsao_inicial_fundeb,
previsao_atualizada_fundeb, arrecadada_fundeb, data_arquivo, data_carga, rank)
SELECT DISTINCT id, ano, mes, codigo_unidade_gestora,
unidade_gestora, esfera_administrativa, classificacao_receita, codigo_categoria,
nome_origem, codigo_especie, nome_especie, codigo_grupo, nome_grupo,
codigo_fonte_reduzida, nome_fonte_reduzida, codigo_detalhamento, nome_detalhamento,
previsao_inicial, previsao_atualizada, arrecadada, previsao_inicial_fundeb,
previsao_atualizada_fundeb, arrecadada_fundeb, data_arquivo, data_carga, rank
FROM STG.dbo.stg_receitas_processada;


SELECT count (*)
  FROM [DW].[dbo].[dw_receitas_processadas]

SELECT count (*)
  FROM [stg].[dbo].[stg_receitas_processada]