# Enterprise Docker Infrastructure: Secure Multi-Container Java Application

An enterprise-grade, highly secure, and isolated multi-container architecture hosting an Apache Tomcat Java web application backed by MariaDB, Memcached, and RabbitMQ, fronted by an NGINX reverse proxy.

This project implements advanced containerization security best practices, network segmentation, health checks, resource governance, and persistent storage management using Docker Compose.

## 🏗️ Architectural Overview

The infrastructure isolates components across two dedicated Docker bridge networks, ensuring that database, caching, and message broker tiers are never directly exposed to external clients.

```text
                 END USERS (HTTP: 80)
                         |
                         v
              +----------------------+
              |     NGINX (Proxy)    |
              |  Only exposed port 80|
              +----------------------+
                         |
                  FRONTEND NETWORK
                         |
                         v
              +----------------------+
              |   Apache Tomcat      |
              |   Java Application   |
              |      Port 8080       |
              +----------------------+
                         |
             BACKEND NETWORK (internal: true)
                  +------+------+------+
                  |      |      |      |
                  v      v      v
             +--------+ +--------+ +----------+
             |MariaDB | |Memcached| | RabbitMQ |
             +--------+ +--------+ +----------+
                  |                  |
             [db_data]         [rabbitmq_data]
                  |                  |
             Persistent Named Volumes
```

### Infrastructure Components

| Tier | Service Name | Base Image | Internal Port | Host Exposure | Purpose |
|---|---|---|---|---|---|
| Edge / Proxy | `nginx` | `nginx:1.25-alpine` | `80` | `80:80` | Reverse proxy routing incoming client traffic |
| Application | `tomcat` | Custom (`tomcat:11-jre`) | `8080` | None | Executes business logic and connects to backend services |
| Database | `mariadb` | `mariadb:11` | `3306` | None | Relational data persistence (`db_data` volume) |
| Cache | `memcached` | `memcached:1.6` | `11211` | None | High-performance in-memory caching |
| Message Broker | `rabbitmq` | `rabbitmq:3.13-management` | `5672`, `15672` | None | Asynchronous messaging (`rabbitmq_data` volume) |

## 🔒 Security & Hardening Implementation

This deployment follows the **Principle of Least Privilege** across all containers.

### 1. Non-Root Execution

Services execute under dedicated non-privileged users (`user: "10001:10001"` or container-native service users) to reduce the risk of host compromise.

### 2. Linux Capability Stripping

Unnecessary Linux kernel capabilities are dropped:

```yaml
cap_drop:
  - ALL
```

Only explicitly required capabilities should be added back.

### 3. Privilege Escalation Prevention

The following security option is enforced across services:

```yaml
security_opt:
  - no-new-privileges:true
```

This prevents processes from gaining additional privileges through mechanisms such as `setuid` and `setgid`.

### 4. Read-Only Root Filesystems

Container root filesystems are locked down where applicable:

```yaml
read_only: true
```

Writable temporary directories are provided through `tmpfs` mounts, such as `/tmp`, where required.

### 5. Network Isolation

The backend network is configured with:

```yaml
internal: true
```

This isolates databases, caching, and message broker services from external network access while allowing communication between connected backend containers.

### 6. Secrets Management

Sensitive credentials, including database and RabbitMQ passwords, are kept outside container images through environment files (`.env`) and secured secret or volume mounts.

The `.env` file should not be committed to GitHub. Use `.env.example` as a template without real credentials.

### 7. Resource Governance

Explicit CPU and memory limits are configured using Docker Compose options such as:

```yaml
cpus: "1.0"
mem_limit: 512m
```

These restrictions help prevent individual containers from exhausting host resources.

## 📁 Project Directory Structure

```text
Enterprise_Docker_infrastructure_Security/
│
├── docker-compose.yml
├── .env.example
├── .gitignore
├── README.md
│
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf
│
├── tomcat/
│   ├── Dockerfile
│   └── application.war
│
├── mariadb/
│   └── init.sql
│
├── rabbitmq/
│   └── rabbitmq.conf
│
├── secrets/
│   └── .gitkeep
│
└── scripts/
    ├── deploy.sh
    ├── validate.sh
    └── backup.sh
```

## 🛠️ Technologies Used

- Docker
- Docker Compose
- Apache Tomcat
- Java
- NGINX
- MariaDB
- Memcached
- RabbitMQ
- Linux container security
- Docker networking and volumes

## 🔐 Security Objectives

The project focuses on the following security objectives:

- Minimize container privileges.
- Isolate application and backend services.
- Avoid exposing internal service ports to the host.
- Protect sensitive credentials.
- Restrict container resource consumption.
- Maintain persistent application data.
- Improve container deployment and runtime security.

## ⚠️ Important Notes

- The Docker Compose configuration is the source of truth for the actual service settings, network definitions, volume mounts, and security controls.
- Read-only filesystems and dropped capabilities must be validated against each image's runtime requirements.
- The `.env` file and actual secret values must remain outside version control.
- Named volumes provide persistence across container recreation, but they are not a substitute for backups.
- The architecture and security controls should be validated against the actual deployed Compose configuration before production use.

