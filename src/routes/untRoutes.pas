unit untRoutes;

interface

procedure RegistrarRotas;

implementation

uses
  Horse,
  untUserController,
  untProdutoController;

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

  {$REGION 'Rotas do Produto'}
  THorse.Get('/produtos', ListarProdutos); //Listar os produtos cadastrados
  THorse.Post('/produtos', InserirProdutos); //Cadastrar um produto novo
  THorse.Put('/produtos', AtualizarProdutos); //Atualizar produto

  {$ENDREGION}
end;

end.
