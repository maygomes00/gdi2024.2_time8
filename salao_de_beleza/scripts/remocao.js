//No shell,  colocar use salao_de_beleza;

// Remover um cliente específico (DELETEONE)
db.clientes.deleteOne({ nome: "Luisa Tolentino" });

// Remover serviços abaixo de um preço específico (DELETEMANY)
db.servicos.deleteMany({ preco: { $lt: 40.00 } });
