unit untProdutoController;

interface

uses
  Horse;


procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure InserirProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure AtualizarProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.JSON,
  System.SysUtils,
  untProdutoService;

procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Integer;
  lStatus: string;
  lResponse: TJSONArray;
begin
  try
    //Se nao encontrar na qry param o ID, passa como 0 pro defalt
    lId := StrToIntDef(Req.Query['id'], 0);

    lStatus := Trim(Req.Query['status']);

    //Se não encontrou o status, passa como padrao ativos
    if lStatus = '' then
      lStatus := 'ativos';

    //Valida erros de digitacao
    if not (
      SameText(lStatus, 'ativos') or SameText(lStatus, 'inativos') or
      SameText(lStatus, 'todos') )
    then
    begin
      Res.Status(400).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'STATUS_INVALIDO')
          .AddPair('message', 'Use ativos, inativos ou todos.') );
      Exit;
    end;

    lResponse := TProdutoService.ListarProdutos(lId, lStatus);

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

procedure InserirProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONObject;
  lSession: TJSONObject;
  lResponse: TJSONObject;
  lUsuarioId : Integer;
begin
  try
    //Ja recebe o corpo da requisição
    lBody := Req.Body<TJSONObject>;

    lSession := Req.Session<TJSONObject>;

    if not Assigned(lSession) then
    begin
      Res.Status(401).Send('Token inválido');
      Exit;
    end;

    lUsuarioId := StrToIntDef(lSession.GetValue<string>('sub', ''), 0);

    if not Assigned(lBody) then
    begin
      Res.Status(400).Send<TJSONObject>(
        TJSONObject.Create.AddPair('error', 'BODY_INVALIDO')
          .AddPair('message', 'Body da requisição inválido.'));
      Exit;
    end;

    lResponse := TProdutoService.InserirProdutos( lUsuarioId, lBody);
    Res.Status(201).Send<TJSONObject>(lResponse);
  except
    //Trata todas as exceçoes
    on E: Exception do
    begin
      if E.Message = 'nome_obrigatorio' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'NOME_OBRIGATORIO')
            .AddPair('message', 'O campo nome é obrigatório.')
        )
      else
      if E.Message = 'preco_invalido' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'PRECO_INVALIDO')
            .AddPair('message', 'O preço deve ser maior que zero.') )
      else
        Res.Status(500).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'ERRO_INTERNO')
            .AddPair('message', E.Message) );
    end;
  end;
end;

procedure AtualizarProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Integer;
  lBody: TJSONObject;
  lResponse: TJSONObject;
begin
  try

    lId := StrToIntDef(Req.Query['id'], 0);
    lBody := Req.Body<TJSONObject>;

    if not Assigned(lBody) then
    begin
      Res.Status(400).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'BODY_INVALIDO')
          .AddPair('message', 'Body da requisição inválido.'));
      Exit;
    end;

    lResponse := TProdutoService.AtualizarProdutos(lId, lBody);
    Res.Status(200).Send<TJSONObject>(lResponse);
  except
    on E: Exception do
    begin
      if E.Message = 'id_invalido' then
        Res.Status(400).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'ID_INVALIDO')
            .AddPair('message', 'Id do produto inválido.'))
      else
      if E.Message = 'produto_nao_encontrado' then
        Res.Status(404).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'PRODUTO_NAO_ENCONTRADO')
            .AddPair('message', 'Produto não encontrado.'))
      else
      if E.Message = 'nome_obrigatorio' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'NOME_OBRIGATORIO')
            .AddPair('message', 'O campo nome é obrigatório.'))
      else
      if E.Message = 'preco_invalido' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'PRECO_INVALIDO')
            .AddPair('message', 'O preço deve ser maior que zero.'))
      else
        Res.Status(500).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'ERRO_INTERNO')
            .AddPair('message', E.Message));
    end;
  end;
end;

end.
