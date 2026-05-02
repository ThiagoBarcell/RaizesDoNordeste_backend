unit untEstoqueService;

interface

uses
  System.JSON, untLogService;

type
  TEstoqueService = class
  public
    class function ListarEstoque(const pProdutoId, pUnidadeId: Integer): TJSONArray;
    class function MovimentarEstoque(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  untConnection,
  untEstoqueDAO,
  untPedidosDAO,
  untConstantesGlobais;

class function TEstoqueService.ListarEstoque(const pProdutoId, pUnidadeId: Integer): TJSONArray;
begin
  Result := TEstoqueDAO.Listar(pProdutoId, pUnidadeId);
end;

class function TEstoqueService.MovimentarEstoque(const pUsuarioId: Integer; const pBody: TJSONObject): TJSONObject;
var
  lProdutoId: Integer;
  lUnidadeId: Integer;
  lQuantidade: Integer;
  lQuantidadeAnterior: Integer;
  lQuantidadeAtual: Integer;
  lTipo: string;
  lObservacao: string;
begin

  lProdutoId := pBody.GetValue<Integer>( 'produtoId', 0 );
  lUnidadeId := pBody.GetValue<Integer>( 'unidadeId', 0 ) ;
  lTipo := Trim(UpperCase(pBody.GetValue<string>( 'tipo', '' ) ) );
  lQuantidade := pBody.GetValue<Integer>( 'quantidade', 0);
  lObservacao := Trim(pBody.GetValue<string>( 'observacao', '' ) );

  if ( pUsuarioId <= 0 )then
    raise Exception.Create('usuario_invalido');

  if ( lProdutoId <= 0 ) then
    raise Exception.Create('produto_obrigatorio');

  if ( lUnidadeId <= 0 ) then
    raise Exception.Create('unidade_obrigatoria');

  //Uso os metodos ja existentes pra validações simples
  if not TPedidoDAO.ProdutoExiste(lProdutoId) then
    raise Exception.Create('produto_nao_encontrado');

  if not TPedidoDAO.UnidadeExiste(lUnidadeId) then
    raise Exception.Create('unidade_nao_encontrada');

  if lQuantidade <= 0 then
    raise Exception.Create('quantidade_invalida');

  if (lTipo <> MOV_TIPO_ENTRADA) and
     (lTipo <> MOV_TIPO_SAIDA) and
     (lTipo <> MOV_TIPO_AJUSTE)
  then
    raise Exception.Create('tipo_movimentacao_invalido');

  try
    lQuantidadeAnterior := TEstoqueDAO.ObterSaldo(lProdutoId, lUnidadeId);

    if lTipo = MOV_TIPO_ENTRADA then
      lQuantidadeAtual := lQuantidadeAnterior + lQuantidade
    else
    if lTipo = MOV_TIPO_SAIDA then
    begin
      if lQuantidadeAnterior < lQuantidade then
        raise Exception.Create('estoque_insuficiente');

      lQuantidadeAtual := lQuantidadeAnterior - lQuantidade;
    end
    else
      lQuantidadeAtual := lQuantidade;

    TEstoqueDAO.AtualizarSaldo( lProdutoId, lUnidadeId, lQuantidadeAtual );

    TEstoqueDAO.RegistrarMovimentacao( lProdutoId, lUnidadeId, pUsuarioId,lTipo,
      ORI_PED_MANUAL,lQuantidade, lQuantidadeAnterior,lQuantidadeAtual,  lObservacao);

    TLogService.GerarLog(pUsuarioId,'MOVIMENTAR_ESTOQUE', 'ESTOQUE',
      lProdutoId, lTipo + ' ; Quantidade : ' + IntToStr(lQuantidade));

  except
    raise;
  end;

  Result := TJSONObject.Create;
  Result.AddPair('produtoId', TJSONNumber.Create(lProdutoId));
  Result.AddPair('unidadeId', TJSONNumber.Create(lUnidadeId));
  Result.AddPair('tipo', lTipo);
  Result.AddPair('quantidade', TJSONNumber.Create(lQuantidade));
  Result.AddPair('quantidadeAnterior', TJSONNumber.Create(lQuantidadeAnterior));
  Result.AddPair('quantidadeAtual', TJSONNumber.Create(lQuantidadeAtual));
  Result.AddPair('observacao', lObservacao);
end;

end.
