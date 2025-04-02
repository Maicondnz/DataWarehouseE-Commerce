-- 1. Dimensão Data 
DROP TABLE IF EXISTS dw.dim_data;
CREATE TABLE dw.dim_data (
    sk_data   SERIAL PRIMARY KEY,
    data      DATE NOT NULL,
    dia       INT,
    mes       INT,
    ano       INT,
    nome_mes  VARCHAR(20),
    trimestre INT
);

-- 2. Dimensão Produto
DROP TABLE IF EXISTS dw.dim_produto;
CREATE TABLE dw.dim_produto (
    sk_produto                SERIAL PRIMARY KEY,
    nk_cod_produto            VARCHAR(50),
    nm_categoria              VARCHAR(255),
    nm_produto_tamanho        INT,  
    desc_produto_tamanho      INT,  
    qtd_fotos                 INT,   
    peso_g                    INT,   
    volume_cm                 INT,
    data_inicio               DATE,
    data_fim                  DATE,
    flag_atual                BOOLEAN
);

-- 3. Dimensão Cliente
DROP TABLE IF EXISTS dw.dim_cliente;
CREATE TABLE dw.dim_cliente (
    sk_cliente         SERIAL PRIMARY KEY,
    nk_cod_cliente        VARCHAR(50),       
    nk_cod_unico_cliente  VARCHAR(50),
    cep_prefix            INT,
    nm_cidade             VARCHAR(100),
    nm_estado             VARCHAR(50),
    data_inicio           DATE,
    data_fim              DATE,
    flag_atual            BOOLEAN
);

-- 4. Dimensão Vendedor
DROP TABLE IF EXISTS dw.dim_vendedor;
CREATE TABLE dw.dim_vendedor (
    sk_vendedor  SERIAL PRIMARY KEY,
    nk_cod_vendedor    VARCHAR(50),       
    cep_prefix         INT,
    nm_cidade          VARCHAR(100),
    nm_estado          VARCHAR(50),
    data_inicio        DATE,
    data_fim           DATE,
    flag_atual         BOOLEAN
);


-- 5. Fato Vendas (nível de item do pedido)
DROP TABLE IF EXISTS dw.fato_vendas;
CREATE TABLE dw.fato_vendas (
    sk_fato_vendas       SERIAL PRIMARY KEY,
    sk_data_compra              INT not NULL,  
    sk_data_envio               INT not NULL,  
    sk_data_entrega             INT not NULL,   
    sk_cliente                  INT not NULL,   
    sk_vendedor                 INT not NULL,   
    sk_produto                  INT not NULL,
    nk_cod_pedido               VARCHAR(50),
    num_item                    INT,
    vlr_item                    NUMERIC(10,2),
    vlr_frete                   NUMERIC(10,2),
    status_pedido               VARCHAR(50),
    tempo_estimado_entrega_dias INT, 
    tempo_real_entrega_dias     INT,
    CONSTRAINT fk_data_compra FOREIGN KEY (sk_data_compra) REFERENCES dw.dim_data(sk_data),
    CONSTRAINT fk_data_envio FOREIGN KEY (sk_data_envio) REFERENCES dw.dim_data(sk_data),
    CONSTRAINT fk_data_entrega FOREIGN KEY (sk_data_entrega) REFERENCES dw.dim_data(sk_data),
    CONSTRAINT fk_cliente FOREIGN KEY (sk_cliente) REFERENCES dw.dim_cliente(sk_cliente),
    CONSTRAINT fk_vendedor FOREIGN KEY (sk_vendedor) REFERENCES dw.dim_vendedor(sk_vendedor),
    CONSTRAINT fk_produto FOREIGN KEY (sk_produto) REFERENCES dw.dim_produto(sk_produto)
);