unit untJWT;

interface

function GerarToken(const pUserId: Integer; const pEmail: string; const pRoleID : Integer): string;

implementation

uses
  Horse,
  Horse.JWT,
  System.SysUtils,
  System.DateUtils,
  JOSE.Core.JWT,
  JOSE.Core.Builder,
  JOSE.Types.JSON,
  JOSE.Core.JWS,
  JOSE.Builder,
  untEnv;

function GerarToken(const pUserId: Integer; const pEmail: string; const pRoleID : Integer): string;
var
  lJWT: TJWT;
begin
  lJWT := TJWT.Create;
  try
    lJWT.Claims.Expiration := IncHour(Now, 24);
    lJWT.Claims.IssuedAt := Now;
    lJWT.Claims.Subject := IntToStr(pUserId);
    lJWT.Claims.SetClaimOfType<string>('email', pEmail);
    lJWT.Claims.SetClaimOfType<Integer>('roleId', pRoleID);

    Result := TJOSE.SHA256CompactToken(TEnv.LerEnvPorChave('JWT_SECRET'), lJWT);
  finally
    lJWT.Free;
  end;
end;

end.
