unit untFidelidadeDAO;

interface

uses
  System.JSON,
  FireDAC.Comp.Client;

type
  TFidelidadeDAO = class
  public

    class function RegistroExiste(const pUsuarioId: Integer): Boolean;
    class procedure CriarRegistroSeNaoExistir( const pUsuarioId: Integer);
    class function BuscarSaldo(const pUsuarioId: Integer): TJSONObject;
    class function TemConsentimento(const pUsuarioId: Integer): Boolean;
    class procedure AtualizarConsentimento(const pUsuarioId: Integer;const pConsentimento: Boolean);
    class procedure CreditarPontos(const pUsuarioId: Integer; const pPontos: Integer; const pDescricao: string);
    class procedure ResgatarPontos(const pUsuarioId: Integer;const pPontos: Integer;const pDescricao: string);
    class function ListarHistorico(const pUsuarioId: Integer): TJSONArray;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.DApt,
  untConnection;

class function TFidelidadeDAO.RegistroExiste(const pUsuarioId: Integer): Boolean;
var
  lQry: TFDQuery;
begin
  Result := False;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Clear;
    lQry.SQL.Text := 'SELECT 1 FROM fidelidade WHERE usuario_id = :usuario_id LIMIT 1';
    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.Open;

    Result := not lQry.IsEmpty;
  finally
    lQry.Free;
  end;
end;

class procedure TFidelidadeDAO.CriarRegistroSeNaoExistir( const pUsuarioId: Integer);
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Clear;
    lQry.SQL.Text := 'INSERT INTO fidelidade (usuario_id, pontos, consentimento) ' +
      'VALUES (:usuario_id, 0, false) ' +
      'ON CONFLICT (usuario_id) DO NOTHING';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

class function TFidelidadeDAO.BuscarSaldo(const pUsuarioId: Integer): TJSONObject;
var
  lQry: TFDQuery;
begin
  Result := TJSONObject.Create;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;

    lQry.SQL.Clear;

    lQry.SQL.Text := 'SELECT usuario_id, pontos, consentimento, atualizado_em ' +
      'FROM fidelidade ' +
      'WHERE usuario_id = :usuario_id';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.Open;

    if lQry.IsEmpty then
    begin
      Result.AddPair('usuarioId', TJSONNumber.Create(pUsuarioId));
      Result.AddPair('pontos', TJSONNumber.Create(0));
      Result.AddPair('consentimento', TJSONBool.Create(False));
      Result.AddPair('historico', ListarHistorico(pUsuarioId));
      Exit;
    end;

    Result.AddPair('usuarioId', TJSONNumber.Create(lQry.FieldByName('usuario_id').AsInteger));
    Result.AddPair('pontos', TJSONNumber.Create(lQry.FieldByName('pontos').AsInteger));
    Result.AddPair('consentimento', TJSONBool.Create(lQry.FieldByName('consentimento').AsBoolean));
    Result.AddPair('atualizadoEm', FormatDateTime('yyyy-mm-dd hh:nn:ss', lQry.FieldByName('atualizado_em').AsDateTime));
    Result.AddPair('historico', ListarHistorico(pUsuarioId));
  finally
    lQry.Free;
  end;
end;

class function TFidelidadeDAO.TemConsentimento( const pUsuarioId: Integer): Boolean;
var
  lQry: TFDQuery;
begin
  Result := False;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Clear;
    lQry.SQL.Text := 'SELECT consentimento ' +
      'FROM fidelidade ' +
      'WHERE usuario_id = :usuario_id';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.Open;

    if not lQry.IsEmpty then
      Result := lQry.FieldByName('consentimento').AsBoolean;
  finally
    lQry.Free;
  end;
end;

class procedure TFidelidadeDAO.AtualizarConsentimento(const pUsuarioId: Integer;const pConsentimento: Boolean);
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Clear;
    lQry.SQL.Text := 'UPDATE fidelidade ' +
      'SET consentimento = :consentimento, atualizado_em = CURRENT_TIMESTAMP ' +
      'WHERE usuario_id = :usuario_id';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.ParamByName('consentimento').AsBoolean := pConsentimento;
    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

class procedure TFidelidadeDAO.CreditarPontos(const pUsuarioId: Integer;const pPontos: Integer;const pDescricao: string);
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;

    lQry.SQL.Clear;
    lQry.SQL.Text := 'UPDATE fidelidade ' +
      'SET pontos = pontos + :pontos, atualizado_em = CURRENT_TIMESTAMP ' +
      'WHERE usuario_id = :usuario_id';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.ParamByName('pontos').AsInteger := pPontos;
    lQry.ExecSQL;

    lQry.SQL.Text :='INSERT INTO fidelidade_historico (usuario_id, tipo, pontos, descricao) ' +
      'VALUES (:usuario_id, :tipo, :pontos, :descricao)';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.ParamByName('tipo').AsString := 'CREDITO';
    lQry.ParamByName('pontos').AsInteger := pPontos;
    lQry.ParamByName('descricao').AsString := pDescricao;
    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

class procedure TFidelidadeDAO.ResgatarPontos(const pUsuarioId: Integer;const pPontos: Integer;const pDescricao: string);
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Clear;
    lQry.SQL.Text :=
      'UPDATE fidelidade ' +
      'SET pontos = pontos - :pontos, atualizado_em = CURRENT_TIMESTAMP ' +
      'WHERE usuario_id = :usuario_id';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.ParamByName('pontos').AsInteger := pPontos;
    lQry.ExecSQL;

    lQry.SQL.Clear;
    lQry.SQL.Text :=
      'INSERT INTO fidelidade_historico (usuario_id, tipo, pontos, descricao) ' +
      'VALUES (:usuario_id, :tipo, :pontos, :descricao)';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.ParamByName('tipo').AsString := 'RESGATE';
    lQry.ParamByName('pontos').AsInteger := pPontos;
    lQry.ParamByName('descricao').AsString := pDescricao;
    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

class function TFidelidadeDAO.ListarHistorico(const pUsuarioId: Integer): TJSONArray;
var
  lQry: TFDQuery;
  lItem: TJSONObject;
begin
  Result := TJSONArray.Create;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Clear;
    lQry.SQL.Text :=
      'SELECT id, tipo, pontos, descricao, criado_em ' +
      'FROM fidelidade_historico ' +
      'WHERE usuario_id = :usuario_id ' +
      'ORDER BY criado_em DESC';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.Open;

    while not lQry.Eof do
    begin
      lItem := TJSONObject.Create;
      lItem.AddPair('id', TJSONNumber.Create(lQry.FieldByName('id').AsInteger));
      lItem.AddPair('tipo', lQry.FieldByName('tipo').AsString);
      lItem.AddPair('pontos', TJSONNumber.Create(lQry.FieldByName('pontos').AsInteger));
      lItem.AddPair('descricao', lQry.FieldByName('descricao').AsString);
      lItem.AddPair('criadoEm', FormatDateTime('yyyy-mm-dd hh:nn:ss', lQry.FieldByName('criado_em').AsDateTime));

      Result.AddElement(lItem);
      lQry.Next;
    end;
  finally
    lQry.Free;
  end;
end;

end.
