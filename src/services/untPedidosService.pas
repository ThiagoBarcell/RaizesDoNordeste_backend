unit untPedidosService;

interface

uses
  System.JSON;

type
  TPedidoService = class

  public
    class function CriarPedido(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  untPedidosDAO,
  untConnection,
  untConstantesGlobais;

class function TPedidoService.CriarPedido(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;
var
  lUnidadeId: Integer;
  lCanalPedido: string;
  lItens: TJSONArray;
  lItem: TJSONValue;
  lItemObj: TJSONObject;
  lProdutoId: Integer;
  lQuantidade: Integer;
  lPrecoUnitario: Double;
  lEstoqueDisponivel: Integer;
  lTotal: Double;
  lPedidoId: Integer;
  lConnection: TFDConnection;
begin
  lUnidadeId := pBody.GetValue<Integer>('unidadeId', 0);
  lCanalPedido := Trim(UpperCase(pBody.GetValue<string>('canalPedido', '')));
  lItens := pBody.GetValue<TJSONArray>('itens');

  if (pUsuarioId <= 0) then
    raise Exception.Create('usuario_invalido');

  if (lUnidadeId <= 0) then
    raise Exception.Create('unidade_obrigatoria');

  if not (TPedidoDAO.UnidadeExiste(lUnidadeId)) then
    raise Exception.Create('unidade_nao_encontrada');

  //Verifica se está em algum canal de pedido cadastrado
  if not (lCanalPedido = CANAL_APP) and
    not (lCanalPedido = CANAL_TOTEM) and
    not (lCanalPedido = CANAL_WEB)
  then
    raise Exception.Create('canal_pedido_invalido');

  if (not Assigned(lItens)) or (lItens.Count = 0) then
    raise Exception.Create('itens_obrigatorios');

  lTotal := 0;

  //Esse for roda todo o array de itens que foi pego no body da requisição
  // e o lItem, seria o valor atual no for
  for lItem in lItens do
  begin
    lItemObj := lItem as TJSONObject;

    lProdutoId := lItemObj.GetValue<Integer>('produtoId', 0);
    lQuantidade := lItemObj.GetValue<Integer>('quantidade', 0);

    if lProdutoId <= 0 then
      raise Exception.Create('produto_invalido');

    if lQuantidade <= 0 then
      raise Exception.Create('quantidade_invalida');

    if not TPedidoDAO.ProdutoExiste(lProdutoId) then
      raise Exception.Create('produto_nao_encontrado');

    lEstoqueDisponivel := TPedidoDAO.ObterEstoque(lProdutoId, lUnidadeId);

    if lEstoqueDisponivel < lQuantidade then
      raise Exception.Create('estoque_insuficiente');

    lPrecoUnitario := TPedidoDAO.ObterPrecoProduto(lProdutoId);
    lTotal := lTotal + (lPrecoUnitario * lQuantidade);
  end;

  lConnection := TConectarBD.GetConnection;

  //Iniciei a transação para o cached update, caso de algo errado o rollback é geral
  lConnection.StartTransaction;
  try
    lPedidoId := TPedidoDAO.InserirPedido(pUsuarioId, lUnidadeId, lCanalPedido, lTotal, lConnection);

    for lItem in lItens do
    begin

      lItemObj := lItem as TJSONObject;

      lProdutoId := lItemObj.GetValue<Integer>('produtoId', 0);
      lQuantidade := lItemObj.GetValue<Integer>('quantidade', 0);
      lPrecoUnitario := TPedidoDAO.ObterPrecoProduto(lProdutoId);

      TPedidoDAO.InserirPedidoItem(lPedidoId, lProdutoId, lQuantidade, lPrecoUnitario, lConnection);
      //Aqui eu ajusto a diferença de estoque
      TPedidoDAO.BaixarEstoque(lProdutoId, lUnidadeId, lQuantidade, lConnection);
    end;

    lConnection.Commit;
  except
    lConnection.Rollback;
    raise;
  end;

  Result := TJSONObject.Create;
  Result.AddPair('pedidoId', TJSONNumber.Create(lPedidoId));
  Result.AddPair('status', 'AGUARDANDO_PAGAMENTO');
  Result.AddPair('canalPedido', lCanalPedido);
  Result.AddPair('total', TJSONNumber.Create(lTotal));
end;

end.
