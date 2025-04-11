
### Divisão do projeto
api-crud-terraform/
│
├── main.tf             # provider + recursos principais
├── variables.tf        # variáveis de entrada
├── outputs.tf          # o que será exibido após `apply`
├── lambda/
│   └── handler.py      # código da lambda Python


### Comandos

#### Inicializa o projeto
Prepara seu projeto, baixa os plugins necessários (como o da AWS) e cria a pasta .terraform.
```bash
terraform init
```

#### Mostra o que será criado
Mostra uma "prévia" das mudanças que o Terraform fará na AWS. Não cria nada ainda.
```bash
terraform plan
```

#### Aplica e cria a infra
Aplica as mudanças e realmente cria sua infraestrutura na AWS.
```bash
terraform apply
```

Comando para fazer o zip da pasta
```zip lambda_payload.zip handler.py```


Consultar a url/endpoint da api gateway
```terraform output api_endpoint```

