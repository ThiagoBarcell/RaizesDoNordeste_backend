unit untPedidosController;

interface

uses
  Horse;

procedure CriarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);

procedure ListarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);

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

procedure ListarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Integer;
  lStatus: string;
  lCanalPedido: string;
  lResponse: TJSONArray;
begin
  try

    lId := StrToIntDef(Req.Query['id'], 0);
    lStatus := Req.Query['status'];
    lCanalPedido := Req.Query['canalPedido'];

    lResponse := TPedidoService.ListarPedido(lId, lStatus, lCanalPedido);

    Res.Status(200).Send<TJSONArray>(lResponse);
  except
    on E: Exception do
    begin
      if E.Message = 'status_invalido' then
        Res.Status(422).Send<TJSONObject>( TJSONObject.Create
            .AddPair('error', 'STATUS_INVALIDO')
            .AddPair('message', 'Status inválido.'))
      else
      if E.Message = 'canal_pedido_invalido' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'CANAL_PEDIDO_INVALIDO')
            .AddPair('message', 'Use APP, TOTEM, BALCAO, PICKUP ou WEB.'))
      else
        Res.Status(500).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'ERRO_INTERNO')
            .AddPair('message', E.Message));
    end;
  end;
end;

end.
