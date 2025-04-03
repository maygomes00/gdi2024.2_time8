// Calcular total de preços dos serviços por faixa de preço (MAPREDUCE)
db.servicos.mapReduce(
  // Separa os serviços de duas categorias de acordo com o preço.
  function () {
    emit(this.preco >= 100 ? "Alto" : "Baixo", this.preco);
  },
  // Soma os preços dos serviços por categoria.
  function (key, values) {
    return Array.sum(values);
  },
  // Guarda o resultando no valor total de cada categoria em uma nova coleção.
  { out: "faixa_de_preco_soma" }
);

// mostra os serviços e quais funcionários realizam cada serviço (LOOKUP e PROJECT)
db.servicos.aggregate([
  // Atribui os serviços aos funcionarios que realizam eles.
  {
    $lookup: {
      from: "funcionarios",
      localField: "nome",
      foreignField: "servicos",
      as: "funcionarios"
    }
  },
  // Exibe apenas as informações indicadas.
  {
    $project: {
      _id: 0,
      nome: 1,
      "funcionarios.nome": 1
    }
  }
]);

// Adicionar um campo "faixa_preco" com base no preço (COND)
db.servicos.aggregate([
  {
    $project: {
      _id: 0,
      nome: 1,
      preco: 1,
      faixa_preco: {
        $cond: { if: { $gte: ["$preco", 100] }, then: "Alto", else: "Baixo" }
      }
    }
  }
]);

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

// Exibe apenas os funcionarios disponiveis na quinta-feira.
db.funcionarios.aggregate([
  {
    $project: {
      _id: 0,
      nome: 1,
      telefone: 1,
      disponibilidade_quinta: {  // pega só quem tá disnponível na quinta
        $filter: {
          input: "$disponibilidade",
          as: "dia",
          cond: { $eq: ["$$dia", "Quinta"] } 
        }
      }
    }
  },
  {
    $match: {
      "disponibilidade_quinta.0": { $exists: true }  // Só quem tem quinta disponível
      }
    }
  ]);