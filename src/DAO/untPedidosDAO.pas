unit untPedidosDAO;

interface


uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  untModeloItemPedido,
  System.JSON,
  FireDAC.Stan.Param,
  Data.DB;


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

    //Listagem de pedidos
    class function ListarPedidos( const pId: Integer;const pStatus, pCanalPedido: string ): TJSONArray;
    class function ListarItensPedido(const pPedidoId: Integer): TJSONArray;

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

class function TPedidoDAO.ListarItensPedido( const pPedidoId: Integer): TJSONArray;
var
  lQry: TFDQuery;
  lItem: TJSONObject;
begin
  Result := TJSONArray.Create;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;

    lQry.SQL.Text := ' SELECT pedido_itens.produto_id, produtos.nome AS produto, pedido_itens.quantidade, pedido_itens.preco_unitario ' +
      ' FROM pedido_itens pedido_itens ' +
      ' INNER JOIN produtos produtos ' +
      '   ON produtos.id = pedido_itens.produto_id ' +
      ' WHERE pedido_itens.pedido_id = :pedido_id ' +
      ' ORDER BY pedido_itens.id ';

    lQry.ParamByName('pedido_id').AsInteger := pPedidoId;
    lQry.Open;

    while not lQry.Eof do
    begin
      lItem := TJSONObject.Create;
      lItem.AddPair('produtoId', TJSONNumber.Create(lQry.FieldByName('produto_id').AsInteger));
      lItem.AddPair('produto', lQry.FieldByName('produto').AsString);
      lItem.AddPair('quantidade', TJSONNumber.Create(lQry.FieldByName('quantidade').AsInteger));
      lItem.AddPair('precoUnitario', TJSONNumber.Create(lQry.FieldByName('preco_unitario').AsFloat));

      Result.AddElement(lItem);

      lQry.Next;
    end;
  finally
    lQry.Free;
  end;
end;

class function TPedidoDAO.ListarPedidos(const pId: Integer; const pStatus,
  pCanalPedido: string): TJSONArray;
var
  lQry: TFDQuery;
  lPedido: TJSONObject;
begin
  Result := TJSONArray.Create;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;

    lQry.SQL.Clear;
    lQry.SQL.Text := ' SELECT id, usuario_id, unidade_id, canal_pedido, status, total, criado_em ' +
      ' FROM pedidos ' +
      ' WHERE 1=1 '; //To colocando esse where pra ficar mais facil pra so adicionar os ANDs

    if pId > 0 then
      lQry.SQL.Add('AND id = :id');

    if Trim(pStatus) <> '' then
      lQry.SQL.Add('AND status = :status');

    if Trim(pCanalPedido) <> '' then
      lQry.SQL.Add('AND canal_pedido = :canal_pedido');

    //To ordenando pelo ID do pedido de forma decrescente
    lQry.SQL.Add('ORDER BY id DESC');

    if pId > 0 then
      lQry.ParamByName('id').AsInteger := pId;

    if Trim(pStatus) <> '' then
      lQry.ParamByName('status').AsString := pStatus;

    if Trim(pCanalPedido) <> '' then
      lQry.ParamByName('canal_pedido').AsString := pCanalPedido;

    lQry.Open;

    while not lQry.Eof do
    begin
      //Monto do JSON com o Master e o detail neste ponto
      lPedido := TJSONObject.Create;
      lPedido.AddPair('id', TJSONNumber.Create(lQry.FieldByName('id').AsInteger));
      lPedido.AddPair('usuarioId', TJSONNumber.Create(lQry.FieldByName('usuario_id').AsInteger));
      lPedido.AddPair('unidadeId', TJSONNumber.Create(lQry.FieldByName('unidade_id').AsInteger));
      lPedido.AddPair('canalPedido', lQry.FieldByName('canal_pedido').AsString);
      lPedido.AddPair('status', lQry.FieldByName('status').AsString);
      lPedido.AddPair('total', TJSONNumber.Create(lQry.FieldByName('total').AsFloat));
      lPedido.AddPair('criadoEm', FormatDateTime('yyyy-mm-dd hh:nn:ss', lQry.FieldByName('criado_em').AsDateTime));

      lPedido.AddPair('itens', ListarItensPedido(lQry.FieldByName('id').AsInteger));

      Result.AddElement(lPedido);

      lQry.Next;
    end;
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
