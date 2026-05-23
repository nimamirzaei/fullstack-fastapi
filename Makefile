COMPOSE=docker compose

DEV_ENV=--env-file .env.dev
PROD_ENV=--env-file .env.prod

DEV_FILES=-f docker-compose.yml -f docker-compose.override.yml
PROD_FILES=-f docker-compose.traefik.yml -f docker-compose.yml

.PHONY: help dev dev-build dev-down dev-logs \
        prod prod-build prod-down prod-logs \
        config-dev config-prod \
        traefik-network clean

help:
	@echo "FastAPI + Traefik Project - Available Commands"
	@echo ""
	@echo "Development:"
	@echo "  make dev             - Start development environment"
	@echo "  make dev-build       - Build and start development environment"
	@echo "  make dev-down        - Stop development environment"
	@echo "  make dev-logs        - Stream development logs"
	@echo "  make config-dev      - Validate and print dev compose config"
	@echo ""
	@echo "Production:"
	@echo "  make prod            - Start production environment"
	@echo "  make prod-build      - Build and start production environment"
	@echo "  make prod-down       - Stop production environment"
	@echo "  make prod-logs       - Stream production logs"
	@echo "  make config-prod     - Validate and print prod compose config"
	@echo ""
	@echo "Maintenance:"
	@echo "  make traefik-network - Create traefik-public network"
	@echo "  make clean           - Stop and remove all containers and volumes"

# =========================
# Development
# =========================

dev:
	$(COMPOSE) $(DEV_ENV) $(DEV_FILES) up -d

dev-build:
	$(COMPOSE) $(DEV_ENV) $(DEV_FILES) up -d --build

dev-down:
	$(COMPOSE) $(DEV_ENV) $(DEV_FILES) down

dev-logs:
	$(COMPOSE) $(DEV_ENV) $(DEV_FILES) logs -f

config-dev:
	$(COMPOSE) $(DEV_ENV) $(DEV_FILES) config

# =========================
# Production
# =========================

traefik-network:
	docker network create traefik-public 2>/dev/null || true

prod: traefik-network
	$(COMPOSE) $(PROD_ENV) $(PROD_FILES) up -d

prod-build: traefik-network
	$(COMPOSE) $(PROD_ENV) $(PROD_FILES) up -d --build

prod-down:
	$(COMPOSE) $(PROD_ENV) $(PROD_FILES) down

prod-logs:
	$(COMPOSE) $(PROD_ENV) $(PROD_FILES) logs -f

config-prod:
	$(COMPOSE) $(PROD_ENV) $(PROD_FILES) config

# =========================
# Cleanup
# =========================

clean:
	$(COMPOSE) $(DEV_ENV) $(DEV_FILES) down -v --remove-orphans || true
	$(COMPOSE) $(PROD_ENV) $(PROD_FILES) down -v --remove-orphans || true