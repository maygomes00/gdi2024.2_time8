// Usando save para atualizar um documento existente. Também usa findOne 
var cliente = db.clientes.findOne({ nome: "Lúcio Gomes" });
cliente.telefone = "555-9999";
db.clientes.save(cliente);

// Usando save para inserir um novo documento
var novoCliente = { nome: "Ana Paula", telefone: "555-0000" };
db.clientes.save(novoCliente);

// Criar uma função personalizada
var calcularDesconto = function(preco) {
    return preco * 0.9; // 10% de desconto
  };
  
  // Usar a função em uma consulta
  db.servicos.find().forEach(function(servico) {
    print("Serviço: " + servico.nome + ", Preço com desconto: " + calcularDesconto(servico.preco));
  });

// Clientes com nomes de mais de 10 caracteres
db.clientes.find({ $where: "this.nome.length > 10" });

// Encontrar profissionais com exatamente 5 dias de disponibilidade
db.profissionais.find({
    disponibilidade: { $size: 5 }
  }).pretty();



//==============================================================================================================//

//Consultas mais complexas misturando as funções da checklist


//Consulta de serviços PREMIUM (mais caros que 100 reais) (GROUP, SUM, MAX, AVG, PROJECT, MATCH)
db.servicos.aggregate([
  { $match: { preco: { $gte: 100 } } },
  {
    $group: {
      _id: null,
      totalServicos: { $sum: 1 },
      precoMaximo: { $max: "$preco" },
      precoMedio: { $avg: "$preco" }
    }
  },
  {
    $project: {
      _id: 0,
      qtdServicosPremium: "$totalServicos",
      servicoMaisCaro: "$precoMaximo",
      mediaPrecos: { $round: ["$precoMedio", 2] }
    }
  }
]);

//Funções EXISTS, SIZE, FINDONE, $WHERE
// Procura um cliente com email e telefone válidos
db.clientes.findOne({
  email: { $exists: true },  // email validado
  $where: "this.telefone.length >= 11" // telefone validado
});

// profissionais com pelo menos 3 serviços cadastrados
db.profissionais.find({
  servicos: { $size: { $gt: 2 } } // Array de serviços com pelo menso 3
});

// Classificação dos serviços como premium ou padrão dependendo do preço (MAPREDUCE, COND, RENAMECOLLECTION)
db.servicos.mapReduce(
  function() {
    emit(this._id, { 
      tipo: this.preco >= 100 ? "Premium" : "Padrao" 
    });
  },
  function(key, values) { return values[0]; },
  { out: "servicos_classificados" }
);
// Muda nome dos resultados
db.servicos_classificados.renameCollection("catalogo_servicos");

// Serviços premium por cliente (LOOKUP, FILTER, PROJECT)
db.clientes.aggregate([
  {
    $lookup: { 
      from: "servicos",
      localField: "_id",
      foreignField: "_id",
      as: "historico"
    }
  },
  {
    $project: { 
      nome: 1,
      servicosRelevantes: {
        $filter: { // Só serviços premium (100+ reias)
          input: "$historico",
          as: "servico",
          cond: { $gte: ["$$servico.preco", 100] }
        }
      }
    }
  }
]);

//top funcionários (FINDONE, SIZE, EXISTS)
db.profissionais.findOne({
  servicos: { $size: { $gte: 3 } }, // Pelo menos 3 serviços
  disponibilidade: { $exists: true } // Disponibilidade cadastrada
});
