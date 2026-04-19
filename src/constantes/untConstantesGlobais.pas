unit untConstantesGlobais;

interface

const
  //Coloquei no array para pular essas rotas ao autenticar o JWT
  SKIP_ROUTES: array[0..1] of string = ('/ping', '/signup');

implementation

end.
