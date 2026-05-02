unit untPedidosService;

interface

uses
  System.JSON, System.DateUtils;

type
  TPedidoService = class

  public
    class function CriarPedido(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;
    class function ListarPedido( const pId: Integer; const pStatus, pCanalPedido: string ): TJSONArray;
    class function AtualizarStatusPedido(const pUsuarioId: Integer;const pPedidoId: Integer;const pBody: TJSONObject): TJSONObject;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  untPedidosDAO,
  untConnection,
  untConstantesGlobais,
  untEstoqueDAO,
  untLogService;



class function TPedidoService.AtualizarStatusPedido(const pUsuarioId,pPedidoId: Integer; const pBody: TJSONObject): TJSONObject;
var
  lNovoStatus: string;
  lStatusAtual: string;
begin
  if pUsuarioId <= 0 then
    raise Exception.Create('usuario_invalido');

  if pPedidoId <= 0 then
    raise Exception.Create('pedido_invalido');

  lNovoStatus := Trim(UpperCase(pBody.GetValue<string>('status', '')));

  //Se existe o status digitado, seguindo os padrões que eu criei
  if (lNovoStatus <> STATUS_PED_AGUARDANDO_PAGAMENTO) and
     (lNovoStatus <> STATUS_PED_PAGO) and
     (lNovoStatus <> STATUS_PED_EM_PREPARO) and
     (lNovoStatus <> STATUS_PED_PRONTO) and
     (lNovoStatus <> STATUS_PED_ENTREGUE ) and
     (lNovoStatus <> STATUS_PED_CANCELADO)
  then
    raise Exception.Create('status_invalido');

  lStatusAtual := TPedidoDAO.ObterStatusPedidos(pPedidoId);

  if lStatusAtual = '' then
    raise Exception.Create('pedido_nao_encontrado');

  TPedidoDAO.AtualizarStatusPedidos(pPedidoId, lNovoStatus);

  TLogService.GerarLog(pUsuarioId,'ALTERAR_STATUS_PEDIDO',ORI_PED_PEDIDO,
  pPedidoId, 'De : ' + lStatusAtual + ', Para : ' + lNovoStatus);

  Result := TJSONObject.Create;

  Result.AddPair('pedidoId', TJSONNumber.Create(pPedidoId));
  Result.AddPair('statusAnterior', lStatusAtual);
  Result.AddPair('statusAtual', lNovoStatus);
end;

class function TPedidoService.CriarPedido(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;
var
  lUnidadeId, lQuantidadeAnterior, lQuantidadeAtual : Integer;
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

      //Aqui to fazendo o calculo do estoque com o anterior para gravar a movimentação
      lQuantidadeAnterior := TEstoqueDAO.ObterSaldo(lProdutoId, lUnidadeId);
      lQuantidadeAtual := lQuantidadeAnterior - lQuantidade;

      TEstoqueDAO.RegistrarMovimentacao( lProdutoId, lUnidadeId, pUsuarioId,
        MOV_TIPO_BAIXA_PEDIDO, ORI_PED_PEDIDO, lQuantidade, lQuantidadeAnterior, lQuantidadeAtual,
        'Baixa feita pelo pedido : ' + IntToStr(lPedidoId));
    end;

    lConnection.Commit;

    TLogService.GerarLog(pUsuarioId, 'CRIAR_PEDIDO',
     ORI_PED_PEDIDO,lPedidoId,'Pedido criado com total de : ' + FloatToStr(lTotal));

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

class function TPedidoService.ListarPedido(const pId: Integer; const pStatus,
  pCanalPedido: string): TJSONArray;
var
  lStatus: string;
  lCanalPedido: string;
begin
  lStatus := Trim(UpperCase(pStatus));
  lCanalPedido := Trim(UpperCase(pCanalPedido));

  //Se deixar vazio não passa nada pros filtros, mas se preencher segue o padrão
  if (lStatus <> '') and
     (lStatus <> STATUS_PED_AGUARDANDO_PAGAMENTO) and
     (lStatus <> STATUS_PED_PAGO) and
     (lStatus <> STATUS_PED_EM_PREPARO) and
     (lStatus <> STATUS_PED_PRONTO) and
     (lStatus <> STATUS_PED_ENTREGUE) and
     (lStatus <> STATUS_PED_CANCELADO)
  then
    raise Exception.Create('status_invalido');

  if (lCanalPedido <> '') and
     (lCanalPedido <> CANAL_TOTEM) and
     (lCanalPedido <> CANAL_WEB) and
     (lCanalPedido <> CANAL_APP)
  then
    raise Exception.Create('canal_pedido_invalido');

  Result := TPedidoDAO.ListarPedidos(pId, lStatus, lCanalPedido);
end;

end.
