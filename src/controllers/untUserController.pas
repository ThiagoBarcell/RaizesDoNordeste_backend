unit untUserController;


interface

uses
  Horse;

procedure Signup(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.SysUtils,
  System.JSON,
  JOSE.Core.JWT,
  untUserService;

procedure Signup(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONObject;
  lResponse: TJSONObject;
begin
  try
    //Recebe o corpo da requisição, JSON no caso
    lBody := Req.Body<TJSONObject>;

    if not Assigned(lBody) then
    begin
      Res.Status(400).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'JSON_INVALIDO')
          .AddPair('message', 'Json da requisição inválido.')
      );
      Exit;
    end;

    lResponse := TUserService.Signup(lBody);
    //Sem erro, manda 201 de cadastro OK
    Res.Status(201).Send<TJSONObject>(lResponse);

  except
    //Tratei todas as situação para o cadastro para não faltar info no JSON,
    //Esse retorno vem da exceção que é criado dentro da Signup
    on E: Exception do
    begin
      if E.Message = 'email_existente' then
        Res.Status(409).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'EMAIL_EXISTENTE')
            .AddPair('message', 'Já existe um usuário com este e-mail.')
        )
      else
      if E.Message = 'nome_obrigatorio' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'NOME_OBRIGATORIO')
            .AddPair('message', 'O campo nome é obrigatório.')
        )
      else
      if E.Message = 'email_obrigatorio' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'EMAIL_OBRIGATORIO')
            .AddPair('message', 'O campo email é obrigatório.')
        )
      else
      if E.Message = 'senha_obrigatoria' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'SENHA_OBRIGATORIA')
            .AddPair('message', 'O campo senha é obrigatório.')
        )
      else
        Res.Status(500).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'ERRO_INTERNO')
            .AddPair('message', E.Message)
        );
    end;
  end;
end;

procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lBody: TJSONObject;
  lResponse: TJSONObject;
begin
  try
    lBody := Req.Body<TJSONObject>;

    if not Assigned(lBody) then
    begin
      Res.Status(400).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('error', 'JSON_INVALIDO')
          .AddPair('message', 'Body da requisição inválido.')
      );
      Exit;
    end;

    lResponse := TUserService.Login(lBody);
    Res.Status(200).Send<TJSONObject>(lResponse);
  except
    on E: Exception do
    begin
      if E.Message = 'email_nao_encontrado' then
        Res.Status(401).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'EMAIL_NAO_ENCONTRADO')
            .AddPair('message', 'Usuário não encontrado.')
        )
      else if E.Message = 'senha_incorreta' then
        Res.Status(401).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'SENHA_INCORRETA')
            .AddPair('message', 'Senha inválida.')
        )
      else if E.Message = 'email_obrigatorio' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'EMAIL_OBRIGATORIO')
            .AddPair('message', 'O campo email é obrigatório.')
        )
      else if E.Message = 'senha_obrigatoria' then
        Res.Status(422).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'SENHA_OBRIGATORIA')
            .AddPair('message', 'O campo senha é obrigatório.')
        )
      else
        Res.Status(500).Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('error', 'ERRO_INTERNO')
            .AddPair('message', E.Message)
        );
    end;
  end;
end;

end.
