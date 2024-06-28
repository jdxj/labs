merge.sb.%: output := docker/infra/sing-box/conf/config.json
merge.sb.%: path_config := config/sing-box/server
.PHONY: merge.sb.%
merge.sb.%: open.config
	sing-box merge $(output) -C $(path_config) -C $(path_config)/$*
	sing-box check -c $(output)

merge.app.sb.%: path_output := docker/infra/nginx/app
merge.app.sb.%: path_config := config/sing-box/client
.PHONY: merge.app.sb.%
merge.app.sb.%: open.config
	sing-box merge $(path_output)/sing-box-$*.json -C $(path_config) -C $(path_config)/outbounds -C $(path_config)/$*
	sing-box check -c $(path_output)/sing-box-$*.json

merge.nginx.%: output := docker/infra/nginx/conf.d
.PHONY: merge.nginx.%
merge.nginx.%: open.config
	rm -vf $(output)/*.conf
	cp -f config/nginx/$*_*.conf $(output)
