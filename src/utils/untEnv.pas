unit untEnv;

interface

type
  TEnv = class
  public
    class function LerEnvPorChave(const pKey: string): string;
  end;

implementation

uses
  System.SysUtils,
  System.Classes;

{ TEnv }

class function TEnv.LerEnvPorChave(const pKey: string): string;
var
  lArquivo: TStringList;
  lLinha: string;
  lKey: string;
  lValue: string;
  lI: Integer;
begin
  //Reseta o return
  Result := '';

  lArquivo := TStringList.Create;
  try
    //Pega o caminho do .env, esse ParamStr(0) é a localizaçao do app
    lArquivo.LoadFromFile(ExtractFilePath(ParamStr(0)) + '..\..\..\..\.env');

    //Passa lendo o arquivo ate encontrar
    for lI := 0 to lArquivo.Count - 1 do
    begin
      lLinha := Trim(lArquivo[lI]);

      if (lLinha = '') or (lLinha.StartsWith('#')) then
        Continue;

      lKey := Trim(Copy(lLinha, 1, Pos('=', lLinha) - 1));
      lValue := Trim(Copy(lLinha, Pos('=', lLinha) + 1, MaxInt));

      //Se encontrou sai do laco
      if SameText(lKey, pKey) then
      begin
        Result := lValue;
        Exit;
      end;
    end;
  finally
    lArquivo.Free;
  end;
end;


end.
