DOCKER := cd docker/infra && \
	docker compose -f docker-compose.yml -f xray.yml -f xray-forward.yml \
		-f hysteria.yml -f sing-box.yml

.PHONY: open.config
open.config:
	git pull
	lockgit open -f

.PHONY: close.config
close.config:
	lockgit close

.PHONY: down.%
down.%:
	$(DOCKER) down my_$*

.PHONY: rm.image.%
rm.image.%:
	docker image rm -f jdxj/$*:latest

.PHONY: build.%
build.%:
	cd docker/infra/$* && \
		docker buildx build --no-cache -t jdxj/$*:latest .

.PHONY: up.%
up.%: open.config link.host down.% rm.image.% build.%
	$(DOCKER) up -d my_$*

.PHONY: restart.%
restart.%: open.config
	$(DOCKER) restart my_$*

.PHONY: link.host
link.host:
	ln -sf /etc/letsencrypt/live/$(shell hostname) /etc/letsencrypt/live/host
