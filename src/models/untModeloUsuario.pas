unit untModeloUsuario;

interface

type
  TUsuario = class
  private
    fId : Integer;
    fNome : string;
    fEmail : string;
    fSenha : string;
    fRoleId : Integer;
  public
    property Id : Integer read fId write fId;
    property Nome : string read fNome write fNome;
    property Email : string read fEmail write fEmail;
    property Senha : string read fSenha write fSenha;
    property RoleId : Integer read fRoleId write fRoleId;
  end;

implementation

end.
