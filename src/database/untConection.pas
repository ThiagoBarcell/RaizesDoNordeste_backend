unit untConection;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client;

type
  TConectarBD = class
  //To usando class function pra não precisar instanciar a classe direto
  private
    class var FConnection: TFDConnection;
  public
    class function GetConnection: TFDConnection;
    class procedure Connect;
    class procedure Disconnect;
  end;

implementation

uses
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.Phys,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  FireDAC.ConsoleUI.Wait;

{ TConectar }

class procedure TConectarBD.Connect;
begin
  //Se ja está instanciado e conectado, sai do método
  if Assigned(FConnection) and FConnection.Connected then
    Exit;

  if not Assigned(FConnection) then
    FConnection := TFDConnection.Create(nil);

  //Limpa os parametros do conection
  FConnection.Params.Clear;
  FConnection.Params.Add('Server=localhost');
  FConnection.Params.Add('Port=9900');
  FConnection.Params.Add('Database=RaizesDoNordesteDB');
  FConnection.Params.Add('User_Name=postgres');
  FConnection.Params.Add('Password=masterkey');
  FConnection.Params.Add('CharacterSet=UTF8');

  //Define que será Postgre
  FConnection.DriverName := 'PG';

  FConnection.LoginPrompt := False;
  try
    FConnection.Connected := True;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end;

class procedure TConectarBD.Disconnect;
begin
  if Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Connected := False;
    //Libera a instancia da memoria
    FreeAndNil(FConnection);
  end;
end;

class function TConectarBD.GetConnection: TFDConnection;
begin
  if not Assigned(FConnection) or not FConnection.Connected then
    Connect;

  Result := FConnection;
end;

end.
