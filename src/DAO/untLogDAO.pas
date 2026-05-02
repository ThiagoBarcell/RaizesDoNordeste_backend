unit untLogDAO;

interface

uses
  FireDAC.Comp.Client,
  System.DateUtils,
  System.SysUtils,
  FireDAC.Stan.Param;

type
  TLogDAO = class
  public
    class procedure RegistrarLogs(const pUsuarioId: Integer;const pAcao: string;const pEntidade: string;
      const pEntidadeId: Integer;const pDetalhe: string );
  end;

implementation

uses
  FireDAC.DApt,
  untConnection;

class procedure TLogDAO.RegistrarLogs(const pUsuarioId: Integer;const pAcao: string;const pEntidade: string;
  const pEntidadeId: Integer;const pDetalhe: string );
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Clear;
    lQry.SQL.Text := 'INSERT INTO logs_auditoria ' +
      '(usuario_id, acao, entidade, entidade_id, detalhe) ' +
      'VALUES ' +
      '(:usuario_id, :acao, :entidade, :entidade_id, :detalhe)';

    lQry.ParamByName('usuario_id').AsInteger := pUsuarioId;
    lQry.ParamByName('acao').AsString := pAcao;
    lQry.ParamByName('entidade').AsString := pEntidade;
    lQry.ParamByName('entidade_id').AsInteger := pEntidadeId;
    lQry.ParamByName('detalhe').AsString := Now.ToString + ' : ' + pDetalhe;

    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

end.
