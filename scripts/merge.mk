.PHONY: merge.sb.%
merge.sb.%: lockgit.open
	$(DOCKER) down my_sing-box
	docker image prune -af
	docker run --rm \
		-v ./config/sing-box/server:/tmp/server \
		-v sing-box:/tmp/sing-box \
		ghcr.io/sagernet/sing-box \
		merge /tmp/sing-box/conf/config.json -C /tmp/server -C /tmp/server/$*

.PHONY: merge.app.sb.%
merge.app.sb.%: lockgit.open
	docker run --rm \
		-v ./config/sing-box/client:/tmp/sing-box/client \
		-v ./docker/infra/nginx/app:/tmp/sing-box/conf \
		ghcr.io/sagernet/sing-box:latest-beta \
		merge /tmp/sing-box/conf/sing-box-$*.json \
			-C /tmp/sing-box/client -C /tmp/sing-box/client/outbounds -C /tmp/sing-box/client/$*

merge.nginx.%: output := docker/infra/nginx/conf.d
.PHONY: merge.nginx.%
merge.nginx.%: lockgit.open
	rm -vf $(output)/*.conf
	cp -f config/nginx/$*_*.conf $(output)
