# LINUXtips-PICK

Nessa primeira fase, o foco é na construção de uma imagem distroless, com somente a aplicação, e fazendo o apontamento para um segundo container, sendo esse da base, através de uma variável de ambiente.

Os passos são os seguintes:

1 - Containerização com Docker, utilizando imagens seguras 

> Baixando a imagem o repositório do app
#git clone git@github.com:badtuxx/giropops-senhas.git

> Criação da imagem
#docker image build -t lpampolha/linuxtips-giropops-senhas:6.0 .

> Testando
#docker run --name redis -d -p 6379:6379 redis
#docker container run --name giropops-senhas -d -p 5000:5000 lpampolha/linuxtips-giropops-senhas:6.0