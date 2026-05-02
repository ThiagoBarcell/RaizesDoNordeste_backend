unit untLogService;

interface

uses
  FireDAC.Comp.Client;

type
  TLogService = class
  public
    class procedure GerarLog( const pUsuarioId: Integer;const pAcao: string;const pEntidade: string;
      const pEntidadeId: Integer;const pDetalhe: string);
  end;

implementation

uses
  untLogDAO;

class procedure TLogService.GerarLog( const pUsuarioId: Integer;const pAcao: string;const pEntidade: string;
  const pEntidadeId: Integer;const pDetalhe: string);
begin
  TLogDAO.RegistrarLogs(pUsuarioId,pAcao,pEntidade,pEntidadeId,
    pDetalhe);
end;

end.
