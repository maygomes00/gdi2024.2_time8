// No shell, colocar use salao_de_beleza;

db.clientes.insertMany([
    { "nome": "Valéria Silva", "telefone": "555-1234", "email": "maria@geradornv.com.br", "aniversario": "16/05/1999" },
    { "nome": "Lúcio Gomes", "telefone": "555-5678", "email": "joao@geradornv.com.br", "aniversario": "01/06/1970" },
    { "nome": "Denis Santos", "telefone": "555-4142", "email": "ds123@gmail.com", "aniversario": "03/04/2001" },
    { "nome": "Carlos Souza", "telefone": "555-4321", "email": "carlossz@email.com", "aniversario": "12/05/1990" },
    { "nome": "Fernanda Lima", "telefone": "555-3210", "email": "lima@bol.com.br", "aniversario": "08/07/1985" },
    { "nome": "João Pereira", "telefone": "555-9887", "email": "jp@gmail.com.br", "aniversario": "08/07/1992" },
    { "nome": "Mariana Oliveira", "telefone": "555-2109", "email": "marianatrabalho@email.com", "aniversario": "15/11/1998" },
    { "nome": "Tatiane Alves", "telefone": "555-6789", "email": "TataAlves@email.com", "aniversario": "17/06/1983" },
    { "nome": "Gabriel Santos", "telefone": "555-1234", "email": "gabriel.santos@email.com", "aniversario": "21/03/1982" },
    { "nome": "Larissa Ferreira", "telefone": "555-7890", "email": "larissaf0512@gmail.com", "aniversario": "05/12/1991" }
  ]);
  
db.servicos.insertMany([
    { "nome": "Manicure Banho em Gel + Alongamento", "preco": 130.00 },
    { "nome": "Depilação - Axila", "preco": 50.00 },
    { "nome": "Corte de Cabelo Feminino", "preco": 80.00 },
    { "nome": "Escova e Finalização", "preco": 60.00 },
    { "nome": "Coloração Capilar", "preco": 150.00 },
    { "nome": "Hidratação Profunda", "preco": 90.00 },
    { "nome": "Sobrancelha Design + Henna", "preco": 70.00 },
    { "nome": "Depilação - Pernas Inteiras", "preco": 120.00 },
    { "nome": "Massagem Relaxante 1h", "preco": 180.00 },
    { "nome": "Limpeza de Pele Completa", "preco": 130.00 }
    ]);
            
db.profissionais.insertMany([
    { "nome": "Joana", "disponibilidade": ["Segunda", "Terça", "Quarta", "Quinta", "Sexta"], "servicos": ["Manicure Banho em Gel + Alongamento"] },
    { "nome": "Francisco", "disponibilidade": ["Terça", "Quinta", "Sexta"], "servicos": ["Corte de Cabelo Feminino", "Coloração Capilar", "Hidratação Profunda"] },
    { "nome": "Daniela", "disponibilidade": ["Segunda", "Quarta", "Sexta"], "servicos": ["Corte de Cabelo Feminino", "Escova e Finalização", "Sobrancelha Design + Henna"] },
    { "nome": "Tomas", "disponibilidade": ["Segunda", "Terça", "Quarta", "Quinta"], "servicos": ["Depilação - Axila", "Depilação - Pernas Inteiras", "Limpeza de Pele Completa"] },
    { "nome": "Tereza", "disponibilidade": ["Segunda", "Terça", "Quinta", "Sexta"], "servicos": ["Limpeza de Pele Completa", "Massagem Relaxante 1h"] },
    { "nome": "Julia", "disponibilidade": ["Quarta", "Quinta", "Sexta"], "servicos": ["Escova e Finalização", "Sobrancelha Design + Henna", "Depilação - Axila", "Depilação - Pernas Inteiras"] }
    ]);
  
