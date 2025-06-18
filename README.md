
---


# Drupal-AWS

This is a **Drupal 11** starter project pre-configured with **Lando** for local development and intended for deployment to **AWS** infrastructure.

---

## 🔧 Project Overview

- **Framework**: Drupal 11
- **Local Dev Environment**: Lando (PHP 8.1, MariaDB, Nginx)
- **Deployment Target**: AWS (EC2, RDS, S3, etc.)
- **Version Control**: Git + GitHub

---

## 📦 Prerequisites

Make sure you have the following installed:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Lando](https://docs.lando.dev/basics/installation.html)
- [Composer](https://getcomposer.org/) (used inside Lando)
- A GitHub account with this repository cloned

---

## 🚀 Getting Started (Local Setup)

1. **Clone the repository and navigate into it**
   ```bash
   git clone git@github.com:deepakaryan1988/Drupal-AWS.git && cd Drupal-AWS

2. **Start the Lando environment**

   ```bash
   lando start
   ```

3. **Install Drupal site**

   ```bash
   lando drush site:install
   ```

4. **Access the Drupal site in your browser**

   Open:

   ```
   http://drupal-aws.lndo.site
   ```

   > Or copy the URL shown in the terminal after `lando start`

---

## 🧰 Common Lando Commands

| Action                  | Command                          |
| ----------------------- | -------------------------------- |
| Start environment       | `lando start`                    |
| Stop environment        | `lando stop`                     |
| Rebuild containers      | `lando rebuild`                  |
| Drush command (e.g. cr) | `lando drush cr`                 |
| Composer install/update | `lando composer install`         |
| Access MySQL            | `lando mysql -u drupal -pdrupal` |
| Access shell            | `lando ssh`                      |

---

## ☁️ AWS Deployment (Upcoming)

Coming soon in this project:

* Infrastructure as Code (IaC) via Terraform
* EC2 setup for hosting Drupal
* RDS (MariaDB) for database
* S3 for media storage
* CloudFront CDN (optional)

---

## 📂 Project Structure

```
Drupal-AWS/
├── .lando.yml           # Lando environment config
├── composer.json        # Drupal and PHP dependencies
├── web/                 # Drupal web root
└── README.md            # Project guide
```

---

## 👤 Maintainer

Deepak Aryan
🔗 [github.com/deepakaryan1988](https://github.com/deepakaryan1988)

---

## 📃 License

This project is licensed under the MIT License.

```

---

Let me know once you've committed it — and I’ll guide you through the next AWS setup steps.
```
