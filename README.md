# 🚀 Infraestructura Escalable y Resiliente en AWS con Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.17+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![HTTPS](https://img.shields.io/badge/HTTPS-TLS%201.3%20%7C%20ACM-blue)](https://aws.amazon.com/certificate-manager/)
[![Architecture](https://img.shields.io/badge/Architecture-Multi--AZ%20%7C%20Zero--Trust-22c55e)](#-arquitectura-en-la-nube)
[![Hardening](https://img.shields.io/badge/Hardening-Anti--Fingerprinting-orange)](#-seguridad-y-buenas-prácticas)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Infraestructura como Código (IaC) modular, profesional y de alta disponibilidad desplegada en **AWS** con **Terraform**. 

Incorpora una arquitectura multicapa distribuida en dos Zonas de Disponibilidad (**Multi-AZ**), balanceo de carga con cifrado **HTTPS** y redirección 301 (**ALB**), auto-escalado de cómputo en subredes privadas (**EC2 + ASG**), acceso administrativo seguro sin SSH (**AWS SSM**), integración serverless desacoplada (**AWS Lambda**), *hardening* contra reconocimiento (*anti-fingerprinting*) y control de accesos de mínimo privilegio (**AWS IAM**).

---

## 📑 Tabla de Contenidos

- [🏛️ Arquitectura en la Nube](#️-arquitectura-en-la-nube)
- [📂 Estructura del Proyecto](#-estructura-del-proyecto)
- [⚙️ Requisitos Previos](#️-requisitos-previos)
- [🚀 Guía de Despliegue Rápido](#-guía-de-despliegue-rápido)
- [🧪 Pruebas y Verificación](#-pruebas-y-verificación)
- [🛡️ Seguridad y Buenas Prácticas](#️-seguridad-y-buenas-prácticas)
- [🧹 Destrucción de Recursos](#-destrucción-de-recursos)

---

## 🏛️ Arquitectura en la Nube

```mermaid
flowchart TD
    subgraph Internet ["🌐 Internet / Clientes"]
        Client["Clientes Web (HTTPS:443 / HTTP:80)"]
        Admin["Administradores / DevOps"]
    end

    subgraph AWS ["☁️ AWS Cloud (eu-west-1)"]
        subgraph VPC ["VPC: 10.0.0.0/16"]
            IGW["Puerta de Enlace (Internet Gateway)"]

            subgraph PublicSubnets ["🚪 Subredes Públicas (eu-west-1a & eu-west-1c)"]
                ALB["⚖️ Application Load Balancer (ALB)<br/>• Listener HTTPS :443 (Certificado TLS)<br/>• Listener HTTP :80 (Redirección 301)"]
                NAT["🔄 NAT Gateway"]
            end

            subgraph PrivateSubnets ["🛡️ Subredes Privadas (eu-west-1a & eu-west-1c)"]
                ASG["Auto Scaling Group (min: 2, max: 4)"]
                EC2_A["🖥️ Instancia Privada 1 (eu-west-1a)<br/>Servidor Web Hardened"]
                EC2_B["🖥️ Instancia Privada 2 (eu-west-1c)<br/>Servidor Web Hardened"]
            end
        end

        Lambda["⚡ Servicio Backend Serverless<br/>Function URL con CORS Seguro"]
        SSM["🔒 AWS Systems Manager (SSM)<br/>Session Manager"]
    end

    %% Flujos de tráfico
    Client -->|1. Petición HTTPS:443| IGW
    Client -.->|HTTP:80 Redirección 301| ALB
    IGW --> ALB
    ALB -->|2. Tráfico descifrado HTTP:80 en red interna| EC2_A
    ALB -->|2. Tráfico descifrado HTTP:80 en red interna| EC2_B

    %% Conexión Backend
    Client -.->|3. Invocación AJAX/Fetch| Lambda

    %% Administración
    Admin -->|Consola / AWS CLI| SSM
    SSM -->|Conexión directa interna (Sin SSH)| EC2_A
    SSM -->|Conexión directa interna (Sin SSH)| EC2_B

    %% Salida NAT
    EC2_A -.->|Descarga paquetes Linux| NAT
    EC2_B -.->|Descarga paquetes Linux| NAT
    NAT -.-> IGW
```

---

## 📂 Estructura del Proyecto

El código está organizado siguiendo las mejores prácticas oficiales de HashiCorp en **módulos reutilizables e independientes**:

```text
terraform-infrastructure/
├── modules/
│   ├── vpc/             # Red: VPC, Subredes Públicas/Privadas, IGW y NAT Gateway
│   ├── alb/             # Balanceador: ALB HTTPS (:443), Redirección 301 (:80), ACM TLS y SG
│   ├── ec2/             # Cómputo: Launch Template, User Data hardened y Rol IAM SSM
│   ├── autoscaling/     # Escalado: Auto Scaling Group con deregistration_delay = 30s
│   ├── lambda/          # Serverless: Función Backend y Function URL con CORS limpio
│   └── iam/             # Seguridad: Roles, Políticas y Grupo para Desarrolladores
│
├── environments/        # Ambientes aislados para producción y desarrollo
│   ├── dev/             # Entorno de Desarrollo (Instancias t3.micro)
│   └── prod/            # Entorno de Producción (Instancias t3.small, NAT habilitado)
│
├── main.tf              # Orquestador raíz que conecta todos los módulos
├── variables.tf         # Definición de variables globales y tipos
├── outputs.tf           # URLs públicas y valores resultantes del despliegue
├── providers.tf         # Proveedores de AWS, Archive y TLS
├── terraform.tfvars     # Valores asignados a las variables
└── README.md            # Documentación técnica del proyecto
```

---

## ⚙️ Requisitos Previos

Antes de comenzar, asegúrate de tener instaladas y configuradas las siguientes herramientas en tu equipo:

1. **[Terraform CLI](https://developer.hashicorp.com/terraform/install)** (versión `>= 1.5.0`).
2. **[AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)** instalado.
3. Una cuenta de AWS con permisos para crear recursos de VPC, EC2, IAM, ELB, ACM y Lambda.

### Configuración de credenciales de AWS

Configura tu sesión de AWS antes de ejecutar Terraform:

```powershell
aws configure
```
*(Introduce tu Access Key ID, Secret Access Key y como región por defecto `eu-west-1`).*

Si utilizas AWS IAM Identity Center (SSO) o sesión de AWS CLI:
```powershell
aws login
```

---

## 🚀 Guía de Despliegue Rápido

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/terraform-infrastructure.git
cd terraform-infrastructure
```

### 2. Configurar variables (`terraform.tfvars`)
Personaliza el archivo [terraform.tfvars](terraform.tfvars) según tus necesidades:

```hcl
aws_region         = "eu-west-1"
environment        = "dev"
instance_type      = "t3.micro"
key_name           = "user1"
enable_nat_gateway = true
```

### 3. Inicializar el entorno
Descarga los proveedores necesarios (`aws`, `archive`, `tls`) e inicializa los módulos:

```powershell
terraform init
```

### 4. Revisar el plan de ejecución
Genera una previsualización de todos los recursos que se van a crear:

```powershell
terraform plan
```

### 5. Aplicar la infraestructura
Despliega todos los recursos en tu cuenta de AWS:

```powershell
terraform apply
```
*(Escribe `yes` cuando te solicite confirmación).*

---

## 🧪 Pruebas y Verificación

Una vez finalizado el `apply`, Terraform mostrará las salidas del despliegue:

```text
Outputs:

alb_dns_name = "https://app-alb-dev-xxxxxxxx.eu-west-1.elb.amazonaws.com"
lambda_function_url = "https://xxxxxxxx.lambda-url.eu-west-1.on.aws/"
asg_name = "app-asg-dev-xxxx"
vpc_id = "vpc-0123456789abcdef0"
```

### 1. Probar el Balanceador HTTPS y Redirección 301
Abre la URL segura de `alb_dns_name` (`https://...`) en tu navegador web:
* Si intentas entrar por `http://`, el balanceador te redirige automáticamente a `https://` con código HTTP 301.
* Al recargar la página (o en modo incógnito), el balanceador alternará entre la instancia de `eu-west-1a` y la de `eu-west-1c` en sus subredes privadas.

### 2. Probar la Integración con el Backend Serverless
* En el portal web servido por la instancia privada, haz clic en el botón verde **"Consultar Servicio Backend"**.
* El navegador realizará una llamada segura a la `lambda_function_url` y verás la respuesta procesada en tiempo real (`200 OK`).

### 3. Acceso Administrativo Seguro (AWS SSM)
Las instancias no tienen IP pública ni el puerto 22 abierto. Para conectarte por terminal a cualquier máquina:

1. Ve a la consola de AWS > **EC2** > **Instances**.
2. Selecciona cualquiera de las instancias creadas.
3. Haz clic en **Connect** > pestaña **Session Manager** > **Connect**.
4. Se abrirá una sesión interactiva de Bash directamente en tu navegador sin requerir llaves SSH ni abrir puertos.

---

## 🛡️ Seguridad y Buenas Prácticas

| Característica | Implementación en este proyecto |
| :--- | :--- |
| **Cifrado en Tránsito (HTTPS)** | Terminación SSL/TLS en el ALB mediante certificado ACM y política moderna `ELBSecurityPolicy-TLS13-1-2-2021-06`. Redirección obligatoria de HTTP a HTTPS. |
| **Protección Anti-Fingerprinting** | `ServerTokens Prod` y `ServerSignature Off` en servidores web para no revelar versiones de software ni distribución de Linux. Respuesta de Lambda limpia sin exponer lenguaje de ejecución. |
| **Backend Remoto Económico** | Almacenamiento del estado en **Bucket S3** con cifrado gratuito SSE-S3 (`AES256`), bloqueo nativo (`use_lockfile = true`) y regla de ciclo de vida que purga versiones viejas a los 30 días para no acumular costes. |
| **Aislamiento de Red** | Instancias EC2 desplegadas exclusivamente en **Subredes Privadas** sin IP pública. |
| **Firewall Zero-Trust** | El Security Group de las EC2 solo admite tráfico HTTP si procede estrictamente del Security Group del ALB. |
| **Zero Root Policy** | Módulo `iam` con el rol `infra-developer-role` y el grupo `developers-group` para que el equipo nunca use la cuenta root. |
| **Gestión sin SSH** | Cero puertos de gestión abiertos al exterior; administración delegada en **AWS Systems Manager (SSM)**. |
| **Drenado Rápido** | `deregistration_delay = 30` en el Target Group para optimizar el tiempo de ciclo de vida del Auto Scaling Group. |
| **Resiliencia Multi-AZ** | Subredes y cómputo distribuidos entre `eu-west-1a` y `eu-west-1c` con tolerancia a fallos. |
| **Estado Local Seguro** | El archivo `.gitignore` excluye `.tfstate` y directorios `.terraform/` recursivamente. |

---

## 🧹 Destrucción de Recursos

Para evitar cargos continuados en tu cuenta de AWS cuando no vayas a utilizar la infraestructura, elimina todos los recursos con un solo comando:

```powershell
terraform destroy
```
*(Escribe `yes` cuando te solicite confirmación).*
