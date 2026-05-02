unit untSwaggerDocs;

interface

procedure DocumentacaoSwagger;

implementation

uses
  Horse,
  Horse.GBSwagger,
  untConstantesGlobais;

type
  // ====== MODELOS ======

  TModelErro = class
  private
    Ferror: string;
    Fmessage: string;
  public
    property error: string read Ferror write Ferror;
    property message: string read Fmessage write Fmessage;
  end;

  TModelSignupRequest = class
  private
    Fnome: string;
    Femail: string;
    Fsenha: string;
  public
    property nome: string read Fnome write Fnome;
    property email: string read Femail write Femail;
    property senha: string read Fsenha write Fsenha;
  end;

  TModelLoginRequest = class
  private
    Femail: string;
    Fsenha: string;
  public
    property email: string read Femail write Femail;
    property senha: string read Fsenha write Fsenha;
  end;

  TModelLoginResponse = class
  private
    FaccessToken: string;
    FtokenType: string;
  public
    property accessToken: string read FaccessToken write FaccessToken;
    property tokenType: string read FtokenType write FtokenType;
  end;

  TModelPedidoItem = class
  private
    FprodutoId: Integer;
    Fquantidade: Integer;
  public
    property produtoId: Integer read FprodutoId write FprodutoId;
    property quantidade: Integer read Fquantidade write Fquantidade;
  end;

  TModelPedidoRequest = class
  private
    FunidadeId: Integer;
    FcanalPedido: string;
    Fitens: TArray<TModelPedidoItem>;
  public
    property unidadeId: Integer read FunidadeId write FunidadeId;
    property canalPedido: string read FcanalPedido write FcanalPedido;
    property itens: TArray<TModelPedidoItem> read Fitens write Fitens;
  end;

  TModelPagamentoRequest = class
  private
    FpedidoId: Integer;
    Faprovado: Boolean;
  public
    property pedidoId: Integer read FpedidoId write FpedidoId;
    property aprovado: Boolean read Faprovado write Faprovado;
  end;

  TModelAtualizarStatus = class
  private
    Fstatus: string;
  public
    property status: string read Fstatus write Fstatus;
  end;

procedure DocumentacaoSwagger;
begin
  THorse.Use(HorseSwagger('/swagger', '/swagger/json'));

  Swagger
    .Info
      .Title('Raízes do Nordeste API')
      .Description('API REST para gestão de pedidos, produtos, estoque e pagamentos')
      .Contact
        .Name('Thiago Barcellos')
        .Email('t.afonso.barcelos@outlook.com')
      .&End
    .&End;

  Swagger.Config
    .ClassPrefixes('TModel')
  .&End;

  Swagger
    .AddBearerSecurity
    .Description( 'Autenticação via JWT Bearer. ' +
      'Obtenha o token nas rotas /login ou /signup e informe no formato: ' +
      'Bearer <seu_token>')
  .&End;

  // ================= AUTH =================

  Swagger.Path('/signup')
    .Tag(TAG_SWAGGER_AUTH)
    .POST('Cadastro', 'Cadastrar usuário')
      .AddParamBody('Dados', 'Dados do usuário')
        .Required(True)
        .Schema(TModelSignupRequest)
      .&End
      .AddResponse(200, 'OK')
        .Schema(TModelLoginResponse)
      .&End
      .AddResponse(401, 'Não autorizado')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;

  Swagger.Path('/login')
    .Tag(TAG_SWAGGER_AUTH)
    .POST('Login', 'Autenticar usuário')
      .AddParamBody('Credenciais', 'Login')
        .Required(True)
        .Schema(TModelLoginRequest)
      .&End
      .AddResponse(200, 'OK')
        .Schema(TModelLoginResponse)
      .&End
      .AddResponse(401, 'Não autorizado')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;

  // ================= PRODUTOS =================

  Swagger.Path('/produtos')
    .Tag(TAG_SWAGGER_PRODUTOS)
    .GET('Listar', 'Lista produtos')
      .AddResponse(200, 'OK')
    .&End;

  Swagger.Path('/produtos')
    .Tag(TAG_SWAGGER_PRODUTOS)
    .POST('Criar', 'Criar produto')
      .AddResponse(201, 'Criado')
    .&End
  .&End;

  Swagger.Path('/produtos/{id}')
    .Tag(TAG_SWAGGER_PRODUTOS)
    .PUT('Atualizar', 'Atualizar produto')
      .AddParamPath('id', 'ID do produto')
    .&End
      .AddResponse(200, 'OK')
    .&End
  .&End;

  // ================= PEDIDOS =================

  Swagger.Path('/pedidos')
    .Tag(TAG_SWAGGER_PEDIDOS)
    .GET('Listar', 'Lista pedidos com filtros')
      .AddResponse(200, 'OK')
    .&End;

    Swagger.Path('/pedidos')
    .Tag(TAG_SWAGGER_PEDIDOS)
    .POST('Criar', 'Criar pedido')
      .AddParamBody('Pedido', 'Dados do pedido')
        .Required(True)
        .Schema(TModelPedidoRequest)
      .&End
      .AddResponse(201, 'Criado')
    .&End
  .&End;

  Swagger.Path('/pedidos/{id}/status')
    .Tag(TAG_SWAGGER_PEDIDOS)
    .PATCH('Atualizar status', 'Atualiza status do pedido')
      .AddParamPath('id', 'ID do pedido')
      .&End
      .AddParamBody('Status', 'Novo status')
        .Schema(TModelAtualizarStatus)
      .&End
      .AddResponse(200, 'OK')
      .&End
      .AddResponse(409, 'Transição inválida')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;

  // ================= ESTOQUE =================

  Swagger.Path('/estoque')
    .Tag(TAG_SWAGGER_ESTOQUE)
    .GET('Listar', 'Consulta estoque')
      .AddResponse(200, 'OK')
    .&End
  .&End;

  Swagger.Path('/estoque/movimentar')
    .Tag(TAG_SWAGGER_ESTOQUE)
    .POST('Movimentar', 'Movimenta estoque')
      .AddResponse(201, 'Criado')
      .&End
      .AddResponse(409, 'Erro de estoque')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;

  // ================= PAGAMENTO =================

  Swagger.Path('/pagamentos')
    .Tag(TAG_SWAGGER_PAGAMENTOS)
    .POST('Pagamento mock', 'Simula pagamento')
      .AddParamBody('Pagamento', 'Dados do pagamento')
        .Schema(TModelPagamentoRequest)
      .&End
      .AddResponse(201, 'OK')
      .&End
      .AddResponse(409, 'Erro')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;

end;

end.
