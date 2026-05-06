CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_role
        FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE unidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco TEXT,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco NUMERIC(10,2) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE estoque (
    id SERIAL PRIMARY KEY,
    produto_id INT NOT NULL,
    unidade_id INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_estoque_produto
        FOREIGN KEY (produto_id) REFERENCES produtos(id),
    CONSTRAINT fk_estoque_unidade
        FOREIGN KEY (unidade_id) REFERENCES unidades(id),
    CONSTRAINT uq_estoque_produto_unidade
        UNIQUE (produto_id, unidade_id)
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    unidade_id INT NOT NULL,
    canal_pedido VARCHAR(20) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'AGUARDANDO_PAGAMENTO',
    total NUMERIC(10,2) NOT NULL DEFAULT 0,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pedidos_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_pedidos_unidade
        FOREIGN KEY (unidade_id) REFERENCES unidades(id),
    CONSTRAINT ck_pedidos_canal
        CHECK (canal_pedido IN ('APP', 'TOTEM', 'BALCAO', 'PICKUP', 'WEB')),
    CONSTRAINT ck_pedidos_status
        CHECK (status IN (
            'AGUARDANDO_PAGAMENTO',
            'PAGO',
            'EM_PREPARO',
            'PRONTO',
            'ENTREGUE',
            'CANCELADO'
        ))
);

CREATE TABLE pedido_itens (
    id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_pedido_itens_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    CONSTRAINT fk_pedido_itens_produto
        FOREIGN KEY (produto_id) REFERENCES produtos(id),
    CONSTRAINT ck_pedido_itens_quantidade
        CHECK (quantidade > 0)
);

CREATE TABLE pagamentos (
    id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    payload_requisicao TEXT,
    payload_resposta TEXT,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pagamentos_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    CONSTRAINT ck_pagamentos_status
        CHECK (status IN ('PENDENTE', 'APROVADO', 'RECUSADO'))
);

CREATE TABLE logs_auditoria (
    id SERIAL PRIMARY KEY,
    usuario_id INT,
    acao VARCHAR(100) NOT NULL,
    entidade VARCHAR(100) NOT NULL,
    entidade_id INT,
    detalhe TEXT,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_logs_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_pedidos_usuario_id ON pedidos(usuario_id);
CREATE INDEX idx_pedidos_unidade_id ON pedidos(unidade_id);
CREATE INDEX idx_pedidos_status ON pedidos(status);
CREATE INDEX idx_pedidos_canal_pedido ON pedidos(canal_pedido);
CREATE INDEX idx_estoque_produto_unidade ON estoque(produto_id, unidade_id);