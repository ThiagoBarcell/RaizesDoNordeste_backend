program Proj_RaizesDoNordesteAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.JWT,
  Horse.Jhonson,
  System.SysUtils,
  Horse.Logger,
  Horse.Logger.Provider.Console,
  Horse.Utils.ClientIP,
  Horse.GBSwagger,
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
  untProdutoController in 'src\controllers\untProdutoController.pas',
  untModeloItemPedido in 'src\models\untModeloItemPedido.pas',
  untPedidosDAO in 'src\DAO\untPedidosDAO.pas',
  untPedidosService in 'src\services\untPedidosService.pas',
  untPedidosController in 'src\controllers\untPedidosController.pas',
  untEstoqueDAO in 'src\DAO\untEstoqueDAO.pas',
  untEstoqueService in 'src\services\untEstoqueService.pas',
  untEstoqueController in 'src\controllers\untEstoqueController.pas',
  untPagamentoDAO in 'src\DAO\untPagamentoDAO.pas',
  untPagamentoService in 'src\services\untPagamentoService.pas',
  untPagamentoController in 'src\controllers\untPagamentoController.pas',
  untLogDAO in 'src\DAO\untLogDAO.pas',
  untLogService in 'src\services\untLogService.pas',
  untSwaggerDocs in 'src\Swagger\untSwaggerDocs.pas';

begin
  try
    var LLogFileConfig: THorseLoggerConsoleConfig;

    //Middlewares usados no projeto
    THorse.Use(Jhonson);
    THorse.Use(THorseLoggerManager.HorseCallback);
    THorse.Use(HorseJWT(TEnv.LerEnvPorChave('JWT_SECRET'), THorseJWTConfig.New.SkipRoutes(
      [ '/ping','/signup', '/login', '/swagger', '/favicon.ico', '/swagger/json' ])));
    LLogFileConfig := THorseLoggerConsoleConfig.New
      .SetLogFormat( { ${request_clientip} ' [${time}] ${response_status} Request executada : ${request_path_info} ');
    THorseLoggerManager.RegisterProvider(THorseLoggerProviderConsole.New(LLogFileConfig));

    // Aqui faz a carga das DLLs do PostgreSQL para conexão com o banco de dados.
    // Como o projeto é 64 bits, o executável fica em \build\bin\Win64\Debug,
    // então o caminho retorna até a raiz do projeto e acessa a pasta libs.
    SetDllDirectory( PChar( ExtractFilePath( ParamStr(0) ) + '..\..\..\..\libs' ) );

    //Faz a conexao com o banco de dados
    TConectarBD.Connect;

    untSwaggerDocs.DocumentacaoSwagger;
    untRoutes.RegistrarRotas;
    //Deixei essa porta como padrão, ja do proprio HORSE
    THorse.Listen(StrToInt(TEnv.LerEnvPorChave('API_PORT')),
      procedure
      begin
        Writeln('Servidor rodando na porta : ' + IntToStr(THorse.Port) );
      end );
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
