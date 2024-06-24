merge.sb.%: output := docker/infra/sing-box/conf/config.json
merge.sb.%: path_config := config/sing-box/server
.PHONY: merge.sb.%
merge.sb.%: open.config
	sing-box merge $(output) -C $(path_config) -C $(path_config)/$*
	sing-box check -c $(output)

merge.app: output     := docker/infra/nginx/app/sing-box.json
merge.app: output_dev := docker/infra/nginx/app/sing-box-dev.json
merge.app: path_config := config/sing-box/client
merge.app: args := -c $(path_config)/02_dns.json \
				   -c $(path_config)/03_inbounds.json \
				   -c $(path_config)/04_outbounds.json \
				   -c $(path_config)/06_experimental.json
.PHONY: merge.app
merge.app: open.config
	sing-box merge $(output) $(args) \
		-c $(path_config)/01_log.json \
		-c $(path_config)/05_route.json
	sing-box check -c $(output)
	sing-box merge $(output_dev) $(args) \
		-c $(path_config)/01_log_dev.json \
		-c $(path_config)/05_route_dev.json
	sing-box check -c $(output_dev)

merge.nginx.%: output := docker/infra/nginx/conf.d
.PHONY: merge.nginx.%
merge.nginx.%: open.config
	rm -vf $(output)/*.conf
	cp -f config/nginx/$*_*.conf $(output)
