# Configuração do Ambiente para rodar o MongoDB com Docker

## 1. Instalar o Docker e rodar o MongoDB

- **Instale o Docker**: 
  Baixe e instale o Docker a partir do site oficial [https://www.docker.com/](https://www.docker.com/).

- **Crie um contêiner MongoDB**:  
  Execute o seguinte comando no terminal para criar e rodar o MongoDB:
  ```bash
  docker run -d -p 27017:27017 --name mongodb mongo:latest
- **Verifique o contêiner**:
  Confirme que o contêiner está rodando
  ```bash
  docker ps

## 2. Instale o MongoDB Compass:
- **Baixe o MongoDB Compass no site oficial**: [https://www.mongodb.com/products/compass](https://www.mongodb.com/products/compass).
- **Conecte o MongoDB Compass**:
Abra o Compass e insira o seguinte URI de conexão
  ```bash
  mongodb://localhost:27017 (padrão)"
