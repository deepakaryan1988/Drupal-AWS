# Drupal-AWS

This is a Drupal 11 starter project pre-configured with Lando for local development and intended for deployment to AWS infrastructure.

## 🔧 Project Overview

- **Framework**: Drupal 11
- **Local Dev Environment**: Lando (PHP, MariaDB, Nginx)
- **Deployment Target**: AWS (EC2, RDS, S3, etc.)
- **Version Control**: Git + GitHub

---

## 📦 Prerequisites

- [Lando](https://docs.lando.dev/basics/installation.html)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- PHP 8.1+ (configured by Lando)
- Composer 2.x

---

## 🚀 Getting Started (Local Setup)

1. **Clone the repository**
   ```bash
   git clone git@github.com:deepakaryan1988/Drupal-AWS.git
   cd Drupal-AWS
2. **Start Lando**
  ```bash
   lando start
3. **Install Drupal**
  ```bash
   lando drush site:install
4. **Access the Site**
- [Visit](http://drupal-aws.lndo.site)
 (or check the URL in your terminal after lando start)