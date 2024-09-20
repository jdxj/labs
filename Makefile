include scripts/merge.mk
include scripts/install.mk

DOCKER := cd docker/infra && \
		  docker compose -f docker-compose.yml -f sing-box.yml
INSTALL_PATH := /usr/local/bin

# lockgit
.PHONY: lockgit.open
lockgit.open:
	git pull
	lockgit open -f

.PHONY: lockgit.rm
lockgit.rm: lockgit.open
	@lockgit status | grep "unavailable" | awk '{print $$1}' | xargs -r lockgit rm

.PHONY: rm.lockgit
rm.lockgit: lockgit.open
	@lockgit status | grep "new file" | awk '{print $$1}' | xargs -r rm -v

.PHONY: lockgit.close
lockgit.close:
	lockgit close

.PHONY: up.nginx.%
up.nginx.%: lockgit.open merge.nginx.%
	$(DOCKER) down my_nginx
	docker image prune -af
	rm -vf docker/infra/nginx/logs/*.log
	mkdir -p /etc/letsencrypt
	$(DOCKER) up -d my_nginx

.PHONY: up.sb.%
up.sb.%: lockgit.open merge.sb.%
	rm -vf docker/infra/sing-box/log/*.log
	$(DOCKER) up -d my_sing-box

.PHONY: up.ethr
up.ethr:
	cd docker/infra/ethr && \
		docker buildx build -t jdxj/ethr .
	$(DOCKER) up -d my_ethr

.PHONY: up.mysql
up.mysql:
	$(DOCKER) up -d my_mysql

.PHONY: down.%
down.%:
	$(DOCKER) down my_$*
