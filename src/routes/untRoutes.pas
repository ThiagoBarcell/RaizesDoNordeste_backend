unit untRoutes;

interface

uses
  System.SysUtils,
  System.JSON;

procedure RegistrarRotas;

implementation

uses
  Horse,
  untUserController,
  untProdutoController,
  untPedidosController,
  untEstoqueController,
  untPagamentoController,
  untFidelidadeController,
  untUserDAO,
  untConstantesGlobais;

function UsuarioEAdmin(Req: THorseRequest; Res: THorseResponse): Boolean;
var
  lSession: TJSONObject;
  lUsuarioId: Integer;
  lRoleId: Integer;
begin
  Result := False;

  lSession := Req.Session<TJSONObject>;

  if not Assigned(lSession) then
  begin
    Res.Status(401).Send<TJSONObject>(
      TJSONObject.Create
        .AddPair('error', 'TOKEN_INVALIDO')
        .AddPair('message', 'Token inválido ou ausente.'));
    Exit;
  end;

  lUsuarioId := StrToIntDef(lSession.GetValue<string>('sub', ''), 0);

  if lUsuarioId = 0 then
  begin
    Res.Status(401).Send<TJSONObject>(
      TJSONObject.Create
        .AddPair('error', 'TOKEN_INVALIDO')
        .AddPair('message', 'Token sem usuário válido.'));
    Exit;
  end;

  lRoleId := TUserDAO.GetRoleIdByUserId(lUsuarioId);

  if lRoleId <> ROLE_ADMIN then
  begin
    Res.Status(403).Send<TJSONObject>(
      TJSONObject.Create
        .AddPair('error', 'SEM_PERMISSAO')
        .AddPair('message', 'Usuário sem permissão para executar esta operação.'));
    Exit;
  end;

  Result := True;
end;

// Aqui será feito o cadastro de todas as rotas
procedure RegistrarRotas;
begin
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('pong');
    end);

  {$REGION 'Rotas do Usuário'}
  THorse.Post('/signup', Signup);
  THorse.Post('/login', Login);
  {$ENDREGION}

  {$REGION 'Rotas dos Produtos'}
  THorse.Get('/produtos', ListarProdutos); // Listar os produtos cadastrados

  THorse.Post('/produtos',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      if not UsuarioEAdmin(Req, Res) then
        Exit;

      InserirProdutos(Req, Res, Next);
    end
  ); // Cadastrar um produto novo

  THorse.Put('/produtos',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      if not UsuarioEAdmin(Req, Res) then
        Exit;

      AtualizarProdutos(Req, Res, Next);
    end
  ); // Atualizar produto
  {$ENDREGION}

  {$REGION 'Rotas dos Pedidos'}
  THorse.Post('/pedidos', CriarPedido);
  THorse.Get('/pedidos', ListarPedido);
  THorse.Patch('/pedidos/:id/status', AtualizarStatusPedido);
  {$ENDREGION}

  {$REGION 'Rotas dos Estoques'}
  THorse.Get('/estoque', ListarEstoque);

  THorse.Post('/estoque/movimentar',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      if not UsuarioEAdmin(Req, Res) then
        Exit;

      MovimentarEstoque(Req, Res, Next);
    end
  );
  {$ENDREGION}

  {$REGION 'Rotas de pagamento Mockado'}
  THorse.Post('/pagamentos', SolicitarPagamento);
  {$ENDREGION}

  {$REGION 'Fidelidade'}
  THorse.Get('/fidelidade', ConsultarFidelidade);
  THorse.Post('/fidelidade/consentimento', AtualizarConsentimentoFidelidade);
  THorse.Post('/fidelidade/resgatar', ResgatarFidelidade);
  {$ENDREGION}
end;

end.
