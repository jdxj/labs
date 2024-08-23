include scripts/merge.mk
include scripts/install.mk

DOCKER := cd docker/infra && \
		  docker compose -f docker-compose.yml -f sing-box.yml
INSTALL_PATH := /usr/local/bin

.PHONY: open.config
open.config:
	git pull
	lockgit open -f

.PHONY: close.config
close.config:
	lockgit close

.PHONY: up.nginx.%
up.nginx.%: open.config merge.nginx.%
	$(DOCKER) down my_nginx
	docker image prune -af
	rm -vf docker/infra/nginx/logs/*.log
	$(DOCKER) up -d my_nginx

.PHONY: clean
clean:
	@rm -vrf docker/infra/sing-box/log/access.log
