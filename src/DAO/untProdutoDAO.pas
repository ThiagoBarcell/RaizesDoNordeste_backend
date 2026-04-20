unit untProdutoDAO;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  untModeloProduto;

type
  TProdutoDAO = class
  public
    //Listar todos os produtos usando List
    class function ListarProdutos(const pId: Integer; const pStatus: string): TObjectList<TProduto>;
    class function InserirProdutos(const pNome, pDescricao: string; const pPreco: Double; const pAtivo: Boolean): Integer;
    class procedure AtualizarProdutos(const pId: Integer; const pNome, pDescricao: string; const pPreco: Double; const pAtivo: Boolean);
    class function ExistePorId(const pId: Integer): Boolean;
  end;

implementation

uses
  FireDAC.Comp.Client,
  FireDAC.DApt,
  untConnection;

class function TProdutoDAO.ListarProdutos(const pId: Integer; const pStatus: string): TObjectList<TProduto>;
var
  lQry: TFDQuery;
  lProduto: TProduto;
begin
  Result := TObjectList<TProduto>.Create(True);

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;

    lQry.SQL.Clear;
    lQry.SQL.Text :=
      ' SELECT id, nome, descricao, preco, ativo ' +
      ' FROM produtos ' +
      ' WHERE 1=1 ';

    if pId > 0 then
      lQry.SQL.Add('AND id = :id');   //Se informado a ID ja passa como parametro

    if SameText(pStatus, 'ativos') then
      lQry.SQL.Add(' AND ativo = true')
    else
    if SameText(pStatus, 'inativos') then
      lQry.SQL.Add(' AND ativo = false');

    lQry.SQL.Add('ORDER BY id');

    if pId > 0 then
      lQry.ParamByName('id').AsInteger := pId;

    lQry.Open;

    while not lQry.Eof do
    begin
      lProduto := TProduto.Create;
      lProduto.Id := lQry.FieldByName('id').AsInteger;
      lProduto.Nome := lQry.FieldByName('nome').AsString;
      lProduto.Descricao := lQry.FieldByName('descricao').AsString;
      lProduto.Preco := lQry.FieldByName('preco').AsFloat;
      lProduto.Ativo := lQry.FieldByName('ativo').AsBoolean;

      Result.Add(lProduto);
      lQry.Next;
    end;

  finally
    lQry.Free;
  end;
end;

//Insere um produto novo no BD
class function TProdutoDAO.InserirProdutos(const pNome, pDescricao: string; const pPreco: Double; const pAtivo: Boolean): Integer;
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text :=
      ' INSERT INTO produtos (nome, descricao, preco, ativo) ' +
      ' VALUES (:nome, :descricao, :preco, :ativo) ' +
      ' RETURNING id';

    lQry.ParamByName('nome').AsString := pNome;
    lQry.ParamByName('descricao').AsString := pDescricao;
    lQry.ParamByName('preco').AsFloat := pPreco;
    lQry.ParamByName('ativo').AsBoolean := pAtivo;

    lQry.Open;
    Result := lQry.FieldByName('id').AsInteger;
  finally
    lQry.Free;
  end;
end;

//Criei essa verificaçao so pra validar se o produto existe, pelo ID
class function TProdutoDAO.ExistePorId(const pId: Integer): Boolean;
var
  lQry: TFDQuery;
begin
  Result := False;

  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text := 'SELECT 1 FROM produtos WHERE id = :id LIMIT 1';
    lQry.ParamByName('id').AsInteger := pId;
    lQry.Open;

    Result := not lQry.IsEmpty;
  finally
    lQry.Free;
  end;
end;

//Atualiza as informações do produto pelo ID
class procedure TProdutoDAO.AtualizarProdutos(const pId: Integer; const pNome, pDescricao: string; const pPreco: Double; const pAtivo: Boolean);
var
  lQry: TFDQuery;
begin
  lQry := TFDQuery.Create(nil);
  try
    lQry.Connection := TConectarBD.GetConnection;
    lQry.SQL.Text :=
      ' UPDATE produtos ' +
      ' SET nome = :nome, ' +
      ' descricao = :descricao, ' +
      ' preco = :preco, ' +
      ' ativo = :ativo ' +
      ' WHERE id = :id';

    lQry.ParamByName('id').AsInteger := pId;
    lQry.ParamByName('nome').AsString := pNome;
    lQry.ParamByName('descricao').AsString := pDescricao;
    lQry.ParamByName('preco').AsFloat := pPreco;
    lQry.ParamByName('ativo').AsBoolean := pAtivo;

    lQry.ExecSQL;
  finally
    lQry.Free;
  end;
end;

end.
