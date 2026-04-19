INSERT INTO roles (nome) VALUES
('ADMIN'),
('GERENTE'),
('CLIENTE');

INSERT INTO unidades (nome, endereco, ativo) VALUES
('Unidade Centro', 'Rua Principal, 100', TRUE),
('Unidade Shopping', 'Av. Central, 500', TRUE);

INSERT INTO produtos (nome, descricao, preco, ativo) VALUES
('Hamburguer Clássico', 'Pão, carne e queijo', 25.00, TRUE),
('Cheeseburger Bacon', 'Pão, carne, queijo e bacon', 32.00, TRUE),
('Batata Frita Média', 'Porção média de batata frita', 15.00, TRUE),
('Refrigerante Lata', '350ml', 8.00, TRUE);