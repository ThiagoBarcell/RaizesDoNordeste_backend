unit untPedidosController;

interface

uses
  Horse;

procedure CriarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.JSON,
  System.SysUtils,
  JOSE.Core.JWT,
  untPedidosService;

procedure CriarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lUsuarioId: Integer;
  lBody: TJSONObject;
  lResponse: TJSONObject;
begin
  try
    lUsuarioId := StrToIntDef(Req.Session<TJWT>.Claims.Subject, 0);

    if lUsuarioId = 0 then
    begin
      Res.Status(401).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'TOKEN_INVALIDO')
          .AddPair('message', 'Token inválido ou sem usuário.') );
      Exit;
    end;

    lBody := Req.Body<TJSONObject>;

    if not Assigned(lBody) then
    begin
      Res.Status(400).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'BODY_INVALIDO')
          .AddPair('message', 'Body da requisição inválido.'));
      Exit;
    end;

    lResponse := TPedidoService.CriarPedido(lUsuarioId, lBody);
    Res.Status(201).Send<TJSONObject>(lResponse);

  except
    on E: Exception do
    begin
      if E.Message = 'unidade_obrigatoria' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'UNIDADE_OBRIGATORIA')
                           .AddPair('message', 'O campo unidadeId é obrigatório.')
        )
      else if E.Message = 'unidade_nao_encontrada' then
        Res.Status(404).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'UNIDADE_NAO_ENCONTRADA')
                           .AddPair('message', 'Unidade não encontrada.')
        )
      else if E.Message = 'canal_pedido_invalido' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'CANAL_PEDIDO_INVALIDO')
                           .AddPair('message', 'Use APP, TOTEM, BALCAO, PICKUP ou WEB.')
        )
      else if E.Message = 'itens_obrigatorios' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'ITENS_OBRIGATORIOS')
                           .AddPair('message', 'Informe ao menos um item no pedido.')
        )
      else if E.Message = 'produto_nao_encontrado' then
        Res.Status(404).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'PRODUTO_NAO_ENCONTRADO')
                           .AddPair('message', 'Um dos produtos informados não existe.')
        )
      else if E.Message = 'estoque_insuficiente' then
        Res.Status(409).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'ESTOQUE_INSUFICIENTE')
                           .AddPair('message', 'Não há estoque suficiente para um ou mais itens.')
        )
      else if E.Message = 'quantidade_invalida' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'QUANTIDADE_INVALIDA')
                           .AddPair('message', 'A quantidade deve ser maior que zero.')
        )
      else
        Res.Status(500).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'ERRO_INTERNO')
                           .AddPair('message', E.Message)
        );
    end;
  end;
end;

end.
