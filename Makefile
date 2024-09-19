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
	mkdir -p /etc/letsencrypt
	$(DOCKER) up -d my_nginx

.PHONY: up.sb.%
up.sb.%: open.config merge.sb.%
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

.PHONY: hostname.%
hostname.%:
	hostnamectl hostname $*

# ssh.config
ssh.config: CONFIG_PATH := ./config/ssh/config
ssh.config: KEYS_PATH   := ./config/ssh/authorized_keys
.PHONY: ssh.config
ssh.config: open.config
	cp -f $(CONFIG_PATH) $(KEYS_PATH) ~/.ssh
	chmod 0600 $(CONFIG_PATH) $(KEYS_PATH)

# ssh.keygen
.PHONY: ssh.keygen.%
ssh.keygen.%:
	ssh-keygen -t ed25519 -C $*

# sshd.config
.PHONY: sshd.config
sshd.config: ssh.config
	rm -f /etc/ssh/sshd_config.d/*.conf
	cp config/sshd/env.conf /etc/ssh/sshd_config.d
	systemctl restart sshd
