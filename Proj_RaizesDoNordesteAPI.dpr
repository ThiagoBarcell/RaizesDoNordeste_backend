program Proj_RaizesDoNordesteAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.SysUtils,
  Winapi.Windows,
  untRoutes in 'src\routes\untRoutes.pas',
  untConection in 'src\database\untConection.pas';

begin
  try
    //Aqui faz a carga das DLLs para o postgre, para fazer a conexão com o BD
    //como o projeto é 64bits, ele se encontra em \Win64\Debug, volta quatro e vai pra libs
    SetDllDirectory(PChar(ExtractFilePath(ParamStr(0)) + '..\..\..\..\libs'));

    //Faz a conexao com o banco de dados
    TConectarBD.Connect;

    untRoutes.RegistrarRotas;

    //Deixei essa porta como padrão, ja do pro  prio HORSE
    THorse.Listen(9000,
      procedure
      begin
        Writeln('Servidor rodando em ' + THorse.Host + ':' +IntToStr(THorse.Port) );
      end
    );
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
