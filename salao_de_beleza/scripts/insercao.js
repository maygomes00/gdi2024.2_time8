db.clientes.insertMany([
    { "nome": "Valéria Silva", "telefone": "555-1234", "email": "maria@geradornv.com.br", "aniversario": "16/05/1999" },
    { "nome": "Lúcio Gomes", "telefone": "555-5678", "email": "joao@geradornv.com.br", "aniversario": "01/06/1970" }
  ]);
  
db.servicos.insertMany([
    { "nome": "Manicure Banho em Gel + Alongamento", "preco": 130.00 },
    { "nome": "Depilação - Axila", "preco": 60.00 }
    ]);
            
db.funcionarios.insertOne({
    "nome": "Joana",
    "disponibilidade": ["Segunda", "Terça", "Quarta", "Quinta", "Sexta"],
    "servicos": ["Manicure Banho em Gel + Alongamento"]
});
  