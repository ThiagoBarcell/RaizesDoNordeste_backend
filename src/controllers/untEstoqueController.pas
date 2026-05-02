unit untEstoqueController;

interface

uses
  Horse;

procedure ListarEstoque(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure MovimentarEstoque(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.SysUtils,
  System.JSON,
  untEstoqueService;

procedure ListarEstoque(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lProdutoId: Integer;
  lUnidadeId: Integer;
  lResponse: TJSONArray;
begin
  try
    lProdutoId := StrToIntDef(Req.Query['produtoId'], 0);
    lUnidadeId := StrToIntDef(Req.Query['unidadeId'], 0);

    lResponse := TEstoqueService.ListarEstoque(lProdutoId, lUnidadeId);

    Res.Status(200).Send<TJSONArray>(lResponse);
  except
    on E: Exception do
    begin
      Res.Status(500).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'ERRO_INTERNO')
          .AddPair('message', E.Message) );
    end;
  end;
end;

procedure MovimentarEstoque(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lSession: TJSONObject;
  lUsuarioId: Integer;
  lBody: TJSONObject;
  lResponse: TJSONObject;
begin
  try
    lSession := Req.Session<TJSONObject>;

    if not Assigned(lSession) then
    begin

      Res.Status(401).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'TOKEN_INVALIDO')
          .AddPair('message', 'JWT não encontrado na sessão.') );
      Exit;
    end;

    lUsuarioId := StrToIntDef(lSession.GetValue<string>('sub', ''), 0);

    if lUsuarioId = 0 then
    begin
      Res.Status(401).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'TOKEN_INVALIDO')
          .AddPair('message', 'Token inválido ou sem usuário.'));
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

    lResponse := TEstoqueService.MovimentarEstoque(lUsuarioId, lBody);

    //Retorna o json na resposta
    Res.Status(201).Send<TJSONObject>(lResponse);

  except
    on E: Exception do
    begin
      if E.Message = 'produto_obrigatorio' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'PRODUTO_OBRIGATORIO')
                            .AddPair('message', 'O campo produtoId é obrigatório.'))
      else
      if E.Message = 'unidade_obrigatoria' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'UNIDADE_OBRIGATORIA')
                            .AddPair('message', 'O campo unidadeId é obrigatório.'))
      else
      if E.Message = 'produto_nao_encontrado' then
        Res.Status(404).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'PRODUTO_NAO_ENCONTRADO')
                            .AddPair('message', 'Produto não encontrado.'))
      else
      if E.Message = 'unidade_nao_encontrada' then
        Res.Status(404).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'UNIDADE_NAO_ENCONTRADA')
                            .AddPair('message', 'Unidade não encontrada.'))
      else
      if E.Message = 'quantidade_invalida' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'QUANTIDADE_INVALIDA')
                            .AddPair('message', 'A quantidade deve ser maior que zero.'))
      else
      if E.Message = 'tipo_movimentacao_invalido' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'TIPO_MOVIMENTACAO_INVALIDO')
                            .AddPair('message', 'Use ENTRADA, SAIDA ou AJUSTE.'))
      else
      if E.Message = 'estoque_insuficiente' then
        Res.Status(409).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'ESTOQUE_INSUFICIENTE')
                            .AddPair('message', 'Estoque insuficiente para realizar a saída.'))
      else
        Res.Status(500).Send<TJSONObject>(
          TJSONObject.Create.AddPair('error', 'ERRO_INTERNO')
                            .AddPair('message', E.Message));
    end;
  end;
end;

end.
