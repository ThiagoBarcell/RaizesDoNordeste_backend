unit untRoutes;

interface

procedure RegistrarRotas;

implementation

uses
  Horse;

procedure RegistrarRotas;
begin
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('pong');
    end);
end;

end.
