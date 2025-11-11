# PoC1 - Secure Access (Authentik + JumpServer)

Automated DevOps environment for testing secure access management using Authentik SSO and JumpServer.

## 🎯 Overview

This PoC demonstrates:
- **Authentik**: Modern SSO/Identity Provider with OAuth2/OIDC
- **JumpServer**: Open-source Privileged Access Management (PAM)
- **PostgreSQL**: Shared database backend
- **Redis**: Cache and message broker

## 🚀 Quick Start

### Prerequisites
- Docker (with Compose plugin)
- Bash shell
- OpenSSL (for password generation)

### Installation

1. **Initialize Environment**
   ```bash
   bash scripts/init_env.sh
   ```
   This creates `config/.env` with auto-generated secure passwords and settings.

2. **Install Stack**
   ```bash
   bash scripts/install_stack.sh
   ```
   Or simply:
   ```bash
   bash scripts/setup.sh
   ```

3. **Validate Environment**
   ```bash
   bash scripts/test_env.sh
   ```

4. **Generate Report**
   ```bash
   bash scripts/test_env.sh | tee logs.txt
   python3 scripts/summary.py logs.txt
   ```

## 📁 Project Structure

```
poc1-secure-access/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline
├── config/
│   ├── env.sample              # Environment template
│   └── .env                    # Generated (git-ignored)
├── scripts/
│   ├── init_env.sh            # Generate .env with secrets
│   ├── install_stack.sh       # Full stack installation
│   ├── setup.sh               # Main setup wrapper
│   ├── test_env.sh            # Environment validation
│   └── summary.py             # Report generator
├── docker-compose.yml         # Service definitions
└── README.md
```

## 🔧 Configuration

The `config/.env` file contains all configuration:

- **AUTHENTIK_SECRET_KEY**: Authentik encryption key
- **AUTHENTIK_ADMIN_PASSWORD**: Admin user password
- **AUTH_CLIENT_ID**: OAuth client identifier (auto-generated with timestamp)
- **AUTH_CLIENT_SECRET**: OAuth client secret
- **POSTGRES_PASSWORD**: Database password
- **REDIS_PASSWORD**: Redis authentication
- **HOST_IP**: Auto-detected or manually set

## 🌐 Service Access

After installation, access services at:

- **Authentik**: http://localhost:9000
  - HTTPS: https://localhost:9443
  - Admin: Use credentials from `config/.env`

- **JumpServer**: http://localhost:8080
  - SSH Gateway: localhost:2222
  - Admin: Use credentials from `config/.env`

## 📊 Scripts Reference

### init_env.sh
- Detects PoC type (PoC1 or PoC2)
- Auto-generates secure passwords
- Creates AUTH_CLIENT_ID with timestamp
- Detects HOST_IP automatically
- Generates `config/.env`

### install_stack.sh
- Validates Docker dependencies
- Pulls latest images
- Starts containers with health checks
- Waits for services to be ready
- Validates accessibility
- Logs to `/tmp/install_poc.log`

### test_env.sh
- Checks Docker daemon
- Validates all containers running
- Tests Authentik health endpoint
- Verifies JumpServer accessibility
- Checks port availability (9000, 9443, 8080, 2222)
- Tests database connectivity
- Displays resource usage

### summary.py
- Parses test logs
- Detects errors and warnings
- Identifies container status
- Generates comprehensive report
- Provides recommendations

## 🔄 CI/CD Workflow

The GitHub Actions workflow (`.github/workflows/deploy.yml`) automatically:

1. Initializes environment
2. Sets up stack
3. Validates services
4. Generates summary report
5. Uploads report as artifact

## 🛠️ Troubleshooting

### View Container Logs
```bash
docker compose logs -f [service_name]
```

### Restart Services
```bash
docker compose restart
```

### Clean Install
```bash
docker compose down -v
bash scripts/setup.sh
```

### Check Service Health
```bash
# Authentik
curl http://localhost:9000/if/flow/initial-setup/

# JumpServer
curl http://localhost:8080/

# PostgreSQL
docker compose exec postgres pg_isready -U authentik

# Redis
docker compose exec redis redis-cli -a $REDIS_PASSWORD ping
```

## 📝 Development

### Manual Docker Compose
```bash
# Load environment
set -a && source config/.env && set +a

# Start services
docker compose up -d

# Stop services
docker compose down
```

### Regenerate Environment
```bash
rm config/.env
bash scripts/init_env.sh
```

## 🔒 Security Notes

- All passwords are auto-generated with OpenSSL
- `config/.env` is git-ignored (contains secrets)
- Use `config/env.sample` as reference template
- Change default passwords in production
- Enable HTTPS for production deployments

## 📄 License

See repository license file.

## 🤝 Contributing

This is a Proof of Concept for testing and development purposes.