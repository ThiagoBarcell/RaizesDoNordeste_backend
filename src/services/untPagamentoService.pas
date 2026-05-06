unit untPagamentoService;

interface

uses
  System.JSON,
  System.StrUtils,
  untLogService,
  untFidelidadeService;

type
  TPagamentoService = class
  private

  public

    class function SolicitarPagamento(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  untConnection,
  untPagamentoDAO,
  untConstantesGlobais;

class function TPagamentoService.SolicitarPagamento(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;
var
  lPedidoId: Integer;
  lAprovado: Boolean;
  lStatusAtual: string;
  lStatusPagamento: string;
  lStatusPedido: string;
  lValor: Double;
  lJSONRequisicao: TJSONObject;
  lJSONResposta: TJSONObject;
  lConnection: TFDConnection;
begin

  lPedidoId := pBody.GetValue<Integer>('pedidoId', 0);
  lAprovado := pBody.GetValue<Boolean>('aprovado', True);

  //Faz as validações padrões
  if pUsuarioId <= 0 then
    raise Exception.Create('usuario_invalido');

  if lPedidoId <= 0 then
    raise Exception.Create('pedido_obrigatorio');

  if not TPagamentoDAO.PedidoExiste(lPedidoId) then
    raise Exception.Create('pedido_nao_encontrado');

  if TPagamentoDAO.PagamentoExisteParaPedido(lPedidoId) then
    raise Exception.Create('pagamento_ja_registrado');

  lStatusAtual := TPagamentoDAO.ObterStatusPedido(lPedidoId);

  if lStatusAtual <> STATUS_PED_AGUARDANDO_PAGAMENTO then
    raise Exception.Create('pedido_nao_aguarda_pagamento');

  lValor := TPagamentoDAO.ObterTotalPedido(lPedidoId);

  if lAprovado then
  begin
    lStatusPagamento := STATUS_PAGAMENTO_APROVADO;
    lStatusPedido := STATUS_PED_PAGO;
  end
  else
  begin
    lStatusPagamento := STATUS_PAGAMENTO_RECUSADO;
    lStatusPedido := STATUS_PED_CANCELADO;
  end;

  lJSONRequisicao := TJSONObject.Create;
  lJSONResposta := TJSONObject.Create;

  try

    lJSONRequisicao.AddPair('pedidoId', TJSONNumber.Create(lPedidoId));
    lJSONRequisicao.AddPair('valor', TJSONNumber.Create(lValor));
    lJSONRequisicao.AddPair('provedor', AMB_MOCK);

    lJSONResposta.AddPair('provedor', AMB_MOCK);
    lJSONResposta.AddPair('status', lStatusPagamento);
    lJSONResposta.AddPair('mensagem', IfThen(lAprovado, 'Pagamento aprovado pelo mock.', 'Pagamento recusado pelo mock.'));

    lConnection := TConectarBD.GetConnection;
    lConnection.StartTransaction;
    try
      TPagamentoDAO.InserirPagamento( lPedidoId,lStatusPagamento,lValor,lJSONRequisicao.ToJSON,
        lJSONResposta.ToJSON,lConnection);

      TPagamentoDAO.AtualizarStatusPedido(lPedidoId,lStatusPedido,lConnection);

      lConnection.Commit;

      //Se o pagamento for aprovado e estiver tudo OK, gera o saldo fidelidade do cliente
      if lStatusPagamento = STATUS_PAGAMENTO_APROVADO then
        TFidelidadeService.CreditarPorPagamentoAprovado(pUsuarioId,lPedidoId,lValor);

      TLogService.GerarLog(pUsuarioId,'PROCESSAR_PAGAMENTO',ORI_PED_PEDIDO,
        lPedidoId,'Pagamento : ' + lStatusPagamento );
    except
      lConnection.Rollback;
      raise;
    end;

    Result := TJSONObject.Create;

    Result.AddPair('pedidoId', TJSONNumber.Create(lPedidoId));
    Result.AddPair('pagamentoStatus', lStatusPagamento);
    Result.AddPair('pedidoStatus', lStatusPedido);
    Result.AddPair('valor', TJSONNumber.Create(lValor));
    Result.AddPair('RetornoMock', lJSONResposta.Clone as TJSONValue);

  finally
    lJSONRequisicao.Free;
    lJSONResposta.Free;
  end;
end;

end.
