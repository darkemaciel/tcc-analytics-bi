use STG;

with filtro_colunas as (
select
	CAST(ano AS VARCHAR)+CAST(mes AS VARCHAR)+codigo_unidade_gestora+CAST(classificacao_receita AS VARCHAR)+arrecadada as id
	,ano
	,mes
	,codigo_unidade_gestora
	,unidade_gestora
	,esfera_administrativa
	,classificacao_receita
	,codigo_categoria
	,nome_categoria
	,codigo_origem
	,nome_origem
	,codigo_especie
	,nome_especie
	,codigo_grupo
	,nome_grupo
	,codigo_fonte_reduzida
	,nome_fonte_reduzida
	,codigo_detalhamento
	,nome_detalhamento
	,previsao_inicial
	,previsao_atualizada
	,arrecadada
	,previsao_inicial_fundeb
	,previsao_atualizada_fundeb
	,arrecadada_fundeb
	,data_arquivo
	,data_carga
from
	tb_stg_receitas
)
,	retirar_repetidos as (
select *
	,ROW_NUMBER() OVER (partition by id order by data_arquivo) AS rank
from filtro_colunas
)
select *
INTO stg_receitas_processada
from retirar_repetidos
where rank =1


DELETE FROM stg_receitas_processada
WHERE ano >= '2013' AND ano <= '2018';


select distinct ano
from stg_receitas_processada
