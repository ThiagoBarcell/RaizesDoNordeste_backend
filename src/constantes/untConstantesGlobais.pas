unit untConstantesGlobais;

interface

const
  //Coloquei no array para pular essas rotas ao autenticar o JWT
  SKIP_ROUTES: array[0..1] of string = ('/ping', '/signup');

  //Canais de pedido possíveis
  CANAL_TOTEM = 'TOTEM';
  CANAL_WEB = 'WEB';
  CANAL_APP = 'APP';

  //Status dos pedidso
  STATUS_PED_AGUARDANDO_PAGAMENTO = 'AGUARDANDO_PAGAMENTO';
  STATUS_PED_PAGO = 'PAGO';
  STATUS_PED_EM_PREPARO = 'EM_PREPARO';
  STATUS_PED_PRONTO = 'PRONTO';
  STATUS_PED_ENTREGUE = 'ENTREGUE';
  STATUS_PED_CANCELADO = 'CANCELADO';

  //Tipos de movimentações do estoque, deixei aqui pro padrão q fiz no BD
  MOV_TIPO_ENTRADA = '';
  MOV_TIPO_SAIDA = 'SAIDA';
  MOV_TIPO_AJUSTE = 'AJUSTE';
  MOV_TIPO_BAIXA_PEDIDO = 'BAIXA_PEDIDO';

  //Origem da movimentação do pedido, fiz pra ficar facil na hora de orientar
  ORI_PED_MANUAL = 'MANUAL';
  ORI_PED_PEDIDO = 'PEDIDO';
  ORI_PED_SISTEMA = 'SISTEMA';


implementation

end.
