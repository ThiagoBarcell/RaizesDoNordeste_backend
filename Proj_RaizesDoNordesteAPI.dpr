program Proj_RaizesDoNordesteAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.JWT,
  Horse.Jhonson,
  System.SysUtils,
  Winapi.Windows,
  untRoutes in 'src\routes\untRoutes.pas',
  untConnection in 'src\database\untConnection.pas',
  untUserDAO in 'src\DAO\untUserDAO.pas',
  untUserService in 'src\services\untUserService.pas',
  untUserController in 'src\controllers\untUserController.pas',
  untEnv in 'src\utils\untEnv.pas',
  untJWT in 'src\utils\untJWT.pas',
  untConstantesGlobais in 'src\constantes\untConstantesGlobais.pas',
  untModeloUsuario in 'src\models\untModeloUsuario.pas',
  untModeloProduto in 'src\models\untModeloProduto.pas',
  untProdutoDAO in 'src\DAO\untProdutoDAO.pas',
  untProdutoService in 'src\services\untProdutoService.pas',
  untProdutoController in 'src\controllers\untProdutoController.pas';

begin
  try
    //Middlewares usados no projeto
    THorse.Use(Jhonson);
    THorse.Use(HorseJWT(TEnv.LerEnvPorChave('JWT_TOKEN'), THorseJWTConfig.New.SkipRoutes(
      [ '/signup', '/login']
    )));

    //Aqui faz a carga das DLLs para o postgre, para fazer a conexão com o BD, meotodo padrão
    //como o projeto é 64bits, ele se encontra em \Win64\Debug, volta quatro e vai pra libs
    SetDllDirectory( PChar( ExtractFilePath( ParamStr(0) ) + '..\..\..\..\libs' ) );

    //Faz a conexao com o banco de dados
    TConectarBD.Connect;

    untRoutes.RegistrarRotas;

    //Deixei essa porta como padrão, ja do proprio HORSE
    THorse.Listen(StrToInt(TEnv.LerEnvPorChave('API_PORT')),
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
