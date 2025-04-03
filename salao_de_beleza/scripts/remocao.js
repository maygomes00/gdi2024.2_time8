//No shell,  colocar use salao_de_beleza;

// Remover um cliente específico (DELETEONE)
db.clientes.deleteOne({ nome: "Carlos Souza" });

// Insere no sistema do banco de dados uma função que remove um serviço tanto da coleção de serviços quanto dos serviços dos funcionarios (FUNCTION)
db.system.js.insertOne({
    _id: "removeServico",
    value: function (nomeServico){
        // Remove serviço da coleção de serviços.
        db.servicos.deleteOne({
            nome: nomeServico
        })
        // Remove serviço dos arrays de serviço dos profissionais que tiverem ele.
        db.funcionarios.updateMany(
            { servicos: nomeServico},
            { $pull: { servicos: nomeServico}}
        )
    }
})

// Usa a função que remove serviços para remover o serviço "Massagem Relaxante 1h" (FUNCTION)
db.loadServerScripts();
print(removerServico("Massagem Relaxante 1h"));
