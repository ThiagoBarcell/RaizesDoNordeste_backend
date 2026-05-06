unit untRoutes;

interface

procedure RegistrarRotas;

implementation

uses
  Horse,
  untUserController,
  untProdutoController,
  untPedidosController,
  untEstoqueController,
  untPagamentoController,
  untFidelidadeController;

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
  THorse.Get('/produtos', ListarProdutos); //Listar os produtos cadastrados
  THorse.Post('/produtos', InserirProdutos); //Cadastrar um produto novo
  THorse.Put('/produtos', AtualizarProdutos); //Atualizar produto
  {$ENDREGION}

  {$REGION 'Rotas dos Pedidos'}
  THorse.Post('/pedidos', CriarPedido);
  THorse.Get('/pedidos', ListarPedido);
  THorse.Patch('/pedidos/:id/status', AtualizarStatusPedido);
  {$ENDREGION}

  {$REGION 'Rotas dos Estoques'}
  THorse.Get('/estoque', ListarEstoque);
  THorse.Post('/estoque/movimentar', MovimentarEstoque);
  {$ENDREGION}

  {$REGION 'Rotas de pagamento Mockado'}
  THorse.Post('/pagamentos',SolicitarPagamento);
  {$ENDREGION}

  {$REGION 'Fidelidade'}
  THorse.Get('/fidelidade',ConsultarFidelidade);
  THorse.Post('/fidelidade/consentimento', AtualizarConsentimentoFidelidade);
  THorse.Post('/fidelidade/resgatar', ResgatarFidelidade);
  {$ENDREGION}
end;

end.
