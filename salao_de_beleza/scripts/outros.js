// Calcular total de preços dos serviços por faixa de preço (MAPREDUCE)
db.servicos.mapReduce(
  function () {
    emit(this.preco >= 100 ? "Alto" : "Baixo", this.preco);
  },
  function (key, values) {
    return Array.sum(values);
  },
  { out: "faixa_de_preco" }
);

// Combinar clientes com serviços usando IDs simulados (LOOKUP)
db.clientes.aggregate([
  {
    $lookup: {
      from: "servicos",
      localField: "_id",
      foreignField: "_id",
      as: "servicos_realizados"
    }
  }
]);

// Adicionar um campo "faixa_preco" com base no preço (COND)
db.servicos.aggregate([
  {
    $project: {
      nome: 1,
      preco: 1,
      faixa_preco: {
        $cond: { if: { $gte: ["$preco", 100] }, then: "Alto", else: "Baixo" }
      }
    }
  }
]);
