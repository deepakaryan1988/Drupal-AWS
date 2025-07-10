
# 🚀 Drupal on AWS with Terraform & Lando

This repository contains a Drupal 11 project configured for local development with Lando and infrastructure-as-code using Terraform to provision an EC2 instance on AWS. It serves as a portfolio project to demonstrate modern DevOps practices for managing a Drupal application.

## ✨ Project Overview

The primary goal of this project is to showcase a streamlined workflow for developing a Drupal site locally and deploying it to a cloud environment. It combines the power of Drupal 11, the simplicity of Lando for local development, and the robustness of Terraform for infrastructure automation.

## 🛠️ Tech Stack

| Technology | Description |
| :--- | :--- |
| **Drupal 11** | The latest version of the powerful open-source content management system. |
| **Lando** | A free, open-source, and cross-platform local development environment and DevOps tool. |
| **Docker** | The underlying containerization technology used by Lando. |
| **Terraform** | An open-source infrastructure as code software tool. |
| **AWS** | Amazon Web Services, the cloud platform where the infrastructure is provisioned. |

## ⚙️ Setup Instructions

### Prerequisites

- [Lando](https://lando.dev/download/)
- [Docker](https://www.docker.com/products/docker-desktop)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [AWS CLI](https://aws.amazon.com/cli/)

### Local Setup with Lando

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/Drupal-AWS.git
    cd Drupal-AWS
    ```

2.  **Start Lando:**
    ```bash
    lando start
    ```

3.  **Install Drupal:**
    Use Lando to run Composer to install the Drupal dependencies.
    ```bash
    lando composer install
    ```
    Follow the on-screen instructions to complete the Drupal installation in your browser. You can get the site URL by running `lando info`.

##  Terraform Usage

The Terraform code in `terraform/ec2/` will provision a new EC2 instance on AWS.

1.  **Navigate to the Terraform directory:**
    ```bash
    cd terraform/ec2
    ```

2.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

3.  **Plan the infrastructure:**
    ```bash
    terraform plan
    ```

4.  **Apply the changes:**
    ```bash
    terraform apply
    ```

## 🌐 Demo and Access

This project is designed to be a template. The EC2 instance provisioned by Terraform is a bare-bones server. The next steps, which are not yet implemented, would be to:

-   Configure the EC2 instance with a web server (e.g., Nginx), PHP, and other required dependencies.
-   Deploy the Drupal site to the EC2 instance.
-   Set up a CI/CD pipeline to automate the deployment process.

## 📂 Project Structure

```
.
├── .lando.yml
├── composer.json
├── recipes
│   └── README.txt
├── terraform
│   └── ec2
│       ├── main.tf
│       └── outputs.tf
└── web
    ├── modules
    ├── profiles
    ├── sites
    └── themes
```

| File/Folder | Description |
| :--- | :--- |
| **`.lando.yml`** | Lando configuration file for local development. |
| **`composer.json`** | PHP dependency management. |
| **`recipes`** | Lando recipes and custom scripts. |
| **`terraform/ec2`** | Terraform code for the EC2 instance. |
| **`web`** | The Drupal web root. |

## 📋 Common Commands

### Lando

| Command | Description |
| :--- | :--- |
| `lando start` | Start the Lando environment. |
| `lando stop` | Stop the Lando environment. |
| `lando rebuild` | Rebuild the Lando containers. |
| `lando info` | Get information about the Lando environment, including the site URL. |
| `lando composer ...` | Run Composer commands. |
| `lando drush ...` | Run Drush commands. |

### Terraform

| Command | Description |
| :--- | :--- |
| `terraform init` | Initialize the Terraform configuration. |
| `terraform plan` | Create an execution plan. |
| `terraform apply` | Apply the changes required to reach the desired state. |
| `terraform destroy` | Destroy the Terraform-managed infrastructure. |

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**

-   [GitHub](https://github.com/deepakaryan1988)
-   [LinkedIn](https://www.linkedin.com/in/deepakaryan1988)
-   [Drupal](https://www.drupal.org/u/deepakaryan1988)
