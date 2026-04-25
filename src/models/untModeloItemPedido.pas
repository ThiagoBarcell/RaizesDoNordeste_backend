unit untModeloItemPedido;

interface

//Modelo para indicar o produto dentro do pedido
type
  TModeloItemPedido = class
  private
    fProdutoId: Integer;
    fQuantidade: Integer;
  public

    property ProdutoId: Integer read fProdutoId write fProdutoId;
    property Quantidade: Integer read fQuantidade write fQuantidade;
  end;

implementation

end.
