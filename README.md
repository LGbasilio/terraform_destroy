# DevOps

**Nesse tutorial, irei mostrar como criar pipelines no jenkins para iniciar o job de criação e destruição da infraestrutura na Google Cloud Platform usando terraform e salvando o arquivo tfstat em um bucket.**

![infra](https://user-images.githubusercontent.com/97743829/176186128-c18e38a4-dc70-4fcb-97ac-fe2634f7569f.JPG)

A imagem acima mostra o fluxograma de criação da infraestrutura (vm + bucket) através do job Terraform_pipeline e também sua remoção através do job Terraform_destroy (exceto o bucket) pelo Jenkins.

**Requisitos:**
```
1 - Host com VSCode, GitBash instalado, conta no Github, repositório com os arquivos principais do terraform (main.tf, vm.tf, etc..)
2 - VM ou Servidor com o terraform + Jenkins + Git instalados (aqui usei uma VM com Debian 11 hospedado na própria GCP).
3 - Conta no Google Cloud Platform e arquivo de credentials no formato .json
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

Antes de tudo, você terá que inserir as credentials criadas na etapa anterior.
Ir até o Jenkins > Projeto > add credentials > colocar seu username do GIT e o token de acesso criado anteriormente.

**a.** Ir ao seu repositório no GitHub que quer integrar.
**b.** Clicar em Settings.
**c.** Clicar em webhooks > add webhooks.
**d.** Em payload, insira a url completa do jenkins adicionando no final "/github-webhook/" ex utilizado: "http://34.125.192.189:8080/github-webhook/" 
e em "Content type" selecione "application/json", deixe "secret" em branco.
**e.** Escolha a opção "Let me select individual events." selecione "Pull requests", "push" e "active" depois clique em "add webhook"
**f.** Volte ao Jenkins e clique em "new item" > digite um nome e selecione "pipeline"  e clique em "ok".
na tela seguinte selecione a aba  "general" > marque a checkbox "Git" e cole o código copiado do repositório ex: "https://github.com/LGbasilio/DevOps.git".
**g.** Clique em "Build Triggers" e selecione "GitHub hook trigger for GITScm polling".
**h.** Em definetion, selecione pipeline script e insira o script de criação da infra:

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

**4 - Instalando o plugin Terraform no Jenkins:**

Na página inicial clicar em gerir Jenkins > plugin > procurar teraform > clicar em instalar.

Depois gerir jenkins novamente > Global tools configuration > add terraform > setar um nome de sua preferência > tirar a flag de atualizações automáticas >
install directory digitar "/usr/bin" > save


**A partir desse momento a pipiline já está configurada e pronta para uso**

Vamos configurar agora o VSCode para mandar o pull para o github e startar o job da pipeline para criação da infraestrutura.

**5 - Integrando o VScode ao GitHub:**

Abra o vscode e pressione as teclas "ctrl+shift+P", selecione a opção clonar do git, insira suas credenciais e pronto!

A partir desse momento, quando você fizer um pull editando algum arquivo do repositório o Jenkins irá startar a pipeline do terraform.

**6 - Por fim, vamos configurar a pipeline do terraform destroy**

Vá até o git > crie um novo repositório e digite um nome (ex: terraform_destroy), suba todos os arquivos do repositório usado no "terraform_pipeline" e copie o o link do seu projeto (ex: https://github.com/LGbasilio/terraform_destroy.git). 

Navegue até o dashboard do Jenkins e selecione "novo item" > digite um nome de sua preferência (ex terraform_destroy) clique em pipeline e no campo "copy from" selecione "terraform_pipeline" a que já foi criada antes só para clone, clique em save.
Clique na pipeline criada "terraform_destroy" selecione "configurar", no campo "GitHub project" mude o nome do projeto para o projeto do terraform_destroy que voc~e criou no github (ex https://github.com/LGbasilio/terraform_destroy.git), selecione "GitHub hook trigger for GITScm polling" no campo "pipeline script" copie e cole o script abaixo e clique em save.

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

**Pronto! a pipeline terraform destroy foi criada com êxito, a partir do momento que o VScode receber um pull desse projeto "terraform_destroy" o jenkins irá startar a pipeline que destruirá toda infraestrutura criada!** 





 
