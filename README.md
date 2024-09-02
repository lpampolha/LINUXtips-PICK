# LINUXtips-PICK

Nessa primeira fase, o foco é na construção de uma imagem distroless, com somente a aplicação, e fazendo o apontamento para um segundo container, sendo esse da base, através de uma variável de ambiente.

Os passos são os seguintes:

## 1 - Containerização com Docker, utilizando imagens seguras 

### Baixando a imagem o repositório do app

#git clone git@github.com:badtuxx/giropops-senhas.git

#### Criação da imagem

#docker image build -t lpampolha/linuxtips-giropops-senhas:6.0 .

#### Testando

#docker run --name redis -d -p 6379:6379 redis
#docker container run --name giropops-senhas -d -p 5000:5000 lpampolha/linuxtips-giropops-senhas:6.0

## 2 - Verificando vulnerabilidades

Aqui usaremos o Trivy para fazer um scan na imagem, a fim de verificar vulnerabilidades (CVEs).  

#### Baixando o Trivy 

Acesse o site https://trivy.dev, busque os repositórios que estejam de acordo com o sabor de Linux que você estiver utilizando, e mande ver

#sudo apt-get install wget apt-transport-https gnupg <br />
#wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null <br />
#echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list <br />
#sudo apt-get update <br />
#sudo apt-get install trivy <br />

´Testando a imagem´ <br />
#trivy image lpampolha/linuxtips-giropops-senhas:6.0 <br />

<p float="left" >
<img src=./images/zero.png />
</p>

## 3 - Assinando com Cosign

-Vá até https://docs.sigstore.dev/system_config/installation/

-Instalando o Cosign <br />
#curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64" <br />
#sudo mv cosign-linux-amd64 /usr/local/bin/cosign <br />
#sudo chmod +x /usr/local/bin/cosign <br />

-Gerando o par de chaves para assinar a imagem <br />
#cosign generate-key-pair <br />

-Insira uma senha.  Após isso serão geradas as chaves pública e privada <br />
#cosign sign --key cosign.key lpampolha/linuxtips-giropops-senhas:6.0 <br />

-Verificando se a imagem é segura <br />
#cosign verify --key cosign.pub lpampolha/linuxtips-giropops-senhas:6.0 <br />

Com a imagem criada, sem vulnerabilidades e assinada, vamos ao Kubernetes <br />

## 4 - Criando os Manifestos de Deployment, Services, Secrets, ConfigMap e Ingress

### Deployments e Services

Primeiro vamos testar os manifestos da aplicação e do Redis.  Os arquivos estão no diretório k8s.  Nesse primeiro momento iremos subir a aplicação e o Redis, e expô-los através dos services.

#k apply -f giropops-senhas-deployment.yaml
#k apply -f giropops-senhas-service.yaml
#k apply -f redis-deployment.yaml
#k apply -f redis-service.yaml

### Secrets

Agora vamos criar um secret para autenticar no Docker Hub, a fim de acessar imagens privadas.  Para isso devemos codificar o conteúdo do arquivo ~/.docker/config.json, com o sequinte comando: <br />
#base64 ~/.docker/config.json

Depois vamos executar o seguinte arquivo: <br />

Agora é criar o arquivo dockerhub-secret.yaml, com o seguinte conteúdo:

  kind: Secret
  apiVersion: v1
  metadata:
    name: docker-hub-secret
  type: kubernetes.io/dockerconfigjson
  data:
    .dockerconfigjson: | #aqui entra o valor do config.json do docker codificado

Para baixar a imagem privada, será necessário usar o campo spec.imagePullSecrets

  spec:
    containers:
    - name: nginx-secret
      image: lpampolha/linuxtips-giropops-senhas:6.0
    imagePullSecrets:
    - name: docker-hub-secret

### ConfigMap

Um ConfigMap é um objeto da API usado para armazenar dados não-confidenciais em pares chave-valor. Pods podem consumir ConfigMaps como variáveis de ambiente, argumentos de linha de comando ou como arquivos de configuração em um volume.

Um ConfigMap ajuda a desacoplar configurações vinculadas ao ambiente das imagens de container, de modo a tornar aplicações mais facilmente portáveis.

### Ingress

Com o Ingress é possível expôr rotas http e https de fora do cluster para um serviço de dentro do cluster.

Antes de instalá-lo no Kind, existe a necessidade de adicionar algumas linhas no manifesto do cluster.  O arquivo para a recriação é o cluster.yaml, que está dentro do diretório k8s.  Após recriar o Cluster, execute os dois próximos comandos:

Visite a página https://kind.sigs.k8s.io/docs/user/ingress/

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yam

#kubectl wait --namespace ingress-nginx \                                                                      130 ↵
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

Vamos dar um apply no diretório k8s, a fim de subir os deploys e serviços

#k apply -f k8s/
configmap/configmap-giropops-senhas created
secret/docker-hub-secret created
deployment.apps/giropops-senhas created
service/giropops-senhas created
deployment.apps/redis created
service/redis-service created

Agora sim vamos ao nosso Ingress

#k apply -f k8s/ingress.yaml

Funcionando
