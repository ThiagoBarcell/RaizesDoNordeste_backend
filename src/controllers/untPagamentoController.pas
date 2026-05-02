unit untPagamentoController;

interface

uses
  Horse;

procedure SolicitarPagamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.SysUtils,
  System.JSON,
  untPagamentoService;

procedure SolicitarPagamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lSession: TJSONObject;
  lUsuarioId: Integer;
  lBody: TJSONObject;
  lResponse: TJSONObject;
begin
  try
    lSession := Req.Session<TJSONObject>;

    if not Assigned(lSession) then
    begin
      Res.Status(401).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'TOKEN_INVALIDO')
          .AddPair('message', 'JWT não encontrado na sessão.'));
      Exit;
    end;

    lUsuarioId := StrToIntDef(lSession.GetValue<string>('sub', ''), 0);

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

    lResponse := TPagamentoService.SolicitarPagamento(lUsuarioId, lBody);
    Res.Status(201).Send<TJSONObject>(lResponse);

  except

    on E: Exception do
    begin
      if E.Message = 'pedido_obrigatorio' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'PEDIDO_OBRIGATORIO')
            .AddPair('message', 'O campo pedidoId é obrigatório.'))
      else
      if E.Message = 'pedido_nao_encontrado' then
        Res.Status(404).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'PEDIDO_NAO_ENCONTRADO')
            .AddPair('message', 'Pedido não encontrado.'))
      else
      if E.Message = 'pagamento_ja_registrado' then
        Res.Status(409).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'PAGAMENTO_JA_REGISTRADO')
            .AddPair('message', 'Já existe pagamento registrado para este pedido.'))
      else
      if E.Message = 'pedido_nao_aguarda_pagamento' then
        Res.Status(409).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'PEDIDO_NAO_AGUARDA_PAGAMENTO')
            .AddPair('message', 'O pedido não está aguardando pagamento.'))
      else
        Res.Status(500).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'ERRO_INTERNO')
            .AddPair('message', E.Message));
    end;
  end;
end;

end.
