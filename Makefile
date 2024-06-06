DOCKER := cd docker/infra && \
		  docker compose -f docker-compose.yml -f xray.yml -f xray-forward.yml -f hysteria.yml -f sing-box.yml

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
up.%: open.config down.% rm.image.% build.%
	$(DOCKER) up -d my_$*

.PHONY: restart.%
restart.%: open.config
	$(DOCKER) restart my_$*

merge.sb.%: output := docker/infra/sing-box/conf/config.json
merge.sb.%: path_config := config/sing-box/server
.PHONY: merge.sb.%
merge.sb.%: open.config
	sing-box merge $(output) \
		-c $(path_config)/01_log.json \
		-c $(path_config)/02_dns.json \
		-c $(path_config)/03_inbounds_$*.json \
		-c $(path_config)/04_outbounds.json \
		-c $(path_config)/05_route.json
	sing-box check -c $(output)

merge.app: output     := docker/infra/nginx/app/sing-box.json
merge.app: output_dev := docker/infra/nginx/app/sing-box-dev.json
merge.app: path_config := config/sing-box/client
merge.app: args := -c $(path_config)/02_dns.json \
				   -c $(path_config)/03_inbounds.json \
				   -c $(path_config)/04_outbounds.json \
				   -c $(path_config)/05_route.json \
				   -c $(path_config)/06_experimental.json
.PHONY: merge.app
merge.app: open.config
	sing-box merge $(output) $(args) -c $(path_config)/01_log.json
	sing-box check -c $(output)
	sing-box merge $(output_dev) $(args) -c $(path_config)/01_log_dev.json
	sing-box check -c $(output_dev)

merge.nginx.%: output := docker/infra/nginx/conf.d
.PHONY: merge.nginx.%
merge.nginx.%: open.config
	rm -vf $(output)/*.conf
	cp -f config/nginx/$*_*.conf $(output)
