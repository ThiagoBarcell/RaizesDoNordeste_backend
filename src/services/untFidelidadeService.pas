unit untFidelidadeService;

interface

uses
  System.JSON;

type
  TFidelidadeService = class
  public

    class function Consultar(const pUsuarioId: Integer): TJSONObject;
    class function AtualizarConsentimento(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;
    class function Resgatar(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;

    class procedure CreditarPorPagamentoAprovado(const pUsuarioId: Integer;const pPedidoId: Integer;const pValor: Double);
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  FireDAC.Comp.Client,
  untConnection,
  untFidelidadeDAO,
  untLogService;

class function TFidelidadeService.Consultar(const pUsuarioId: Integer): TJSONObject;
begin
  if pUsuarioId <= 0 then
    raise Exception.Create('usuario_invalido');
  try
    TFidelidadeDAO.CriarRegistroSeNaoExistir(pUsuarioId);

  except
    raise Exception.Create('não_foi_possível_cadastrar_fidelidade_verifique_o_cadastro');
  end;

  Result := TFidelidadeDAO.BuscarSaldo(pUsuarioId);
end;

class function TFidelidadeService.AtualizarConsentimento(const pUsuarioId: Integer;const pBody: TJSONObject): TJSONObject;
var
  lConsentimento: Boolean;
begin
  if pUsuarioId <= 0 then
    raise Exception.Create('usuario_invalido');

  lConsentimento := pBody.GetValue<Boolean>('consentimento', False);
  try
    TFidelidadeDAO.CriarRegistroSeNaoExistir(pUsuarioId);

    TFidelidadeDAO.AtualizarConsentimento(pUsuarioId,lConsentimento);

    TLogService.GerarLog(pUsuarioId,'ATUALIZAR_CONSENTIMENTO_FIDELIDADE',
      'FIDELIDADE',pUsuarioId,'Consentimento alterado para: ' + BoolToStr(lConsentimento, True));
  except
    raise Exception.Create('erro_ao_atualizar_consentimento');
  end;

  Result := TJSONObject.Create;
  Result.AddPair('usuarioId', TJSONNumber.Create(pUsuarioId));
  Result.AddPair('consentimento', TJSONBool.Create(lConsentimento));
end;

class function TFidelidadeService.Resgatar(const pUsuarioId: Integer;const pBody: TJSONObject): TJSONObject;
var
  lPontos: Integer;
  lSaldoAtual: TJSONObject;
  lSaldoPontos: Integer;
begin
  if pUsuarioId <= 0 then
    raise Exception.Create('usuario_invalido');

  lPontos := pBody.GetValue<Integer>('pontos', 0);

  if lPontos <= 0 then
    raise Exception.Create('pontos_invalidos');

  try
    TFidelidadeDAO.CriarRegistroSeNaoExistir(pUsuarioId);

    lSaldoAtual := TFidelidadeDAO.BuscarSaldo(pUsuarioId);
    try
      lSaldoPontos := lSaldoAtual.GetValue<Integer>('pontos', 0);
    finally
      lSaldoAtual.Free;
    end;

    if lSaldoPontos < lPontos then
      raise Exception.Create('pontos_insuficientes');

    TFidelidadeDAO.ResgatarPontos(pUsuarioId,lPontos,'Resgate manual de pontos');

    TLogService.GerarLog(pUsuarioId,'RESGATAR_PONTOS','FIDELIDADE',pUsuarioId,
      'Resgate de ' + IntToStr(lPontos) + ' pontos');

  except
    raise
  end;

  Result := TJSONObject.Create;
  Result.AddPair('usuarioId', TJSONNumber.Create(pUsuarioId));
  Result.AddPair('pontosResgatados', TJSONNumber.Create(lPontos));
end;

class procedure TFidelidadeService.CreditarPorPagamentoAprovado(const pUsuarioId: Integer;const pPedidoId: Integer;const pValor: Double);
var
  lPontos: Integer;
begin
  if pUsuarioId <= 0 then
    Exit;

  lPontos := Floor(pValor);

  if lPontos <= 0 then
    Exit;

  try
    TFidelidadeDAO.CriarRegistroSeNaoExistir(pUsuarioId);

    if TFidelidadeDAO.TemConsentimento(pUsuarioId) then
    begin
      TFidelidadeDAO.CreditarPontos(pUsuarioId,lPontos,'Crédito gerado pelo pagamento aprovado do pedido ' + IntToStr(pPedidoId));

      TLogService.GerarLog(pUsuarioId,'CREDITAR_PONTOS','FIDELIDADE',pUsuarioId,
        'Crédito de ' + IntToStr(lPontos) + ' pontos pelo pedido ' + IntToStr(pPedidoId));
    end;
  except
    raise Exception.Create('nao_foi_possivel_creditar_pontos_fdl');
  end;
end;

end.
