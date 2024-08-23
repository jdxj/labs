.PHONY: merge.sb.%
merge.sb.%: open.config
	$(DOCKER) down my_sing-box
	docker image prune -af
	docker run --rm \
		-v ./config/sing-box/server:/tmp/sing-box/server \
		-v ./docker/infra/sing-box/conf:/tmp/sing-box/conf \
		ghcr.io/sagernet/sing-box \
		merge /tmp/sing-box/conf/config.json -C /tmp/sing-box/server -C /tmp/sing-box/server/$*

.PHONY: merge.app.sb.%
merge.app.sb.%: open.config
	docker run --rm \
		-v ./config/sing-box/client:/tmp/sing-box/client \
		-v ./docker/infra/nginx/app:/tmp/sing-box/conf \
		ghcr.io/sagernet/sing-box \
		merge /tmp/sing-box/conf/sing-box-$*.json \
			-C /tmp/sing-box/client -C /tmp/sing-box/client/outbounds -C /tmp/sing-box/client/$*

merge.nginx.%: output := docker/infra/nginx/conf.d
.PHONY: merge.nginx.%
merge.nginx.%: open.config
	rm -vf $(output)/*.conf
	cp -f config/nginx/$*_*.conf $(output)
