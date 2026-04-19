unit untRoutes;

interface

procedure RegistrarRotas;

implementation

uses
  Horse,
  untUserController;

// Aqui será feito o cadastro de todas as rotas

procedure RegistrarRotas;
begin
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('pong');
    end);

  {$REGION 'Metodos do Usuário'}
  THorse.Post('/signup', Signup);
  THorse.Post('/login', Login);
  {$ENDREGION}
end;

end.
