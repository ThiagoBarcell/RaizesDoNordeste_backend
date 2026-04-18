program Proj_RaizesDoNordesteAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.SysUtils,
  untRoutes in 'src\routes\untRoutes.pas',
  untConection in 'src\database\untConection.pas';

begin
  try
    //Faz a conexao com o banco de dados
    TConectarBD.Connect;

    untRoutes.RegistrarRotas;

    //Deixei essa porta como padrão, ja do proprio HORSE
    THorse.Listen(9000,
      procedure
      begin
        Writeln('Servidor rodando em ' + THorse.Host + IntToStr(THorse.Port) );
      end
    );
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
