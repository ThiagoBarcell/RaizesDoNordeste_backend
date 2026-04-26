unit untPedidosController;

interface

uses
  Horse;

procedure CriarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.JSON,
  System.SysUtils,
  JOSE.Core.JWT,
  untPedidosService;

procedure CriarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lUsuarioId: Integer;
  lBody: TJSONObject;
  lResponse: TJSONObject;
  lSession: TJSONObject;
  lSubject: string;
begin
  try
    lSession := Req.Session<TJSONObject>;

    if not Assigned(lSession) then
    begin
      Res.Status(401).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'TOKEN_INVALIDO')
          .AddPair('message', 'JWT não encontrado na sessão.') );
      Exit;
    end;

    //Metodo pra extrai o usuario da sessao´pra criar o pedido
    lSubject := lSession.GetValue<string>('sub', '');
    lUsuarioId := StrToIntDef(lSubject, 0);

    if lUsuarioId = 0 then
    begin
      Res.Status(401).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'TOKEN_INVALIDO')
          .AddPair('message', 'Token inválido ou sem usuário.'));
      Exit;
    end;

    lBody := Req.Body<TJSONObject>;

    if not Assigned(lBody) then
    begin
      Res.Status(400).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'BODY_INVALIDO')
          .AddPair('message', 'Body da requisição inválido.'));
      Exit;
    end;

    lResponse := TPedidoService.CriarPedido(lUsuarioId, lBody);
    Res.Status(201).Send<TJSONObject>(lResponse);

  except
    on E: Exception do
    begin
      Res.Status(500).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'ERRO_INTERNO')
          .AddPair('message', E.Message));
    end;
  end;
end;

end.
