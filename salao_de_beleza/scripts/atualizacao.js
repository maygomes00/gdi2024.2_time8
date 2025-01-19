//No shell,  colocar use salao_de_beleza;

// Atualizar o preço de um serviço (UPDATEONE e SET)
db.servicos.updateOne(
    { nome: "Corte Feminino" },
    { $set: { preco: 75.00 } }
  );
  
  // Adicionar um serviço à lista de um profissional (ADDTOSET)
  db.profissionais.updateOne(
    { nome: "Carla" },
    { $addToSet: { servicos: "Hidratação Capilar" } }
  );
  
  // Atualizar o telefone de um cliente (UPDATEONE)
  db.clientes.updateOne(
    { nome: "Rosane Pedroso" },
    { $set: { telefone: "97333-3333" } }
  );
  
  // Atualizar múltiplos profissionais para incluir "Sobrancelhas" como serviço (UPDATEMANY)
  db.profissionais.updateMany(
    { disponibilidade: { $all: ["Segunda", "Terça"] } },
    { $addToSet: { servicos: "Sobrancelhas" } }
  );
  