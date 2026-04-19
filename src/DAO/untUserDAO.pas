unit untUserDAO;

interface

uses
  Data.DB,
  FireDAC.DApt,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  untModeloUsuario;

type
  TUserDAO = class
  public
    class function EmailExists(const AEmail: string): Boolean;
    class function InsertUser(const ANome, AEmail, ASenhaHash: string; ARoleId: Integer): Integer;
    class function GetUserByEmail(const pEmail: string): TUsuario; //Metodo para validar o usuário e ja retornar o modelo
  end;

implementation

uses
  System.SysUtils,
  untConnection;

class function TUserDAO.EmailExists(const AEmail: string): Boolean;
var
  lQry: TFDQuery;
begin
  //Crio a query em tempo de execução
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.Close;
    lQry.SQL.Clear;
    lQry.SQL.Text := 'SELECT id, nome, email, senha, role_id, criado_em ' +
      ' FROM usuarios ' +
      ' WHERE email = :email';
    lQry.ParamByName('email').AsString := AEmail;
    lQry.Open;

    //Se a query não está vazia ou seja se encontrou algum registro
    Result := not lQry.IsEmpty;
  finally
    lQry.Free;
  end;
end;

class function TUserDAO.GetUserByEmail(const pEmail: string): TUsuario;
var
  lQry: TFDQuery;
begin
  Result := nil;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text :=
      'SELECT id, nome, email, senha, role_id ' +
      'FROM usuarios ' +
      'WHERE email = :email';

    lQry.ParamByName('email').AsString := pEmail;
    lQry.Open;

    //Se encontrou o usuário no banco, devolve o model preenchido
    if not lQry.IsEmpty then
    begin
      //Instancia o objeto
      Result := TUsuario.Create;
      Result.Id := lQry.FieldByName('id').AsInteger;
      Result.Nome := lQry.FieldByName('nome').AsString;
      Result.Email := lQry.FieldByName('email').AsString;
      Result.Senha := lQry.FieldByName('senha').AsString;
      Result.RoleId := lQry.FieldByName('role_id').AsInteger;
    end;
  finally
    lQry.Free;
  end;
end;

class function TUserDAO.InsertUser(const ANome, AEmail, ASenhaHash: string; ARoleId: Integer): Integer;
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.Close;
    lQry.SQL.Clear;
    lQry.SQL.Text :=
      'INSERT INTO usuarios (nome, email, senha, role_id) ' +
      'VALUES (:nome, :email, :senha, :role_id) ' +
      'RETURNING id';
    lQry.ParamByName('nome').AsString := ANome;
    lQry.ParamByName('email').AsString := AEmail;
    lQry.ParamByName('senha').AsString := ASenhaHash;
    lQry.ParamByName('role_id').AsInteger := ARoleId;

    lQry.Open;
    Result := lQry.FieldByName('id').AsInteger;
  finally
    lQry.Free;
  end;
end;

end.
