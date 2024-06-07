DOCKER := cd docker/infra && \
		  docker compose -f docker-compose.yml -f xray.yml -f xray-forward.yml -f hysteria.yml -f sing-box.yml
INSTALL_PATH := /usr/local/bin

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

install.ethr: tmp := $(mktemp -d)
install.ethr: file_name := ethr_linux.zip
.PHONY: install.ethr
install.ethr:
	wget -O $(tmp)/$(file_name) \
		https://github.com/microsoft/ethr/releases/download/v1.0.0/$(file_name)
	unzip -d $(INSTALL_PATH) $(tmp)/$(file_name)

install.lockgit: tmp := $(mktemp -d)
install.lockgit: file_name := lockgit_0.9.0_linux_amd64.tar.gz
.PHONY: install.lockgit
install.lockgit:
	wget -O $(tmp)/$(file_name) \
		https://github.com/jswidler/lockgit/releases/download/v0.9.0/$(file_name)
	tar -zxvf $(tmp)/$(file_name) -C $(INSTALL_PATH) lockgit

install.sing-box: tmp := $(mktemp -d)
install.sing-box: tar_dir := sing-box-1.9.0-linux-amd64
install.sing-box: file_name := $(tar_dir).tar.gz
.PHONY: install.sing-box
install.sing-box:
	wget -O $(tmp)/$(file_name) \
		https://github.com/SagerNet/sing-box/releases/download/v1.9.0/$(file_name)
	tar --strip-components=1 -zxvf $(tmp)/$(file_name) -C $(INSTALL_PATH) $(tar_dir)/sing-box

.PHONY: install.docker
install.docker:
	apt-get update
	apt-get install ca-certificates curl
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	chmod a+r /etc/apt/keyrings/docker.asc
	echo \
		"deb [arch=$(shell dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		$(shell . /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get update
	apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	docker run hello-world

.PHONY: install.snap
install.snap:
	apt update
	apt install snapd
	snap install core
	snap install hello-world

.PHONY: install.certbot
install.certbot: install.snap
	snap install --classic certbot
	ln -s /snap/bin/certbot /usr/bin/certbot

.PHONY: install.base
install.base:
	apt install -y wget make vim