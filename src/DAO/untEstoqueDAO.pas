unit untEstoqueDAO;

interface

uses
  System.JSON,
  FireDAC.Comp.Client;

type

  TEstoqueDAO = class

  public
    class function Listar(const pProdutoId, pUnidadeId: Integer): TJSONArray;
    class function ObterSaldo( const pProdutoId, pUnidadeId: Integer;const pConnection: TFDConnection = nil): Integer;

    class procedure AtualizarSaldo(const pProdutoId, pUnidadeId, pQuantidadeAtual: Integer);
    class procedure RegistrarMovimentacao(const pProdutoId, pUnidadeId, pUsuarioId: Integer;const pTipo, pOrigem: string;
      const pQuantidade, pQuantidadeAnterior, pQuantidadeAtual: Integer;const pObservacao: string);
  end;

implementation

uses
  System.SysUtils,
  FireDAC.DApt,
  untConnection;

class function TEstoqueDAO.Listar(const pProdutoId, pUnidadeId: Integer): TJSONArray;
var
  lQry: TFDQuery;
  lItem: TJSONObject;
begin
  Result := TJSONArray.Create;
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;

    lQry.SQL.Clear;
    lQry.SQL.Text := ' SELECT e.produto_id, p.nome AS produto, e.unidade_id, u.nome AS unidade, e.quantidade ' +
      ' FROM estoque e ' +
      ' INNER JOIN produtos p ' +
      ' ON p.id = e.produto_id ' +
      ' INNER JOIN unidades u ' +
      ' ON u.id = e.unidade_id ' +
      ' WHERE 1=1 ';

    if (pProdutoId > 0 )then
      lQry.SQL.Add(' AND e.produto_id = :produto_id ');

    if (pUnidadeId > 0) then
      lQry.SQL.Add(' AND e.unidade_id = :unidade_id ');

    lQry.SQL.Add(' ORDER BY u.nome, p.nome ');

    if (pProdutoId > 0) then
      lQry.ParamByName(' produto_id ').AsInteger := pProdutoId;

    if (pUnidadeId > 0) then
      lQry.ParamByName(' unidade_id ').AsInteger := pUnidadeId;
    lQry.Open;

    while not lQry.Eof do
    begin

      lItem := TJSONObject.Create;

      lItem.AddPair('produtoId', TJSONNumber.Create(lQry.FieldByName('produto_id').AsInteger));
      lItem.AddPair('produto', lQry.FieldByName('produto').AsString);
      lItem.AddPair('unidadeId', TJSONNumber.Create(lQry.FieldByName('unidade_id').AsInteger));
      lItem.AddPair('unidade', lQry.FieldByName('unidade').AsString);
      lItem.AddPair('quantidade', TJSONNumber.Create(lQry.FieldByName('quantidade').AsInteger));

      Result.AddElement(lItem);
      lQry.Next;
    end;
  finally
    lQry.Free;
  end;
end;

class function TEstoqueDAO.ObterSaldo(const pProdutoId, pUnidadeId: Integer;
  const pConnection: TFDConnection): Integer;
var
  lQry: TFDQuery;
begin
  Result := 0;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;


    lQry.SQL.Text :=
      ' SELECT quantidade ' +
      ' FROM estoque ' +
      ' WHERE produto_id = :produto_id ' +
      ' AND unidade_id = :unidade_id';

    lQry.ParamByName('produto_id').AsInteger := pProdutoId;
    lQry.ParamByName('unidade_id').AsInteger := pUnidadeId;
    lQry.Open;

    if not lQry.IsEmpty then
      Result := lQry.FieldByName('quantidade').AsInteger;
  finally
    lQry.Free;
  end;
end;

class procedure TEstoqueDAO.AtualizarSaldo( const pProdutoId, pUnidadeId, pQuantidadeAtual: Integer);
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try

    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Clear;
    lQry.SQL.Text :=
      'UPDATE estoque ' +
      'SET quantidade = :quantidade ' +
      'WHERE produto_id = :produto_id ' +
      'AND unidade_id = :unidade_id';

    lQry.ParamByName('quantidade').AsInteger := pQuantidadeAtual;
    lQry.ParamByName('produto_id').AsInteger := pProdutoId;
    lQry.ParamByName('unidade_id').AsInteger := pUnidadeId;
    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

class procedure TEstoqueDAO.RegistrarMovimentacao( const pProdutoId, pUnidadeId, pUsuarioId: Integer;
  const pTipo, pOrigem: string;
  const pQuantidade, pQuantidadeAnterior, pQuantidadeAtual: Integer;const pObservacao: string );
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;

    lQry.SQL.Text :=
      'INSERT INTO estoque_movimentacoes ' +
      '(produto_id, unidade_id, usuario_id, tipo, origem, quantidade, quantidade_anterior, quantidade_atual, observacao) ' +
      'VALUES ' +
      '(:produto_id, :unidade_id, :usuario_id, :tipo, :origem, :quantidade, :quantidade_anterior, :quantidade_atual, :observacao)';

    lQry.ParamByName('produto_id').AsInteger := pProdutoId;
    lQry.ParamByName('unidade_id').AsInteger := pUnidadeId;
    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.ParamByName('tipo').AsString := pTipo;
    lQry.ParamByName('origem').AsString := pOrigem;
    lQry.ParamByName('quantidade').AsInteger:= pQuantidade;
    lQry.ParamByName('quantidade_anterior').AsInteger:= pQuantidadeAnterior;
    lQry.ParamByName('quantidade_atual').AsInteger:= pQuantidadeAtual;
    lQry.ParamByName('observacao').AsString:= pObservacao;

    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

end.
