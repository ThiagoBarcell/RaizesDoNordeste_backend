CREATE TABLE IF NOT EXISTS fidelidade (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL UNIQUE,
    pontos INT NOT NULL DEFAULT 0,
    consentimento BOOLEAN NOT NULL DEFAULT FALSE,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fidelidade_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id),

    CONSTRAINT ck_fidelidade_pontos
        CHECK (pontos >= 0)
);

CREATE TABLE IF NOT EXISTS fidelidade_historico (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    pontos INT NOT NULL,
    descricao TEXT,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fidelidade_hist_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id),

    CONSTRAINT ck_fidelidade_hist_tipo
        CHECK (tipo IN ('CREDITO', 'RESGATE')),

    CONSTRAINT ck_fidelidade_hist_pontos
        CHECK (pontos > 0)
);

CREATE INDEX IF NOT EXISTS idx_fidelidade_usuario_id
    ON fidelidade(usuario_id);

CREATE INDEX IF NOT EXISTS idx_fidelidade_hist_usuario_id
    ON fidelidade_historico(usuario_id);

CREATE INDEX IF NOT EXISTS idx_fidelidade_hist_tipo
    ON fidelidade_historico(tipo);

CREATE INDEX IF NOT EXISTS idx_fidelidade_hist_criado_em
    ON fidelidade_historico(criado_em);