unit untJWT;

interface

function GerarToken(const pUserId: Integer; const pEmail: string): string;

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

function GerarToken(const pUserId: Integer; const pEmail: string): string;
var
  lJWT: TJWT;
begin
  lJWT := TJWT.Create;
  try
    lJWT.Claims.Expiration := IncHour(Now, 24);
    lJWT.Claims.IssuedAt := Now;
    lJWT.Claims.Subject := IntToStr(pUserId);
    lJWT.Claims.SetClaimOfType<string>('email', pEmail);

    Result := TJOSE.SHA256CompactToken(TEnv.LerEnvPorChave('JWT_TOKEN'), lJWT);
  finally
    lJWT.Free;
  end;
end;

end.
