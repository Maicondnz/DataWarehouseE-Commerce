-----------------------------------------------------------
-- 1. Carga da Dim_Clientes
-----------------------------------------------------------

WITH novos_clientes AS (
    SELECT DISTINCT
           c.customer_id                    AS nk_cod_cliente,
           c.customer_unique_id				as nk_cod_unico_cliente,
           c.customer_city                  AS nm_cidade,
           c.customer_state                 AS nm_estado,
           c.customer_zip_code_prefix       AS cep_prefix
      FROM public.olist_customers_dataset c
)
INSERT INTO dw.dim_cliente (
    nk_cod_cliente,
    nk_cod_unico_cliente,
    cep_prefix,
    nm_cidade,
    nm_estado,
    data_inicio,
    data_fim,
    flag_atual
)
SELECT
    nc.nk_cod_cliente,
    nc.nk_cod_unico_cliente,
    nc.cep_prefix,
    nc.nm_cidade,
    nc.nm_estado,
    CURRENT_DATE,
    NULL,
    TRUE
FROM novos_clientes nc
LEFT JOIN dw.dim_cliente d
       ON d.nk_cod_cliente = nc.nk_cod_cliente
       and d.nk_cod_unico_cliente = nc.nk_cod_unico_cliente
       AND d.flag_atual = true;

-----------------------------------------------------------
-- 2. Carga da Dim_Produto
-----------------------------------------------------------


WITH novos_produtos AS (
    SELECT DISTINCT
           p.product_id                  AS nk_cod_produto,
           p. product_category_name      AS nm_categoria_produto,
           p.product_name_lenght         AS tam_nome_produto,
           p.product_description_lenght  AS tam_desc_produto,
           p.product_photos_qty          AS qtd_fotos,
           p.product_weight_g            AS peso_g,
    	   COALESCE ( 
    	   p.product_length_cm * 
           p.product_height_cm * 
           p.product_width_cm, 0)        AS volume_cm
           
      FROM public.olist_products_dataset p
)
INSERT INTO dw.dim_produto (
    nk_cod_produto,
    nm_categoria,
    nm_produto_tamanho,
    desc_produto_tamanho,
    qtd_fotos,
    peso_g,
  	volume_cm,
    data_inicio,
    data_fim,
    flag_atual
)
SELECT
    np.nk_cod_produto,
    np.nm_categoria_produto,
    np.tam_nome_produto,
    np.tam_desc_produto,
    np.qtd_fotos,
    np.peso_g,
    np.volume_cm,
    CURRENT_DATE,
    NULL,
    TRUE
FROM novos_produtos np
LEFT JOIN dw.dim_produto d
       ON d.nk_cod_produto = np.nk_cod_produto
      AND d.flag_atual = true;

-----------------------------------------------------------
-- 3. Carga da Dim_Vendedor
-----------------------------------------------------------

WITH novos_vendedores AS (
    SELECT DISTINCT
           v.seller_id                    AS nk_cod_vendedor,
           v.seller_zip_code_prefix       AS cep_prefix,
           v.seller_city                  AS nm_cidade,
           v.seller_state                 AS nm_estado
      FROM public.olist_sellers_dataset v
)
INSERT INTO dw.dim_vendedor (
    nk_cod_vendedor,
    cep_prefix,
    nm_cidade,
    nm_estado,
    data_inicio,
    data_fim,
    flag_atual
)
SELECT
    nv.nk_cod_vendedor,
    nv.cep_prefix,
    nv.nm_cidade,
    nv.nm_estado,
    CURRENT_DATE,
    NULL,
    TRUE
FROM novos_vendedores nv
LEFT JOIN dw.dim_vendedor d
       ON d.nk_cod_vendedor = nv.nk_cod_vendedor
      AND d.flag_atual = true;

-----------------------------------------------------------
-- 4. Carga da Dim_Data
-----------------------------------------------------------

INSERT INTO dw.dim_data (data, dia, mes, ano, nome_mes, trimestre)
SELECT 
    dt::timestamp,
    EXTRACT(DAY FROM dt)::INT,
    EXTRACT(MONTH FROM dt)::INT,
    EXTRACT(YEAR FROM dt)::INT,
    TO_CHAR(dt, 'TMMonth'),
    EXTRACT(QUARTER FROM dt)::INT
FROM generate_series(
    (SELECT MIN(order_purchase_timestamp)::date FROM public.olist_orders_dataset),
    (SELECT MAX(order_purchase_timestamp)::date FROM public.olist_orders_dataset),
    INTERVAL '1 day'
) AS dt;

-----------------------------------------------------------
-- 5. Carga do Fato Vendas (fato_vendas)
-----------------------------------------------------------
INSERT INTO dw.fato_vendas (
    sk_data_compra,
    sk_data_envio,
    sk_data_entrega,
    sk_cliente,
    sk_vendedor,
    sk_produto,
    nk_cod_pedido,
    num_item,
    vlr_item,
    vlr_frete,
    status_pedido,
    tempo_estimado_entrega_dias,
    tempo_real_entrega_dias
)
SELECT 
    dd_compra.sk_data,
    dd_envio.sk_data,
    dd_entrega.sk_data,
    dc.sk_cliente,
    dv.sk_vendedor,
    dp.sk_produto,
    o.order_id::varchar,
    oi.order_item_id,
    oi.price,
    oi.freight_value,
    o.order_status,
    (CAST(o.order_estimated_delivery_date AS date) - CAST(o.order_purchase_timestamp AS date))::INT,
    (CAST(o.order_delivered_customer_date AS date) - CAST(o.order_purchase_timestamp AS date))::INT
FROM public.olist_orders_dataset o
JOIN public.olist_order_items_dataset oi 
    ON o.order_id = oi.order_id
JOIN dw.dim_data dd_compra 
    ON dd_compra.data = CAST(NULLIF(o.order_purchase_timestamp, '') AS date)
JOIN dw.dim_data dd_envio 
    ON dd_envio.data = CAST(NULLIF(o.order_delivered_carrier_date, '') AS date)
JOIN dw.dim_data dd_entrega 
    ON dd_entrega.data = CAST(NULLIF(o.order_delivered_customer_date, '') AS date)
JOIN dw.dim_cliente dc 
    ON dc.nk_cod_cliente = o.customer_id::varchar
JOIN dw.dim_vendedor dv 
    ON dv.nk_cod_vendedor = oi.seller_id::varchar
JOIN dw.dim_produto dp 
    ON dp.nk_cod_produto = oi.product_id::varchar;

 
 
 
 
 
SELECT 
    fv.sk_fato_vendas,
    fv.nk_cod_pedido,
    fv.num_item,
    fv.vlr_item,
    fv.vlr_frete,
    fv.status_pedido,
    fv.tempo_estimado_entrega_dias,
    fv.tempo_real_entrega_dias,
    dd_compra.data AS data_compra,
    dd_entrega.data AS data_entrega
FROM dw.fato_vendas fv
LEFT JOIN dw.dim_data dd_compra 
    ON fv.sk_data_compra = dd_compra.sk_data
LEFT JOIN dw.dim_data dd_entrega 
    ON fv.sk_data_entrega = dd_entrega.sk_data;


 
 
 
 