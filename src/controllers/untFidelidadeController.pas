unit untFidelidadeController;

interface

uses
  Horse;

procedure ConsultarFidelidade(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure AtualizarConsentimentoFidelidade(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ResgatarFidelidade(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.SysUtils,
  System.JSON,
  untFidelidadeService;

function ObterUsuarioIdDaSessao(Req: THorseRequest): Integer;
var
  lSession: TJSONObject;
begin
  Result := 0;

  lSession := Req.Session<TJSONObject>;

  if Assigned(lSession) then
    Result := StrToIntDef(lSession.GetValue<string>('sub', ''), 0);
end;

procedure ConsultarFidelidade(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lUsuarioId: Integer;
  lResponse: TJSONObject;
begin
  try
    lUsuarioId := ObterUsuarioIdDaSessao(Req);

    if lUsuarioId = 0 then
    begin
      Res.Status(401).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'TOKEN_INVALIDO')
          .AddPair('message', 'Token inválido ou sem usuário.')
      );
      Exit;
    end;

    lResponse := TFidelidadeService.Consultar(lUsuarioId);
    Res.Status(200).Send<TJSONObject>(lResponse);
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

procedure AtualizarConsentimentoFidelidade(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lUsuarioId: Integer;
  lBody: TJSONObject;
  lResponse: TJSONObject;
begin
  try
    lUsuarioId := ObterUsuarioIdDaSessao(Req);

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

    lResponse := TFidelidadeService.AtualizarConsentimento(lUsuarioId, lBody);
    Res.Status(200).Send<TJSONObject>(lResponse);
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

procedure ResgatarFidelidade(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lUsuarioId: Integer;
  lBody: TJSONObject;
  lResponse: TJSONObject;
begin
  try
    lUsuarioId := ObterUsuarioIdDaSessao(Req);

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

    lResponse := TFidelidadeService.Resgatar(lUsuarioId, lBody);
    Res.Status(200).Send<TJSONObject>(lResponse);
  except
    on E: Exception do
    begin
      if E.Message = 'pontos_invalidos' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'PONTOS_INVALIDOS')
            .AddPair('message', 'Informe uma quantidade de pontos maior que zero.'))
      else
      if E.Message = 'pontos_insuficientes' then
        Res.Status(409).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'PONTOS_INSUFICIENTES')
            .AddPair('message', 'Saldo de pontos insuficiente para resgate.'))
      else
        Res.Status(500).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'ERRO_INTERNO')
            .AddPair('message', E.Message));
    end;
  end;
end;

end.
