# lockgit start ---

.PHONY: open.config
open.config:
	lockgit open -f

# lockgit end

# xray start ---

.PHONY: down.xray
down.xray:
	cd docker/infra && \
		docker compose -f docker-compose.yml -f xray.yml down my_xray

.PHONY: rm.image.xray
rm.image.xray:
	docker image rm -f jdxj/xray:latest

.PHONY: build.xray
build.xray: open.config
	cd docker/infra/xray && \
		docker buildx build --no-cache -t jdxj/xray:latest .

.PHONY: up.xray
up.xray: down.xray rm.image.xray build.xray
	cd docker/infra && \
		docker compose -f docker-compose.yml -f xray.yml up -d my_xray

.PHONY: restart.xray
restart.xray:
	cd docker/infra && \
		docker compose -f docker-compose.yml -f xray.yml restart my_xray

# xray end
