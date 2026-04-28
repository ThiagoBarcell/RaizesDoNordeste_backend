CREATE TABLE IF NOT EXISTS estoque_movimentacoes (
    id SERIAL PRIMARY KEY,

    produto_id INT NOT NULL,
    unidade_id INT NOT NULL,
    usuario_id INT,

    tipo VARCHAR(30) NOT NULL,
    origem VARCHAR(30) NOT NULL,

    quantidade INT NOT NULL,
    quantidade_anterior INT NOT NULL,
    quantidade_atual INT NOT NULL,

    observacao TEXT,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_estoque_mov_produto
        FOREIGN KEY (produto_id) REFERENCES produtos(id),

    CONSTRAINT fk_estoque_mov_unidade
        FOREIGN KEY (unidade_id) REFERENCES unidades(id),

    CONSTRAINT fk_estoque_mov_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id),

    CONSTRAINT ck_estoque_mov_tipo
        CHECK (tipo IN ('ENTRADA', 'SAIDA', 'AJUSTE', 'BAIXA_PEDIDO')),

    CONSTRAINT ck_estoque_mov_origem
        CHECK (origem IN ('MANUAL', 'PEDIDO', 'SISTEMA')),

    CONSTRAINT ck_estoque_mov_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT ck_estoque_mov_saldos
        CHECK (quantidade_anterior >= 0 AND quantidade_atual >= 0)
);

CREATE INDEX IF NOT EXISTS idx_estoque_mov_produto_id
    ON estoque_movimentacoes(produto_id);

CREATE INDEX IF NOT EXISTS idx_estoque_mov_unidade_id
    ON estoque_movimentacoes(unidade_id);

CREATE INDEX IF NOT EXISTS idx_estoque_mov_usuario_id
    ON estoque_movimentacoes(usuario_id);

CREATE INDEX IF NOT EXISTS idx_estoque_mov_tipo
    ON estoque_movimentacoes(tipo);

CREATE INDEX IF NOT EXISTS idx_estoque_mov_origem
    ON estoque_movimentacoes(origem);

CREATE INDEX IF NOT EXISTS idx_estoque_mov_criado_em
    ON estoque_movimentacoes(criado_em);

CREATE INDEX IF NOT EXISTS idx_logs_usuario_id
    ON logs_auditoria(usuario_id);

CREATE INDEX IF NOT EXISTS idx_logs_acao
    ON logs_auditoria(acao);

CREATE INDEX IF NOT EXISTS idx_logs_entidade
    ON logs_auditoria(entidade);

CREATE INDEX IF NOT EXISTS idx_logs_entidade_id
    ON logs_auditoria(entidade_id);

CREATE INDEX IF NOT EXISTS idx_logs_criado_em
    ON logs_auditoria(criado_em);