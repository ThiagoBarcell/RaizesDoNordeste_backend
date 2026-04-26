unit untRoutes;

interface

procedure RegistrarRotas;

implementation

uses
  Horse,
  untUserController,
  untProdutoController,
  untPedidosController;

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
  {$ENDREGION}
end;

end.
