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
