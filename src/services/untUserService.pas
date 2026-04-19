unit untUserService;

interface

uses
  System.JSON;

type
  TUserService = class
  public
    class function Signup(const pBody: TJSONObject): TJSONObject;
    class function Login(const pBody: TJSONObject): TJSONObject;
  end;

implementation

uses
  System.SysUtils,
  BCrypt,
  untUserDAO,
  untModeloUsuario,
  untJWT;

class function TUserService.Signup(const pBody: TJSONObject): TJSONObject;
var
  lNome: string;
  lEmail: string;
  lSenha: string;
  lSenhaHash: string;
  lUserId: Integer;
begin
  lNome := pBody.GetValue<string>('nome', '');
  lEmail := pBody.GetValue<string>('email', '');
  lSenha := pBody.GetValue<string>('senha', '');

  if Trim(lNome) = '' then
    raise Exception.Create('nome_obrigatorio');

  if Trim(lEmail) = '' then
    raise Exception.Create('email_obrigatorio');

  if Trim(lSenha) = '' then
    raise Exception.Create('senha_obrigatoria');

  if TUserDAO.EmailExists(lEmail) then
    raise Exception.Create('email_existente');

  // custo 10 é o default documentado na  lib
  lSenhaHash := TBCrypt.GenerateHash(lSenha, 10);

  // role_id = 2 que seria CLIENTE no seed
  lUserId := TUserDAO.InsertUser(lNome, lEmail, lSenhaHash, 2);

  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(lUserId));
  Result.AddPair('nome', lNome);
  Result.AddPair('email', lEmail);
end;

class function TUserService.Login(const pBody: TJSONObject): TJSONObject;
var
  lEmail: string;
  lSenha: string;
  lToken: string;
  lUsuario: TUsuario;
begin
  lEmail := pBody.GetValue<string>('email', '');
  lSenha := pBody.GetValue<string>('senha', '');

  if Trim(lEmail) = '' then
    raise Exception.Create('email_obrigatorio');

  if Trim(lSenha) = '' then
    raise Exception.Create('senha_obrigatoria');

  //Cria a classe e recebe, optei por classe
  lUsuario := TUserDAO.GetUserByEmail(lEmail);

  try
    if not Assigned(lUsuario) then
      raise Exception.Create('email_nao_encontrado');

    if not TBCrypt.CompareHash(lSenha, lUsuario.Senha) then
      raise Exception.Create('senha_incorreta');

    lToken := GerarToken(lUsuario.Id, lUsuario.Email);

    Result := TJSONObject.Create;
    Result.AddPair('accessToken', lToken);
    Result.AddPair('tokenType', 'Bearer');
    Result.AddPair(
      'user',
      TJSONObject.Create
        .AddPair('id', TJSONNumber.Create(lUsuario.Id))
        .AddPair('nome', lUsuario.Nome)
        .AddPair('email', lUsuario.Email)
        .AddPair('roleId', TJSONNumber.Create(lUsuario.RoleId))
    );
  finally
    lUsuario.Free;
  end;
end;

end.
