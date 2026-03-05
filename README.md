# DreamSquad — Infraestrutura Cloud com Terraform

Projeto de demonstração de infraestrutura na AWS utilizando **Terraform**, criando 3 serviços totalmente automatizados e funcionais.

## 🌟 Objetivo

Este projeto implementa uma arquitetura em nuvem escalável e de fácil reprodução, demonstrando:

- ✅ **Serviço 1**: Frontend estático via S3 Website Hosting
- ✅ **Serviço 2**: Backend em container com ECS Fargate + Application Load Balancer
- ✅ **Serviço 3**: Rotina diária automatizada com Lambda + EventBridge

## 🏗️ Arquitetura

### Serviço 1 — Frontend (S3 + Website Hosting)
- Bucket S3 público configurado para servir website estático
- Página HTML pré-carregada com branding DreamSquad
- URL do site gerada automaticamente nos outputs do Terraform

### Serviço 2 — Backend (ECS Fargate + ALB)
- VPC dedicada com 2 subnets públicas em zonas de disponibilidade diferentes
- Cluster ECS Fargate rodando container Nginx
- Application Load Balancer distribuindo tráfego
- Security Groups configurados para isolamento de rede
- CloudWatch Logs capturando logs da aplicação

### Serviço 3 — Rotina Diária (Lambda + EventBridge)
- Função Lambda em Python executada diariamente às **10:00 BRT** (13:00 UTC)
- Bucket S3 dedicado recebendo arquivos com timestamp da execução
- EventBridge (CloudWatch Events) orquestrando agendamento
- Permissões IAM granulares para Lambda acessar S3

## 📋 Pré-requisitos

- **Terraform** >= 1.3.0 instalado
- **AWS CLI** >= 2.0 configurado com credenciais
- **Conta AWS** com permissões para criar: S3, EC2 (VPC, subnets, security groups), ECS, Lambda, IAM, EventBridge, CloudWatch Logs
- **Git** (opcional, para versionar o código)

## 🚀 Como executar

### 1. Clonar ou preparar o projeto

```bash
git clone https://github.com/LucianoHMG/dreamsquad-terraform.git
cd dreamsquad-terraform
```

### 2. Inicializar Terraform

```bash
terraform init
```

Isso baixa os providers necessários (AWS, Random, Archive).

### 3. Visualizar o plano de execução

```bash
terraform plan
```

Mostra todos os recursos que serão criados. Verifique se está tudo como esperado.

### 4. Aplicar a infraestrutura

```bash
terraform apply
```

Quando perguntar `Do you want to perform these actions?`, responda:

```
yes
```

O processo leva **3 a 7 minutos**. Ao final, você verá os **Outputs** com as URLs dos serviços.

### 5. Testar os serviços

#### Frontend (S3)
```bash
# Copie a URL do output "frontend_url" e abra no navegador
# Exemplo: http://dreamsquad-frontend-f1355171.s3-website-us-east-1.amazonaws.com
```

#### Backend (ECS + ALB)
```bash
# Copie a URL do output "backend_url" e abra no navegador
# Exemplo: http://dreamsquad-alb-1651720529.us-east-1.elb.amazonaws.com
# Deve exibir "Welcome to nginx!"
```

#### Lambda + S3 (Rotina Diária)
1. Vá ao **AWS Console** → **Lambda**
2. Procure por `dreamsquad-daily-scheduler`
3. Aba **Code**, botão **Test**
4. Execute um teste manual
5. Vá a **S3** → bucket `dreamsquad-scheduler-XXXXX`
6. Verifique se apareceu um arquivo `.txt` com timestamp (ex: `2026-03-05T18:30:45Z.txt`)

## 📁 Estrutura dos arquivos

```
dreamsquad-test/
├── main.tf                # Definição de todos os recursos (VPC, S3, ECS, Lambda, etc)
├── variables.tf            # Variáveis de entrada (region)
├── outputs.tf             # Outputs (URLs dos serviços)
├── .terraform/            # Pasta do Terraform (gerada após 'terraform init')
├── .terraform.lock.hcl   # Lock file (versionamento de providers)
└── lambda_function.zip   # Arquivo Lambda (gerado automaticamente)
```

## 🔐 Segurança

- ✅ **Buckets S3**: Acesso público apenas para leitura (GetObject)
- ✅ **VPC**: Isolada com Security Groups restritivos
- ✅ **ECS**: Roda em Fargate (sem gerenciar EC2)
- ✅ **Lambda**: Usa IAM roles com permissões mínimas (least privilege)
- ✅ **Credenciais**: Configuradas via `aws configure` (não incluídas no código)

## 💰 Custos estimados

**Aviso**: Este projeto criará recursos na AWS que **geram custos**. Estimátiva para 1 mês:

- S3 buckets: ~$0.50 (storage mínimo)
- ALB: ~$16.00 (por hora de uso)
- ECS Fargate: ~$10.00 (256 CPU + 512 MB RAM)
- Lambda: ~$0.20 (milhões de invocações gratuitas)
- **Total aproximado: $30–50/mês**

Para evitar custos, execute:

```bash
terraform destroy
```

Ele pedirá confirmação e deletará tudo.

## ⚠️ Observações importantes

### Permissões AWS
Na minha conta pessoal de teste, tive que adicionar a política **AdministratorAccess** ao usuário para que o Terraform criasse todos os recursos (S3, VPC, ECS, IAM, Lambda, EventBridge).

Em um ambiente corporativo, seria mais apropriado criar uma política customizada com permissões específicas para cada serviço. Isso pode ser feito no IAM criando uma policy JSON que permita apenas as ações necessárias.

### Escalabilidade
Este projeto usa:
- **1 container ECS** em Fargate (mínimo)
- **1 execução de Lambda** por dia

Para produção, considere:
- Auto-scaling no ECS (desired_count > 1)
- Múltiplas regiões AWS para alta disponibilidade
- HTTPS/TLS nos load balancers
- RDS ou DynamoDB para persistência de dados

## 🐛 Troubleshooting

### Erro: "terraform" não é reconhecido como comando
Você não adicionou o Terraform ao PATH do sistema. Veja a [instalação oficial](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

### Erro: AccessDenied ao criar recursos
Seu usuário AWS não tem permissões suficientes. Vá em **IAM** e anexe políticas que permitam: s3:*, ec2:*, ecs:*, lambda:*, iam:*, events:*, logs:*.

### O ALB está lento para responder
O ECS pode levar alguns minutos para iniciar o container. Espere 2–3 minutos após o `terraform apply` terminar antes de testar a URL.

### Lambda não está executando na hora agendada
Verifique se a regra do EventBridge está ativa em **CloudWatch Events** → **Rules** → `dreamsquad-daily-10am-brt`.

## 📇 Outputs

Após `terraform apply`, você receberá:

```
Outputs:

backend_url = "http://dreamsquad-alb-XXXXXXXXX.us-east-1.elb.amazonaws.com"
frontend_url = "http://dreamsquad-frontend-XXXXXXXX.s3-website-us-east-1.amazonaws.com"
scheduler_bucket = "dreamsquad-scheduler-XXXXXXXX"
```

Use essas URLs para testar os serviços.

## 🎓 Aprendizados

Este projeto demonstra:

1. **Infrastructure as Code** com Terraform
2. **Provisionamento automático** de recursos AWS
3. **Networking** com VPC, subnets e security groups
4. **Containerização** com ECS Fargate
5. **Serverless** com Lambda e EventBridge
6. **Armazenamento** com S3
7. **Load balancing** com ALB
8. **Logging e monitoramento** com CloudWatch

## 📞 Suporte

Para dúvidas sobre Terraform:
- [Documentação oficial do Terraform](https://www.terraform.io/docs)
- [AWS Provider para Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

Para dúvidas sobre AWS:
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS Support](https://console.aws.amazon.com/support/)

## 📄 Licença

Este projeto é fornecido como está, sem garantias. Use por sua conta e risco.

---

**Criado em**: Março de 2026
**Última atualização**: 05/03/2026
**Status**: ✅ Funcional e testado
