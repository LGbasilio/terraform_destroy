# DevOps

**Nesse tutorial, irei mostrar como criar pipelines no jenkins para iniciar o job de criação e destruição da infraestrutura na Google Cloud Platform usando terraform e salvando o arquivo tfstat em um bucket.**

![infra](https://user-images.githubusercontent.com/97743829/176010879-a79a2c30-7071-402d-8710-a78b4b89b5d7.JPG)

A imagem acima mostra o fluxograma de criação da infraestrutura (vm + bucket) através do job Terraform_pipeline e também sua remoção através do job Terraform_destroy (exceto o bucket) pelo Jenkins.

**Requisitos:**
```
1 - Host com VSCode + GitBash instalado.
2 - VM ou Servidor com o terraform + Jenkins + Git instalados (aqui usei uma VM com Debian 11 hospedado na própria GCP).
3 - Conta no Google Cloud Platform.
```

**1 - Configurando o GitHub:**

No seu perfil do GitHub, navegue até "settings", escolha "developer settings", depois "personal access token" e clique em "create access token" 
Anote esse token, ele será usado mais para frente.

**2 - Configurar o git na máquina que o Jenkins está instalado:**

```
git config --global user.name "Seu nome sem aspas"
git config --global user.email "Seu e-mail sem aspas"

Para validar:
git config --list

git clone linkdoseurepo.git
o console irá pedir seu usuário e senha.

```

**3 - Integrar o Jenkins com o GitHub:**
```
Antes de tudo, você terá que inserir as credentials criadas na etapa anterior.
Ir até o Jenkins > Projeto > add credentials > colocar seu username do GIT e o token de acesso criado anteriormente.

a. Ir ao seu repositório no GitHub que quer integrar.
b. Clicar em Settings.
c. Clicar em webhooks > add webhooks.
d. Em payload, insira a url completa do jenkins adicionando no final "/github-webhook/" ex utilizado: "http://34.125.192.189:8080/github-webhook/" 
e em "Content type" selecione "application/json", deixe "secret" em branco.
e. Escolha a opção "Let me select individual events." selecione "Pull requests", "push" e "active" depois clique em "add webhook"
f. Volte ao Jenkins e clique em "new item" > digite um nome e selecione "pipeline"  e clique em "ok".
na tela seguinte selecione a aba  "general" > marque a checkbox "Git" e cole o código copiado do repositório ex: "https://github.com/LGbasilio/DevOps.git".
g. Clique em "Build Triggers" e selecione "GitHub hook trigger for GITScm polling".
h. Em definetion, selecione pipeline script e insira o script de criação da infra:

pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    stages {
        stage('Git checkout') {
           steps{
                git branch: 'main', credentialsId: 'inserir sua credencial ID aqui', url: 'inserir seu projeto.git'
            }
        }
        stage('Criação do Bucket') {
            steps{
                sh  '''
                cd bucket
                terraform init
                terraform apply --auto-approve
                cd ..
                    '''
            }
        }
        stage('terraform Init') {
            steps{
                sh 'terraform init'
            }
        }
        stage('terraform apply') {
            steps{
                sh 'terraform apply --auto-approve'
            }
        }
    }

    
}

```
**Pronto! Seu Jenkins está integrado ao git.**

**5 - Instalando o plugin Terraform no Jenkins:**

Na página inicial clicar em gerir Jenkins > plugin > procurar teraform > clicar em instalar.

Depois gerir jenkins novamente > Global tools configuration > add terraform > setar um nome de sua preferência > tirar a flag de atualizações automáticas >
install directory digitar "/usr/bin" > save


Terraform DESTROY script Jenkins

```


pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    stages {
        stage('Git checkout') {
           steps{
                git branch: 'main', credentialsId: 'inserir sua credencial ID aqui', url: 'inserir seu projeto.git'
            }
        }
        stage('terraform format init') {
            steps{
                sh 'terraform init'
                
            }
        }
        stage('terraform Destroy') {
            steps{
                sh 'terraform destroy --auto-approve'
            }
        }
        stage('Bucket destroy') {
            steps{
                sh  '''
                cd bucket
                terraform init
                terraform destroy --auto-approve
                    '''
            }
        }
    }

    
}
```





 
