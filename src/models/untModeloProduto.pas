unit untModeloProduto;

interface

type
  TProduto = class
  private
    fId: Integer;
    fNome: string;
    fDescricao: string;
    fPreco: Double;
    fAtivo: Boolean;
  public
    property Id: Integer read fId write fId;
    property Nome: string read fNome write fNome;
    property Descricao: string read fDescricao write fDescricao;
    property Preco: Double read fPreco write fPreco;
    property Ativo: Boolean read fAtivo write fAtivo;
  end;

implementation

end.
