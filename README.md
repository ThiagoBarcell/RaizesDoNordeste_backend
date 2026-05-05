# 🌵 Raízes do Nordeste API

API REST desenvolvida em Delphi utilizando o framework Horse para gerenciamento de pedidos, produtos, estoque e pagamentos em uma rede de restaurantes.

---

## 📌 Tecnologias utilizadas

* **Delphi 12 Community Edition**
* **Horse Framework**
* **FireDAC**
* **PostgreSQL**
* **JWT (Autenticação)**
* **BOSS (Gerenciador de pacotes)**
* **Swagger (GBSwagger)**

---

## ⚙️ Requisitos

Antes de executar o projeto, é necessário ter instalado:

* Delphi 12 Community Edition
* PostgreSQL (versão 14+ recomendada)
* Git
* BOSS (Gerenciador de dependências)

---

## 📁 Estrutura do projeto

```
src/
 ├── controllers
 ├── services
 ├── dao
 ├── models
 ├── routes
 ├── utils
 ├── database
 ├── constantes
 ├── Swagger
db/
 └── migrations
libs/
 └── (DLLs do PostgreSQL)
```

---

## 🔧 Instalação

### 1. Clonar o repositório

```
git clone https://github.com/ThiagoBarcell/RaizesDoNordeste_backend
```

---

### 2. Instalar dependências (BOSS)

Na raiz do projeto:

```
## 📦 Instalação de dependências (BOSS)

Este projeto utiliza o **BOSS (Bora Open Source System)** como gerenciador de pacotes para Delphi.

### ▶️ Como instalar as dependências

1. Abra o **Prompt de Comando (CMD)** ou **PowerShell**
2. Navegue até a pasta raiz do projeto:

```bash
cd caminho/do/projeto
```

Exemplo:

```bash
cd D:\Projetos\Delphi\RaizesDoNordeste
```

3. Execute o comando:

```bash
boss install
```

Este comando irá baixar automaticamente todas as dependências necessárias do projeto, como:

* Horse Framework
* Horse JWT
* Horse Logger
* GBSwagger

---

### 📌 Observação

O arquivo BOSS.exe ja se encontra na pasta do projeto, porém caso você queira intalar o BOSS em sua máquina, ou queira obter mais informações sobre o gerenciador de pacotes, acesse o repositório oficial no GitHub:

👉 https://github.com/HashLoad/boss

---

### ⚠️ Importante

O comando `boss install` deve ser executado **dentro da pasta raiz do projeto**, onde se encontra o arquivo de configuração do BOSS.

```

---

### 3. Configurar o banco de dados

Criar banco no PostgreSQL:

```
RaizesDoNordesteDB
```

---

### 4. Executar migrations

Executar os arquivos da pasta:

```
db/migrations
```

Na ordem:

```
V001__...
V002__...
V003__...
V004__...
```

---

### 5. Configurar `.env`

Criar um arquivo `.env` na raiz:

```
API_PORT=9000

DB_HOST=localhost
DB_PORT=5432
DB_NAME=RaizesDoNordesteDB
DB_USER=postgres
DB_PASSWORD=masterkey

JWT_SECRET=HORSE_API_TOP

APP_ENV=development
```

---

### 6. Configurar DLLs do PostgreSQL

As DLLs devem estar na pasta:

```
libs/
```

O projeto já está configurado para carregar automaticamente via:

```
SetDllDirectory(...)
```

---

## ▶️ Executando o projeto

Abrir o projeto no Delphi e executar:

```
Proj_RaizesDoNordesteAPI.dpr
```

Saída esperada:

```
Servidor: 9000
```

---

## 🔐 Autenticação

A API utiliza JWT.

Fluxo:

1. `POST /signup`
2. `POST /login`
3. Utilizar o token nas demais rotas:

```
Authorization: Bearer SEU_TOKEN
```

---

## 📘 Documentação Swagger

Acesse:

```
http://localhost:9000/swagger
```

---

## 📦 Endpoints principais

### Auth

* `POST /signup`
* `POST /login`
* `GET /me`

---

### Produtos

* `GET /produtos`
* `POST /produtos`
* `PUT /produtos/{id}`

---

### Pedidos

* `GET /pedidos`
* `POST /pedidos`
* `PATCH /pedidos/{id}/status`

---

### Estoque

* `GET /estoque`
* `POST /estoque/movimentar`

---

### Pagamentos

* `POST /pagamentos`

---

## 🔄 Fluxo do sistema

```
Cadastro → Login → Criar Pedido → Pagamento → Preparação → Entrega
```

---

## 📊 Controle de estoque

* Entrada
* Saída
* Ajuste
* Baixa automática por pedido

---

## 🧾 Logs de auditoria

O sistema registra:

* criação de pedidos
* alterações de status
* movimentações de estoque
* pagamentos

---

## 💳 Pagamento (Mock)

Simulação de pagamento via endpoint:

```
POST /pagamentos
```

---

## 🧠 Observações importantes

* Projeto desenvolvido com foco acadêmico
* Estrutura baseada em boas práticas de mercado
* Separação em camadas (Controller / Service / DAO)
* Controle de transição de status de pedidos
* Validações de negócio implementadas

---

## 👨‍💻 Autor

Thiago Barcellos
RU: 4673653

---

## 📌 Considerações finais

Este projeto atende aos requisitos propostos no trabalho, incluindo:

* API REST completa
* Autenticação JWT
* Controle de estoque
* Pagamento mock
* Logs de auditoria
* Documentação Swagger
* Estrutura organizada e escalável

---
