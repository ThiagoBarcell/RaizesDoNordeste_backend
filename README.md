# Raízes do Nordeste API

API REST desenvolvida em **Delphi** com o framework **Horse**, utilizando **PostgreSQL** como banco de dados.
---

## Objetivo do projeto

Construir uma API backend para uma rede de restaurantes com foco em:

- cadastro de usuários
- autenticação com JWT
- persistência em PostgreSQL
- organização do projeto em camadas

---

## Tecnologias utilizadas

---

- Delphi 10.3 Rio
- Horse
- Jhonson
- Horse JWT
- BCrypt
- FireDAC
- PostgreSQL
- BOSS

### Pré-requisitos

---

Antes de executar o projeto, é necessário ter instalado:

1. Delphi
Delphi 10.3 Rio

2. PostgreSQL
PostgreSQL instalado localmente
banco disponível na porta configurada no .env

3. BOSS
Gerenciador de pacotes para Delphi.
O BOSS ja se encontra na pasta do projeto boss.exe

4. Projeto compilado em Win64

O projeto utiliza DLLs x64 do PostgreSQL.

### Como recriar o cenário atual do projeto

---

A sequência abaixo recria o cenário atual completo.

#### 1. Clonar o projeto

git clone https://github.com/ThiagoBarcell/RaizesDoNordeste_backend

Ou baixar o ZIP do projeto e extrair.

#### 2. Abrir o projeto no Delphi

Abra o arquivo:

Proj_RaizesDoNordesteAPI.dproj

#### 3. Instalar as dependências com BOSS

Na raiz do projeto, usando o cmd , execute:

boss install

Esse comando instalará as dependências declaradas no boss.json.

Caso precise instalar manualmente, os pacotes utilizados até o momento são:

boss install horse
boss install jhonson
boss install horse-jwt
boss install horse-cors
boss install jose-jwt
boss install https://github.com/viniciussanchez/bcrypt
Observação

Se o projeto já possuir boss.json e boss-lock.json, o ideal é usar apenas:
boss install

#### 4. Configurar o arquivo .env

Na raiz do projeto, crie um arquivo chamado:

.env

Você pode copiar o .env.example e renomear para .env.

Exemplo de .env
API_PORT=9000

DB_HOST=localhost
DB_PORT=9900
DB_NAME=RaizesDoNordesteDB
DB_USER=postgres
DB_PASSWORD=masterkey

JWT_TOKEN=HORSE_API_TOP
JWT_EXPIRES=1d

APP_ENV=development

Explicação das variáveis
APP_PORT: porta onde a API será executada
DB_HOST: host do PostgreSQL
DB_PORT: porta do PostgreSQL
DB_NAME: nome do banco
DB_USER: usuário do banco
DB_PASSWORD: senha do banco
JWT_SECRET: chave de assinatura do token JWT
JWT_EXPIRES: tempo de expiração do token
APP_ENV: ambiente atual

#### 5. Criar o banco de dados no PostgreSQL

No PostgreSQL, crie o banco manualmente:

CREATE DATABASE RaizesDoNordesteDB;

#### 6. Executar as migrations

Os scripts SQL estão na pasta:

db/migrations/

Execute na seguinte ordem:

#### 6.1
V001__init.sql

Esse script cria as tabelas principais do sistema:

roles
usuarios
unidades
produtos
estoque
pedidos
pedido_itens
pagamentos
logs_auditoria

#### 6.2
V002__seed_roles_unidades_produtos.sql

Esse script insere dados iniciais:

roles
unidades
produtos

#### 6.3
V003__seed_estoque.sql

Esse script insere o estoque inicial por unidade.

Ferramenta sugerida

As migrations podem ser executadas pelo DBeaver ou qualquer cliente SQL compatível com PostgreSQL.

#### 7. Configurar as DLLs do PostgreSQL

A API usa FireDAC com PostgreSQL, então são necessárias DLLs nativas do PostgreSQL em arquitetura x64.

Essas DLLs ja foram commitas no projeto, porém, caso necessário, elas devem ficar na pasta:

libs/

Exemplos:

libs/
├── libpq.dll
├── libcrypto-3-x64.dll
├── libssl-3-x64.dll
└── outras dependências necessárias
Importante

O projeto está configurado para carregar essas DLLs via SetDllDirectory(...), então elas não precisam ficar dentro da pasta do executável.

novamente, ja deixei elas commitadas nessa pasta, usar apenas se necessário

#### 8. Compilar em Win64

No Delphi, selecione a plataforma:
Win64

Isso é obrigatório, pois as DLLs utilizadas são x64.

#### 9. Configurar os diretórios de saída do Delphi

Para deixar o projeto mais organizado, recomenda-se configurar os diretórios de saída.

Final output directory

Diretório do executável:

.\build\bin\$(Platform)\$(Config)
Unit output directory

Diretório dos arquivos .dcu:

.\build\dcu\$(Platform)\$(Config)
DCP output directory

Diretório dos .dcp:

.\build\dcp\$(Platform)\$(Config)
Após alterar

Execute:

Clean
Build

#### 10. Executar a aplicação

Depois de compilar, execute a aplicação pelo Delphi ou pelo executável gerado.

Se tudo estiver correto, a API ficará disponível em:

http://localhost:9000