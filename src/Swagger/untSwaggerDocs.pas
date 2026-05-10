unit untSwaggerDocs;

interface

uses
  Horse,
  Horse.GBSwagger,
  untConstantesGlobais,
  System.Generics.Collections;

type
  // Esses são os modelos de retorno e exemplos

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

  TModelSignupResponse = class
  private
    Fid: Integer;
    Fnome: string;
    Femail: string;
  public
    property id: Integer read Fid write Fid;
    property nome: string read Fnome write Fnome;
    property email: string read Femail write Femail;
  end;

  TModelSignupResponseERROR422 = class
  private
    Ferror: string;
    Fmessage: string;
  public
  property error: string read Ferror write Ferror;
  property message: string read Fmessage write Fmessage;
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

type
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
    Fitens: TObjectList<TModelPedidoItem>;
    FformaPagamento : string;
  public
    property unidadeId: Integer read FunidadeId write FunidadeId;
    property canalPedido: string read FcanalPedido write FcanalPedido;
    property itens: TObjectList<TModelPedidoItem> read Fitens write Fitens;
    property formaPagamento: string read FformaPagamento write FformaPagamento;
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

  TModelProduto = class
  private
    Fnome: string;
    Fdescricao : string;
    Fpreco : string;
    Fativo : Boolean;
  public
    property nome: string read Fnome write Fnome;
    property descricao: string read Fdescricao write Fdescricao;
    property preco: string read Fpreco write Fpreco;
    property ativo: Boolean read Fativo write Fativo;
  end;

  TModelMovimentacaoEstoqueRequest = class
  private
    FprodutoId: Integer;
    FunidadeId: Integer;
    FtipoMov: string;
    Fquantidade: Integer;
    Fobservacao: string;
  public
    property produtoId: Integer read FprodutoId write FprodutoId;
    property unidadeId: Integer read FunidadeId write FunidadeId;
    property tipo: string read FtipoMov write FtipoMov;
    property quantidade: Integer read Fquantidade write Fquantidade;
    property observacao: string read Fobservacao write Fobservacao;
  end;

  TModelFidelidadeConsentimentoRequest = class
  private
    Fconsentimento: Boolean;
  public
    property consentimento: Boolean read Fconsentimento write Fconsentimento;
  end;

  TModelFidelidadeResgateRequest = class
  private
    Fpontos: Integer;
  public
    property pontos: Integer read Fpontos write Fpontos;
  end;

procedure DocumentacaoSwagger;

implementation

procedure DocumentacaoSwagger;
begin
  THorse.Use(HorseSwagger('/swagger', '/swagger/json'));

  Swagger
    .Info
      .Title('Raízes do Nordeste API')
      .Description('API REST para gestão de pedidos, produtos, estoque e pagamentos')
      .Contact
        .Name('Thiago Afonso Barcelos RU:4673653')
        .Email('t.afonso.barcelos@outlook.com')
      .&End
    .&End;

  Swagger.Config
    .ClassPrefixes('TModel')
  .&End;

  Swagger
    .AddBearerSecurity
    .Description( 'Autenticação via JWT Bearer. ' +
      'Obtenha o token na rota /login  e informe no formato: ' + sLineBreak +
      'bearer <seu_token> ')
  .&End;

  {$REGION 'AUTH'}
  Swagger.Path('/signup')
    .Tag(TAG_SWAGGER_AUTH)
    .POST('Cadastro', 'Cadastrar usuário')
      .AddParamBody('Dados', 'Dados do usuário')
        .Required(True)
        .Schema(TModelSignupRequest)
      .&End
      .AddResponse(201, 'OK')
        .Schema(TModelSignupResponse)
      .&End
      .AddResponse(401, 'Não autorizado')
        .Schema(TModelErro)
      .&End
      .AddResponse(422, 'Unknown Response Code')
        .Schema(TModelSignupResponseERROR422)
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
      .AddResponse(422, 'Unknown Response Code')
        .Schema(TModelSignupResponseERROR422)
      .&End
    .&End
  .&End;
  {$ENDREGION}

  {$REGION 'PRODUTOS'}
  Swagger.Path('/produtos')
    .Tag(TAG_SWAGGER_PRODUTOS)
    .GET('Listar', 'Lista produtos')
      .AddParamQuery('id', 'ID do produto')
    .&End
      .AddParamQuery('status', 'Status do produto : ATIVOS, INATIVOS')
    .&End
      .AddResponse(200, 'OK')
    .&End
    .AddResponse(400, 'Erro')
      .Schema(TModelErro)
    .&End;

  Swagger.Path('/produtos')
    .Tag(TAG_SWAGGER_PRODUTOS)
    .POST('Criar', 'Criar produto')
    .AddParamBody('Produto', 'Dados do produto')
    .Required(True)
    .Schema(TModelProduto)
    .&End
      .AddResponse(201, 'Criado')
    .&End
  .&End;

  Swagger.Path('/produtos')
    .Tag(TAG_SWAGGER_PRODUTOS)
    .PUT('Atualizar', 'Atualizar produto')
      .AddParamQuery('id', 'ID do produto')
    .&End
    .AddParamBody('Produto', 'Dados do Produto')
    .Required(True)
    .Schema(TModelProduto)
    .&End
      .AddResponse(200, 'OK')
    .&End
  .&End;
  {$ENDREGION}

  {$REGION 'PEDIDOS'}
  Swagger.Path('/pedidos')
    .Tag(TAG_SWAGGER_PEDIDOS)
    .GET('Listar', 'Lista pedidos com filtros')
      .AddParamQuery('id', 'ID do pedido')
    .&End
      .AddParamQuery('canalPedido', 'Canais disponíveis onde fazer pedidos : ' + CANAL_TOTEM + ', ' + CANAL_WEB + ', ' + CANAL_APP )
    .&End
      .AddParamQuery('status', 'Status dos pedidos : ' + STATUS_PED_AGUARDANDO_PAGAMENTO + ', ' +
        STATUS_PED_PAGO + ', ' + STATUS_PED_EM_PREPARO + ', ' + STATUS_PED_PRONTO + ', ' + STATUS_PED_ENTREGUE + ', ' +
          STATUS_PED_CANCELADO + ', ' + STATUS_PAGAMENTO_APROVADO + ', ' + STATUS_PAGAMENTO_RECUSADO )
    .&End
      .AddResponse(200, 'OK')
    .&End
    .AddResponse(500, 'Erro interno')
        .Schema(TModelErro)
    .&End;

    Swagger.Path('/pedidos')
    .Tag(TAG_SWAGGER_PEDIDOS)
    .POST('Criar', 'Criar pedido')
      .AddParamBody('Pedido', 'Dados do pedido, Canais de pedido : ' + CANAL_TOTEM + ', ' + CANAL_WEB + ', ' + CANAL_APP )
        .Required(True)   //Esse schema eu tive que criar na mão pois o array não estava vindo corretamente
        .Schema(TModelPedidoRequest)
      .&End
      .AddResponse(201, 'Criado')
    .&End
    .AddResponse(500, 'Erro interno')
        .Schema(TModelErro)
    .&End
  .&End;

  Swagger.Path('/pedidos/{id}/status')
    .Tag(TAG_SWAGGER_PEDIDOS)
    .PATCH('Atualizar status', 'Atualiza status do pedido')
      .AddParamPath('id', 'ID do pedido')
      .&End
      .AddParamBody('Status', 'Novo status, Lista de status dos pedidos : ' + STATUS_PED_AGUARDANDO_PAGAMENTO + ', ' +
        STATUS_PED_PAGO + ', ' + STATUS_PED_EM_PREPARO + ', ' + STATUS_PED_PRONTO + ', ' + STATUS_PED_ENTREGUE + ', ' +
          STATUS_PED_CANCELADO + ', ' + STATUS_PAGAMENTO_APROVADO + ', ' + STATUS_PAGAMENTO_RECUSADO)
        .Schema(TModelAtualizarStatus)
      .&End
      .AddResponse(200, 'OK')
      .&End
      .AddResponse(404, 'Transição inválida')
        .Schema(TModelErro)
      .&End
      .AddResponse(422, 'Transição inválida')
        .Schema(TModelErro)
      .&End
      .AddResponse(409, 'Transição inválida')
        .Schema(TModelErro)
      .&End
      .AddResponse(500, 'Transição inválida')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;
  {$ENDREGION}

  {$REGION 'ESTOQUE'}
  Swagger.Path('/estoque')
    .Tag(TAG_SWAGGER_ESTOQUE)
    .GET('Listar', 'Consulta estoque')
      .AddParamQuery('produtoId', 'ID do produto')
      .&End
      .AddParamQuery('unidadeId', 'ID da unidade ')
      .&End
      .AddResponse(200, 'OK')
    .&End
  .&End;

  Swagger.Path('/estoque/movimentar')
    .Tag(TAG_SWAGGER_ESTOQUE)
    .POST('Movimentar', 'Movimenta estoque')
      .AddParamBody('Movimentação', 'Tipo da movimentação aceitos no campo "tipo" : ' +
      MOV_TIPO_ENTRADA + ', ' + MOV_TIPO_SAIDA + ', ' + MOV_TIPO_AJUSTE)
        .Required(True)
        .Schema(TModelMovimentacaoEstoqueRequest)
      .&End
      .AddResponse(201, 'Criado')
      .&End
      .AddResponse(404, 'Não encontrado')
        .Schema(TModelErro)
      .&End
      .AddResponse(409, 'Erro de estoque')
        .Schema(TModelErro)
      .&End
      .AddResponse(422, 'Não encontrado')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;
  {$ENDREGION}

  {$REGION 'PAGAMENTO'}
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
      .AddResponse(404, 'Erro')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;
  {$ENDREGION}

  {$REGION 'Fidelidade'}
  Swagger.Path('/fidelidade')
    .Tag(TAG_SWAGGER_FIDELIDADE)
    .GET('Consultar fidelidade', 'Consulta saldo e histórico de pontos do usuário autenticado')
      .AddResponse(200, 'OK')
      .&End
      .AddResponse(401, 'Não autorizado')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;

  Swagger.Path('/fidelidade/consentimento')
    .Tag(TAG_SWAGGER_FIDELIDADE)
    .POST('Atualizar consentimento', 'Ativa ou remove o consentimento para o programa de fidelidade')
      .AddParamBody('Consentimento', 'Dados do consentimento')
        .Required(True)
        .Schema(TModelFidelidadeConsentimentoRequest)
      .&End
      .AddResponse(200, 'OK')
      .&End
      .AddResponse(401, 'Não autorizado')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;

  Swagger.Path('/fidelidade/resgatar')
    .Tag(TAG_SWAGGER_FIDELIDADE)
    .POST('Resgatar pontos', 'Realiza o resgate de pontos do usuário autenticado')
      .AddParamBody('Resgate', 'Quantidade de pontos para resgate')
        .Required(True)
        .Schema(TModelFidelidadeResgateRequest)
      .&End
      .AddResponse(200, 'OK')
      .&End
      .AddResponse(409, 'Pontos insuficientes')
        .Schema(TModelErro)
      .&End
      .AddResponse(422, 'Pontos inválidos')
        .Schema(TModelErro)
      .&End
    .&End
  .&End;
  {$ENDREGION}
end;

end.
