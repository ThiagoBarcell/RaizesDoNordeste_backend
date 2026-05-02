unit untPagamentoDAO;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB;

type
  TPagamentoDAO = class
  public
    class function PedidoExiste(const pPedidoId: Integer): Boolean;
    class function ObterStatusPedido(const pPedidoId: Integer): string;
    class function ObterTotalPedido(const pPedidoId: Integer): Double;
    class function PagamentoExisteParaPedido(const pPedidoId: Integer): Boolean;
    class procedure InserirPagamento( const pPedidoId: Integer; const pStatus: string;const pValor: Double;
      const pPayloadRequisicao: string;const pPayloadResposta: string; const pConnection: TFDConnection);
    class procedure AtualizarStatusPedido(const pPedidoId: Integer;const pStatus: string;const pConnection: TFDConnection);
  end;

implementation

uses
  FireDAC.DApt,
  untConnection;

class function TPagamentoDAO.PedidoExiste(const pPedidoId: Integer): Boolean;
var
  lQry: TFDQuery;
begin
  Result := False;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text := 'SELECT 1 FROM pedidos WHERE id = :id LIMIT 1';
    lQry.ParamByName('id').AsInteger := pPedidoId;
    lQry.Open;

    Result := not lQry.IsEmpty;
  finally
    lQry.Free;
  end;
end;

class function TPagamentoDAO.ObterStatusPedido(const pPedidoId: Integer): string;
var
  lQry: TFDQuery;
begin
  Result := '';

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text := 'SELECT status FROM pedidos WHERE id = :id';
    lQry.ParamByName('id').AsInteger := pPedidoId;
    lQry.Open;

    if not lQry.IsEmpty then
      Result := lQry.FieldByName('status').AsString;
  finally
    lQry.Free;
  end;
end;

class function TPagamentoDAO.ObterTotalPedido(const pPedidoId: Integer): Double;
var
  lQry: TFDQuery;
begin
  Result := 0;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text := 'SELECT total FROM pedidos WHERE id = :id';
    lQry.ParamByName('id').AsInteger := pPedidoId;
    lQry.Open;

    if not lQry.IsEmpty then
      Result := lQry.FieldByName('total').AsFloat;
  finally
    lQry.Free;
  end;
end;

class function TPagamentoDAO.PagamentoExisteParaPedido(const pPedidoId: Integer): Boolean;
var
  lQry: TFDQuery;
begin
  Result := False;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text := 'SELECT 1 FROM pagamentos WHERE pedido_id = :pedido_id LIMIT 1';
    lQry.ParamByName('pedido_id').AsInteger := pPedidoId;
    lQry.Open;

    Result := not lQry.IsEmpty;
  finally
    lQry.Free;
  end;
end;

//To chamando a conection por fora pois em alguns pontos eu uso cached Update
class procedure TPagamentoDAO.InserirPagamento( const pPedidoId: Integer;const pStatus: string;const pValor: Double;
  const pPayloadRequisicao: string;const pPayloadResposta: string;const pConnection: TFDConnection );
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := pConnection;
    lQry.SQL.Text :=
      'INSERT INTO pagamentos ' +
      '(pedido_id, status, valor, payload_requisicao, payload_resposta) ' +
      'VALUES ' +
      '(:pedido_id, :status, :valor, :payload_requisicao, :payload_resposta)';

    lQry.ParamByName('pedido_id').AsInteger := pPedidoId;

    lQry.ParamByName('status').AsString := pStatus;
    lQry.ParamByName('valor').AsFloat := pValor;
    lQry.ParamByName('payload_requisicao').AsString := pPayloadRequisicao;
    lQry.ParamByName('payload_resposta').AsString := pPayloadResposta;

    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

class procedure TPagamentoDAO.AtualizarStatusPedido(const pPedidoId: Integer;const pStatus: string;const pConnection: TFDConnection);
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := pConnection;
    lQry.SQL.Text :=
      'UPDATE pedidos ' +
      'SET status = :status ' +
      'WHERE id = :id';

    lQry.ParamByName('id').AsInteger := pPedidoId;
    lQry.ParamByName('status').AsString := pStatus;

    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

end.
