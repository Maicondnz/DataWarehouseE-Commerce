# Data Warehouse de Vendas - Olist (PostgreSQL)

Este projeto implementa um **Data Warehouse** SCD tipo2 em PostgreSQL a partir de dados transacionais da Olist, simulando um ambiente analítico para extração de insights de vendas, clientes, produtos, logística. Ideal para análise de performance comercial e logística de e-commerce

---

##  Dataset Utilizado

O projeto utiliza o [Olist E-commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) da Olist, uma empresa brasileira de marketplace.

A organização transacional das tabelas do schema `public`:

![dados transacional](imgs/Banco1%20-%20public.png)
---

##  Objetivo

O objetivo é construir um **Data Warehouse analítico** que permita a análise de métricas relevantes para o negócio, como:

-  **Vendas por categoria de produto**
-  **Tempo médio de entrega por estado**
-  **Faturamento mensal e trimestral**
-  **Vendas por vendedor**
-  **Avaliação média dos pedidos entregues**
-  **Identificação de regiões com maior volume de frete**

Essas análises visam auxiliar na **tomada de decisão estratégica**, oferecendo uma visão consolidada de desempenho comercial, logístico e de satisfação do cliente.


## Estrutura do Data Warehouse

O DW é construído no schema `dw`, utilizando um modelo **dimensional** do tipo **estrela (star schema)** com as seguintes tabelas:

![dados transacional](imgs/Banco1%20-%20dw.png)
###  Fato

- **`fato_vendas`**  
  Contém informações de cada item vendido em pedidos entregues.

###  Dimensões

- **`dim_cliente`** – Clientes, cidade, estado, zip e histórico (SCD1/SCD2 com `data_inicio`, `data_fim`, `flag_atual`)  
- **`dim_produto`** – Produtos, categoria, tamanho de nome e descrição, peso, volume  e histórico (SCD1/SCD2 com `data_inicio`, `data_fim`, `flag_atual`)  
- **`dim_vendedor`** – Vendedores, localização e histórico (SCD1/SCD2 com `data_inicio`, `data_fim`, `flag_atual`)  
- **`dim_data`** – Calendário com granularidade diária  

---

## Tecnologias e Ferramentas

- PostgreSQL
- DBeaver / pgAdmin
- SQL (DDL + ETL)
- GitHub (versão do projeto)

---

##  Processo ETL

1. **Criação das dimensões** (`dim_cliente`, `dim_produto`, etc.)
2. **Tratamento incremental** com `LEFT JOIN` e controle de alterações (`flag_atual`, `data_inicio`, `data_fim`)
3. **Carga da dimensão de data** com `generate_series`
4. **Carga da fato com filtros de pedidos entregues**
5. **Tratamento de datas nulas e strings vazias** para evitar erros de cast
6. **Relacionamento via chaves substitutas (SKs)**

---

## Próximos Passos

1. **Novas Tabelas Fatos**  
  Criação de Tabelas Fato ou Data Warehouses de acordo com a necessidade do negócio para possivel análise de formas de pagamento e reviews.

1. **Automatização do ETL**  
   Estudar e implementar ferramentas de orquestração e transformação de dados como:
   - Apache Airflow – para agendamento e controle de fluxos ETL complexos.
   - dbt Data Build Tool – para transformação de dados com versionamento e testes automatizados em SQL.
   - Pentaho Data Integration – para ETL visual com conectores prontos e integração com bancos de dados relacionais.

2. **Carga incremental**  
   Adaptar os scripts para evitar retrabalho, processando apenas os dados novos ou alterados nas tabelas fato e dimensão.

3. **Monitoramento e Logs**  
   Incluir logging das cargas e controle de erros para maior confiabilidade e rastreabilidade.
