use STG;

with filtro_colunas as (
select
	CAST(ano AS VARCHAR)+CAST(mes AS VARCHAR)+codigo_unidade_gestora+CAST(codigo_completo AS VARCHAR)+paga as id
	,ano
	,mes
	,codigo_unidade_gestora
	,unidade_gestora
	,esfera_administrativa
	,codigo_orgao
	,nome_orgao
	,codigo_unidade_orcamentaria
	,nome_unidade_orcamentaria
	,codigo_funcao
	,descricao_funcao
	,codigo_sub_funcao
	,descricao_sub_funcao
	,codigo_programa
	,nome_programa
	,codigo_acao
	,nome_acao
	,codigo_completo
	,codigo_categoria
	,codigo_modalidade
	,descricao_modalidade
	,codigo_elemento
	,descricao_elemento
	,descricao_categoria
	,previsao_inicial
	,previsao_atualizada
	,empenhada
	,liquidada
	,paga
	,data
	,data_carga
from
	tb_stg_despesas
)
,	retirar_repetidos as (
select *
	,ROW_NUMBER() OVER (partition by id order by data) AS rank
from filtro_colunas
)
select *
INTO stg_despesas_processada
from retirar_repetidos
where rank =1


DELETE FROM stg_despesas_processada
WHERE ano >= '2013' AND ano <= '2018';


select distinct ano
from stg_despesas_processada