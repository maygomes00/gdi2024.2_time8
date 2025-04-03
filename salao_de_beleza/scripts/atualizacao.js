//No shell,  colocar use salao_de_beleza;

// Atualizar o preço de um serviço (UPDATEONE e SET)
db.servicos.updateOne(
    { nome: "Corte de Cabelo Feminino" },
    { $set: { preco: 75.00 } }
  );
  
// Atualizar o telefone de um cliente (UPDATEONE e SET)
db.clientes.updateOne(
    { nome: "Gabriel Santos" },
    { $set: { telefone: "555-3333" } }
  );

// Adicionar um serviço à lista de um profissional (ADDTOSET)
db.profissionais.updateOne(
    { nome: "Joana" },
    { $addToSet: { servicos: "Hidratação Profunda" } }
  );
  
// Atualizar múltiplos profissionais para incluir "Sobrancelhas" como serviço (UPDATEMANY)
db.profissionais.updateMany(
    { disponibilidade: { $all: ["Segunda", "Terça"] } },
    { $addToSet: { servicos: "Sobrancelha Design + Henna" } }
  );

// Adiciona corte de cabela masculino como novo serviço (INSERTONE)
db.servicos.insertOne({
  "nome": "Corte de Cabelo Masculino",
  "preco": 40.00
})

// Adiciona um novo profissional que realiza os cortes de cabelo masculino (INSERTONE)
db.profissionais.insertOne({
  "nome": "João",
  "disponibilidade": ["Sabado", "Domingo"],
  "servicos": ["Corte de Cabelo Masculino"]
})