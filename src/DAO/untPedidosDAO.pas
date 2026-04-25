unit untPedidosDAO;

interface


uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  untModeloItemPedido;


type
  TPedidoDAO = class
  public
    //Metodos Uteis para a validação do pedido
    //Criei esse para não ter erro ao procurar a unidade que está emitindo pedido
    class function UnidadeExiste(const pUnidadeId: Integer): Boolean;
    class function ProdutoExiste(const pProdutoId: Integer): Boolean;
    class function ObterPrecoProduto(const pProdutoId: Integer): Double;

    class function ObterEstoque(const pProdutoId, pUnidadeId: Integer): Integer;

    class function InserirPedido( const pUsuarioId, pUnidadeId: Integer; const pCanalPedido: string;
      const pTotal: Double; const pConnection: TFDConnection): Integer;

    class procedure InserirPedidoItem( const pPedidoId, pProdutoId, pQuantidade: Integer;
      const pPrecoUnitario: Double; const pConnection: TFDConnection );

    class procedure BaixarEstoque( const pProdutoId, pUnidadeId, pQuantidade: Integer;
      const pConnection: TFDConnection );
  end;

implementation

uses
  FireDAC.DApt,
  System.SysUtils,
  untConnection,
  untConstantesGlobais;

class function TPedidoDAO.UnidadeExiste(const pUnidadeId: Integer): Boolean;
var
  lQry: TFDQuery;
begin
  Result := False;

  lQry := TFDQuery.Create(nil);

  try

    //Select simples só pra validar se tem mesmo a unidade
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text := 'SELECT 1 FROM unidades WHERE id = :id LIMIT 1';
    lQry.ParamByName('id').AsInteger := pUnidadeId; //Usando sempre o ID dela como parametro
    lQry.Open;
    Result := not lQry.IsEmpty;
  finally
    lQry.Free;
  end;
end;

//Crie essa validação pra encontrar o item no BD e se preciso retornar mais dados dele
class function TPedidoDAO.ProdutoExiste(const pProdutoId: Integer): Boolean;
var
  lQry: TFDQuery;
begin
  Result := False;

  lQry := TFDQuery.Create(nil);

  try
    lQry.Connection := TConectarBD.GetConnection;
    //Deixei pra trazer só 1 registro
    lQry.SQL.Text := 'SELECT 1 FROM produtos WHERE id = :id LIMIT 1';
    lQry.ParamByName('id').AsInteger := pProdutoId;
    lQry.Open;
    Result := not lQry.IsEmpty;
  finally
    lQry.Free;
  end;
end;

//Fiz essa rota pra retornar so o preço, se for pra usar em outros lugares e mais rapido
class function TPedidoDAO.ObterPrecoProduto(const pProdutoId: Integer): Double;
var
  lQry: TFDQuery;
begin
  Result := 0;

  lQry := TFDQuery.Create(nil);
  try

    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text := 'SELECT preco FROM produtos WHERE id = :id';
    lQry.ParamByName('id').AsInteger := pProdutoId;
    lQry.Open;

    if not lQry.IsEmpty then
      Result := lQry.FieldByName('preco').AsFloat;

  finally
    lQry.Free;
  end;
end;

class function TPedidoDAO.ObterEstoque(const pProdutoId, pUnidadeId: Integer): Integer;
var
  lQry: TFDQuery;
begin
  Result := 0;

  lQry := TFDQuery.Create(nil);
  try

    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text :=
      'SELECT quantidade ' +
      'FROM estoque ' +
      'WHERE produto_id = :produto_id ' +
      '  AND unidade_id = :unidade_id';
    lQry.ParamByName('produto_id').AsInteger := pProdutoId;
    lQry.ParamByName('unidade_id').AsInteger := pUnidadeId;
    lQry.Open;

    if not lQry.IsEmpty then
      Result := lQry.FieldByName('quantidade').AsInteger;

  finally
    lQry.Free;
  end;
end;


class function TPedidoDAO.InserirPedido(   const pUsuarioId, pUnidadeId: Integer; const pCanalPedido: string;
  const pTotal: Double; const pConnection: TFDConnection ): Integer;
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try

    lQry.Connection := pConnection;
    lQry.SQL.Text :=
      'INSERT INTO pedidos (usuario_id, unidade_id, canal_pedido, status, total) ' +
      'VALUES (:usuario_id, :unidade_id, :canal_pedido, :status, :total) ' +
      'RETURNING id';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.ParamByName('unidade_id').AsInteger := pUnidadeId;
    lQry.ParamByName('canal_pedido').AsString := pCanalPedido;
    lQry.ParamByName('status').AsString := STATUS_PED_AGUARDANDO_PAGAMENTO; //Status padrão pro pedido que foi criado agora
    lQry.ParamByName('total').AsFloat := pTotal;

    lQry.Open;
    Result := lQry.FieldByName('id').AsInteger;
  finally
    lQry.Free;
  end;
end;

class procedure TPedidoDAO.InserirPedidoItem( const pPedidoId, pProdutoId, pQuantidade: Integer;
  const pPrecoUnitario: Double; const pConnection: TFDConnection);
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try

    lQry.Connection := pConnection;
    lQry.SQL.Text :=
      'INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario) ' +
      'VALUES (:pedido_id, :produto_id, :quantidade, :preco_unitario)';

    lQry.ParamByName('pedido_id').AsInteger := pPedidoId;
    lQry.ParamByName('produto_id').AsInteger := pProdutoId;
    lQry.ParamByName('quantidade').AsInteger := pQuantidade;
    lQry.ParamByName('preco_unitario').AsFloat := pPrecoUnitario;

    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

//Esse método ajusta o estoque pros pedidos, saiu pedido, tira a quantidade
class procedure TPedidoDAO.BaixarEstoque( const pProdutoId, pUnidadeId, pQuantidade: Integer;
  const pConnection: TFDConnection );
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := pConnection;
    lQry.SQL.Text :=
      'UPDATE estoque ' +
      'SET quantidade = quantidade - :quantidade ' +
      'WHERE produto_id = :produto_id ' +
      '  AND unidade_id = :unidade_id';

    lQry.ParamByName('quantidade').AsInteger := pQuantidade;
    lQry.ParamByName('produto_id').AsInteger := pProdutoId;
    lQry.ParamByName('unidade_id').AsInteger := pUnidadeId;

    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

end.
