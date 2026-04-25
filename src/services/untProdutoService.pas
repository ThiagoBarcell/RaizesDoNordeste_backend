unit untProdutoService;

interface

uses
  System.JSON,
  System.SysUtils;

type

  TProdutoService = class
  public
    class function ListarProdutos(const pId: Integer; const pStatus: string): TJSONArray;

    class function InserirProdutos(const pBody: TJSONObject): TJSONObject;

    class function AtualizarProdutos(const pId: Integer; const pBody: TJSONObject): TJSONObject;
  end;

implementation

uses
  System.Generics.Collections,
  untModeloProduto,
  untProdutoDAO;

//Retorna o array para a resposta na controller
class function TProdutoService.AtualizarProdutos(const pId: Integer; const pBody: TJSONObject): TJSONObject;
var
  lNome: string;
  lDescricao: string;
  lPreco: Double;
  lAtivo: Boolean;
begin
  if pId <= 0 then
    raise Exception.Create('id_invalido');

  if not TProdutoDAO.ExistePorId(pId) then
    raise Exception.Create('produto_nao_encontrado');


  lNome := Trim(pBody.GetValue<string>('nome', ''));
  lDescricao := Trim(pBody.GetValue<string>('descricao', ''));
  lPreco := pBody.GetValue<Double>('preco', 0);
  lAtivo := pBody.GetValue<Boolean>('ativo', True);

  if lNome = '' then
    raise Exception.Create('nome_obrigatorio');

  if lPreco <= 0 then
    raise Exception.Create('preco_invalido');

  TProdutoDAO.AtualizarProdutos(pId, lNome, lDescricao, lPreco, lAtivo);

  Result := TJSONObject.Create;

  Result.AddPair('id', TJSONNumber.Create(pId));
  Result.AddPair('nome', lNome);
  Result.AddPair('descricao', lDescricao);
  Result.AddPair('preco', TJSONNumber.Create(lPreco));
  Result.AddPair('ativo', TJSONBool.Create(lAtivo));

  end;

class function TProdutoService.InserirProdutos(const pBody: TJSONObject): TJSONObject;
var
  lNome: string;
  lDescricao: string;
  lPreco: Double;
  lAtivo: Boolean;
  lId: Integer;
begin
  lNome := Trim(pBody.GetValue<string>('nome', ''));
  lDescricao := Trim(pBody.GetValue<string>('descricao', ''));
  lPreco := pBody.GetValue<Double>('preco', 0);
  lAtivo := pBody.GetValue<Boolean>('ativo', True);

  if lNome = '' then
    raise Exception.Create('nome_obrigatorio');

  if lPreco <= 0 then
    raise Exception.Create('preco_invalido');

  lId := TProdutoDAO.InserirProdutos(lNome, lDescricao, lPreco, lAtivo);

  Result := TJSONObject.Create;

  Result.AddPair('id', TJSONNumber.Create(lId));
  Result.AddPair('nome', lNome);
  Result.AddPair('descricao', lDescricao);
  Result.AddPair('preco', TJSONNumber.Create(lPreco));
  Result.AddPair('ativo', TJSONBool.Create(lAtivo));

end;

class function TProdutoService.ListarProdutos(const pId: Integer; const pStatus: string): TJSONArray;
var
  lProdutos: TObjectList<TProduto>;
  lProduto: TProduto;
  lItem: TJSONObject;
begin
  Result := TJSONArray.Create;
  //Basicamente, dentro do TProdutoDAO monta a listagem de produtos do BD, para aqui na service alimentar a lista
  //que será gerado o retorno em JSON Array dentroi do FOR para a controller
  lProdutos := TProdutoDAO.ListarProdutos(pId, pStatus);
  try
    for lProduto in lProdutos do
    begin
      lItem := TJSONObject.Create;

      lItem.AddPair('id', TJSONNumber.Create(lProduto.Id));
      lItem.AddPair('nome', lProduto.Nome);
      lItem.AddPair('descricao', lProduto.Descricao);
      lItem.AddPair('preco', TJSONNumber.Create(lProduto.Preco));
      lItem.AddPair('ativo', TJSONBool.Create(lProduto.Ativo));

      Result.AddElement(lItem);
    end;

  finally
    lProdutos.Free;
  end;
end;

end.
