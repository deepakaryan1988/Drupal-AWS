# Drupal-AWS Infrastructure Architecture Overview

## Executive Summary

This document provides a comprehensive overview of the Drupal-AWS infrastructure, demonstrating a modern cloud-native architecture that leverages AWS managed services for high availability, scalability, and operational efficiency. The system is built using Infrastructure as Code (IaC) principles with Terraform, ensuring consistency, version control, and repeatable deployments.

## System Architecture

### High-Level Architecture Diagram

```
Internet
    ↓
Application Load Balancer (ALB)
    ↓
ECS Fargate Service
    ↓
Drupal Container (PHP 8.3 + Apache)
    ↓
RDS MySQL Database
```

## Core Components & Communication Flow

### 1. Network Infrastructure (`terraform/network/`)

**Purpose**: Establishes the foundational networking layer with high availability and security.

**Components**:
- **VPC**: Isolated network environment with custom CIDR block
- **Internet Gateway**: Provides internet connectivity for public resources
- **Public Subnets**: Deployed across 2 availability zones for fault tolerance
- **Route Tables**: Configured for internet routing
- **Security Groups**: Network-level access control

**Key Features**:
- Multi-AZ deployment for high availability
- Configurable ingress ports via variables
- Proper network segmentation

### 2. Container Registry (`terraform/ecr/`)

**Purpose**: Secure, managed Docker image repository for application artifacts.

**Components**:
- **ECR Repository**: Stores versioned Drupal Docker images
- **Image Scanning**: Automated vulnerability scanning on push
- **Lifecycle Policies**: Configurable image retention and cleanup

**Integration**:
- ECS tasks pull images using IAM roles
- Supports immutable tags for deployment consistency
- Integrates with AWS security services

### 3. Application Layer (`terraform/ecs/`)

**Purpose**: Containerized application hosting with automatic scaling and load balancing.

#### Application Load Balancer (ALB)
- **Protocol**: HTTP on port 80
- **Health Checks**: 30-second intervals on `/` endpoint
- **Target Groups**: IP-based targeting for Fargate compatibility
- **Security**: Dedicated security group for ALB traffic

#### ECS Fargate Service
- **Launch Type**: Fargate (serverless container execution)
- **Scaling**: Configurable desired count with auto-scaling capabilities
- **Networking**: AWS VPC networking with public IP assignment
- **Load Balancer Integration**: Seamless ALB integration for traffic distribution

#### ECS Task Definition
- **Container**: Drupal application with PHP 8.3 and Apache
- **Resources**: Configurable CPU and memory allocation
- **Logging**: CloudWatch integration for centralized log management
- **IAM Roles**: Separate execution and task roles for security

### 4. Database Layer (`terraform/rds/`)

**Purpose**: Managed relational database service with automated backups and maintenance.

**Components**:
- **RDS MySQL 8.0**: Production-ready database engine
- **Multi-AZ**: Optional high availability deployment
- **Security Groups**: Database-specific access control
- **Subnet Groups**: Network placement configuration

**Security Features**:
- Encrypted storage and connections
- Automated backups with configurable retention
- Security group isolation from public internet

## Data Flow & Service Communication

### External Traffic Flow
```
Internet → ALB (Port 80) → Target Group → ECS Task (Port 80) → Drupal Container
```

### Internal Service Communication
```
ECS Task → RDS Security Group → MySQL Database (Port 3306)
```

### Infrastructure Dependencies
```
Network → ECR → RDS → ECS (with ALB)
```

## Security Architecture

### Identity and Access Management (IAM)
- **ECS Task Execution Role**: Permissions for ECR image pulling and CloudWatch logging
- **ECS Task Role**: Application-level AWS service access (extensible)
- **Principle of Least Privilege**: Minimal required permissions for each role

### Network Security
- **ALB Security Group**: HTTP ingress from internet, full egress
- **ECS Security Group**: Traffic from ALB, egress to RDS
- **RDS Security Group**: MySQL ingress from ECS security group only
- **VPC Isolation**: All resources deployed within private VPC

### Data Security
- **Encryption at Rest**: RDS storage encryption enabled
- **Encryption in Transit**: TLS/SSL for database connections
- **Secrets Management**: Database credentials managed securely

## Monitoring & Observability

### Logging
- **CloudWatch Logs**: Centralized logging for all ECS tasks
- **Log Retention**: Configurable retention policies
- **Structured Logging**: Application logs with metadata

### Health Monitoring
- **ALB Health Checks**: Application-level health monitoring
- **RDS Monitoring**: Database performance and availability metrics
- **CloudWatch Metrics**: Infrastructure and application metrics

### Alerting
- **CloudWatch Alarms**: Configurable alerts for critical metrics
- **SNS Integration**: Notification delivery for operational events

## Deployment Strategy

### Infrastructure Deployment
1. **Terraform Apply**: Infrastructure provisioning and configuration
2. **Dependency Resolution**: Automatic handling of resource dependencies
3. **State Management**: Consistent infrastructure state tracking

### Application Deployment
1. **Image Build**: Docker image creation with application code
2. **ECR Push**: Secure image storage in container registry
3. **ECS Update**: Rolling deployment with zero-downtime
4. **Health Validation**: ALB health checks ensure deployment success

## Scalability & Performance

### Horizontal Scaling
- **ECS Auto Scaling**: Automatic scaling based on CPU/memory utilization
- **Load Distribution**: ALB distributes traffic across multiple containers
- **Multi-AZ Deployment**: Fault tolerance across availability zones

### Performance Optimization
- **Fargate Spot**: Cost optimization for non-critical workloads
- **Connection Pooling**: Database connection optimization
- **CDN Integration**: Ready for CloudFront integration

## Cost Optimization

### Resource Efficiency
- **Fargate**: Pay-per-use container execution
- **RDS**: Managed database service with predictable pricing
- **ALB**: Pay-per-request load balancing

### Operational Efficiency
- **Infrastructure as Code**: Reduced manual configuration time
- **Automated Scaling**: Optimal resource utilization
- **Managed Services**: Reduced operational overhead

## Disaster Recovery

### Backup Strategy
- **RDS Automated Backups**: Point-in-time recovery capability
- **Cross-Region Replication**: Optional disaster recovery setup
- **Infrastructure State**: Terraform state backup and versioning

### Recovery Procedures
- **RTO/RPO**: Defined recovery time and point objectives
- **Failover Testing**: Regular disaster recovery validation
- **Documentation**: Comprehensive recovery runbooks

## Compliance & Governance

### Security Standards
- **AWS Well-Architected Framework**: Follows security best practices
- **CIS Benchmarks**: Security configuration compliance
- **Audit Logging**: Comprehensive activity logging

### Operational Standards
- **Change Management**: Infrastructure changes via version control
- **Testing**: Automated infrastructure validation
- **Documentation**: Comprehensive system documentation

## Future Enhancements

### Planned Improvements
- **CI/CD Pipeline**: Automated deployment pipeline integration
- **Monitoring Dashboard**: Custom CloudWatch dashboards
- **Security Scanning**: Container and infrastructure security scanning
- **Cost Monitoring**: Detailed cost allocation and optimization

### Scalability Roadmap
- **Kubernetes Migration**: EKS for advanced orchestration needs
- **Microservices**: Application decomposition for independent scaling
- **Serverless Integration**: Lambda functions for specific workloads

## Conclusion

This architecture demonstrates modern cloud-native principles with a focus on security, scalability, and operational excellence. The use of AWS managed services reduces operational overhead while providing enterprise-grade reliability and performance. The Infrastructure as Code approach ensures consistency, version control, and repeatable deployments across environments.

The system is designed to be production-ready with built-in high availability, security, and monitoring capabilities. It serves as an excellent foundation for scaling Drupal applications in the cloud while maintaining operational efficiency and cost optimization.
