# LINUXtips-PICK

Nessa primeira fase, o foco é na construção de uma imagem distroless, com somente a aplicação, e fazendo o apontamento para um segundo container, sendo esse da base, através de uma variável de ambiente.

Os passos são os seguintes:

1 - Containerização com Docker, utilizando imagens seguras 

=== Baixando a imagem o repositório do app ===

#git clone git@github.com:badtuxx/giropops-senhas.git

=== Criação da imagem ===

#docker image build -t lpampolha/linuxtips-giropops-senhas:6.0 .

=== Testando ===

#docker run --name redis -d -p 6379:6379 redis
#docker container run --name giropops-senhas -d -p 5000:5000 lpampolha/linuxtips-giropops-senhas:6.0

2 - Verificando vulnerabilidades

Aqui usaremos o Trivy para fazer um scan na imagem, a fim de verificar vulnerabilidades (CVEs).  

=== Baixando o Trivy ===

Acesse o site https://trivy.dev, busque os repositórios que estejam de acordo com o sabor de Linux que você estiver utilizando, e mande ver


#sudo apt-get install wget apt-transport-https gnupg
#wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
#echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
#sudo apt-get update
#sudo apt-get install trivy

Testando a imagem
#trivy image lpampolha/linuxtips-giropops-senhas:6.0

<p float="left" >
<img src=./images/zero.png />
</p>

3 - Assinando com Cosign

-Vá até https://docs.sigstore.dev/system_config/installation/

-Instalando o Cosign
#curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
#sudo mv cosign-linux-amd64 /usr/local/bin/cosign
##sudo chmod +x /usr/local/bin/cosign

-Gerando o par de chaves para assinar a imagem
#cosign generate-key-pair

-Insira uma senha.  Após isso serão geradas as chaves pública e privada
#cosign sign --key cosign.key lpampolha/linuxtips-giropops-senhas:6.0

-Verificando se a imagem é segura
#cosign verify --key cosign.pub lpampolha/linuxtips-giropops-senhas:6.0

Com a imagem criada, sem vulnerabilidades e assinada, vamos ao Kubernetes

4 - 