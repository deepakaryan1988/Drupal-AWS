# 🚀 Drupal on AWS with Terraform & Docker

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Drupal](https://img.shields.io/badge/Drupal-0678BE?style=for-the-badge&logo=drupal&logoColor=white)

This repository showcases a transition from manual Drupal deployments to a modern, infrastructure-as-code (IaC) approach using Terraform and Docker on AWS.

---

### 👨‍💻 Developer Profile

I have been deploying and scaling Drupal sites on AWS since 2015, using traditional methods like manual EC2 provisioning, shared file systems (EFS), and simple Git-based rollbacks.

This project represents my professional development as I transition these manual practices into clean, maintainable, and scalable infrastructure-as-code. My goal is to build deep, production-grade knowledge of DevOps principles and create a clean, well-structured repository that reflects modern best practices.

---

### 🏗️ Project Structure

The repository is organized into the following key directories:

-   **/web/**: Contains the Drupal codebase. Core, vendor, and other generated directories are ignored via `.gitignore` to keep the repository clean.
-   **/terraform/**: Houses the modular Terraform code for provisioning AWS infrastructure.
    -   **/network/**: Defines the VPC, subnets, and internet gateway.
    -   **/ecr/**: Sets up the private Elastic Container Registry (ECR).
    -   **/ecs/**: (Work in Progress) Will define the ECS Fargate services for container orchestration.
-   **/docker/**: Includes the Dockerfile for containerizing the Drupal application.

---

### 🛠️ Tools & Stack

This project leverages a modern DevOps toolchain:

-   **Terraform**: Used for modular and reusable infrastructure-as-code. *Remote state management is the next step.*
-   **Docker**: For containerizing the Drupal application, ensuring consistency across environments.
-   **AWS**:
    -   **ECS + Fargate**: The target for container orchestration (planned).
    -   **ECR**: For storing the private Docker images.
    -   **ALB, IAM, CloudWatch Logs**: In-progress components for load balancing, security, and logging.
-   **GitHub + Copilot**: For collaborative development and CI/CD workflows.

---

### 🎯 DevOps Learning Goals

My primary learning objectives for this project are:

-   **Master ECS and CI/CD**: Implement a robust, automated pipeline for continuous integration and deployment.
-   **Real-Time Monitoring**: Integrate real-time monitoring and logging solutions to ensure application health and performance.
-   **Explore Kubernetes**: Eventually, I plan to explore Kubernetes for more complex microservice orchestration.
-   **Certification Path**: Build a job-ready portfolio that aligns with the requirements for the **Terraform Associate** and **AWS DevOps Pro** certifications.

---

### ✅ What’s Done So Far

-   [x] **Modular Terraform Structure**: Infrastructure code is organized into reusable modules.
-   [x] **Docker Image**: The Drupal application has been containerized and pushed to ECR.
-   [x] **Git Ignore**: `.gitignore` is configured for both Drupal and Terraform files.
-   [ ] **Remote State + ECS Fargate**: This is the next major implementation goal.

---

### 📄 License

This project is licensed under the MIT License.

### 👨‍💻 Author

**Deepak Kumar**

-   [GitHub](https://github.com/deepakaryan1988)
-   [LinkedIn](https://www.linkedin.com/in/deepakaryan1988)
-   [Drupal](https://www.drupal.org/u/deepakaryan1988)

---

## 🌐 Our Blog

Check out our technical blog on Hashnode: [debugdeploygrow.hashnode.dev](https://debugdeploygrow.hashnode.dev/)
