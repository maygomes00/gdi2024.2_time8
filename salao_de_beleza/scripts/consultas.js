//No shell,  colocar use salao_de_beleza;

// Quantidade de serviços com preço maior ou igual a 80 (COUNTDOCUMENTS e GTE)
db.servicos.countDocuments({ preco: { $gte: 80 } });

// Encontrar quais os serviços com preço maior ou igual a 80 e formatar a saída com PRETTY (FIND e PRETTY)
db.servicos.find({ preco: { $gte: 80 } }).pretty();

// Encontrar profissionais com disponibilidade às quintas-feiras (FIND e FILTER)
db.funcionarios.find({ disponibilidade: { $in: ["Terça"] } }).pretty();

// (PROJECT)


// Quantidade de serviços com preço maior ou igual a 50 (COUNTDOCUMENTS e GTE)
db.servicos.countDocuments({ preco: { $gte: 80 } });

// Agregaçar e criar Preço médio dos serviços (AGGREGATE, AVG)
db.servicos.aggregate([
  {
    $group: {
      _id: null,
      precoMedio: { $avg: "$preco" }
    }
  }
]);

// Maior preço entre os serviços (MAX)
db.servicos.aggregate([
  {
    $group: {
      _id: null,
      precoMaximo: { $max: "$preco" }
    }
  }
]);

// Contar clientes com email cadastrado (EXISTS)
db.clientes.countDocuments({ email: { $exists: true } });

// Ordenar serviços por preço decrescente (SORT e LIMIT)
db.servicos.find().sort({ preco: -1 }).limit(3);

// Verificar clientes que têm aniversários em dezembro (MATCH e ALL)
db.clientes.find({ aniversario: { $regex: "/12/" } }).pretty();

// Localizar serviços usando TEXTO e BUSCA (TEXT e SEARCH)
db.servicos.createIndex({ nome: "text" });
db.servicos.find({ $text: { $search: "Corte" } });

