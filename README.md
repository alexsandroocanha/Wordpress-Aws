<h1 align="center">WordPress na AWS (Prod)</h1>
<p align="center"> <i>EC2 (ASG) + ALB + RDS MySQL + EFS, provisionado com <strong>Terraform</strong> e pronto para escala. </i></p>

## Visão Geral

```
Objetivo: Hospedar WordPress altamente disponivel em EC2 com Auto Scaling atrás de ALB, com banco de dados RDS MySQL e armazenamento de mídia no EFS
``` 
**Repositório criado 10/09/2025**


## Requisitos 

* _Terraform ≥ 1.6 (sugestão: tfenv)_
* _AWS CLI v2 autenticado (IAM User ou SSO)_
* _Permissões para criar: VPC, ALB, EC2/ASG, RDS, EFS_

### Arquitetura
![alt text](image.png)
 * VPC (2 AZs) → Subnets públicas (ALB/NAT) e privadas (EC2/RDS/EFS)
 * ALB (HTTP/HTTPS) → Target Group (EC2)
 * EC2 (Docker/Compose) → EFS (wp-content) e RDS (MySQL)

### Componentes & Responsabilidades

> * ALB/TG: tráfego, health-check.
> * ASG/LT: escala, user_data, AMI.
> * EC2: Docker + Compose (WordPress), montagem EFS.
> * RDS: banco gerenciado, snapshots, parâmetros.
> * EFS: conteúdo WP compartilhado.

## Variáveis Principais

**Variaveis de ambiente:**

> * **ec2_tags** - Tags da Ec2 e do Template do Auto Scaling
> * **profile** - Seu usuario do SSO
> * **region** - Região dos serviços
> * **db_passwd** - Senha do Banco de dados
> * **ami-instance** - AMI Das instancias EC2


### Informações para Contato

[![Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/alexsandro-ocanha-rodrigues-77149a35b/)
[![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/alexsandro.pcap/)
[![Gmail](https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:alexsandroocanha@gmail.com)