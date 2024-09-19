.PHONY: install.base
install.base:
	apt update
	apt upgrade
	apt install -y wget make vim unzip curl zsh git

install.lockgit: tmp := $(mktemp -d)
install.lockgit: file_name := lockgit_0.9.0_linux_amd64.tar.gz
.PHONY: install.lockgit
install.lockgit:
	wget -O $(tmp)/$(file_name) \
		https://github.com/jswidler/lockgit/releases/download/v0.9.0/$(file_name)
	tar -zxvf $(tmp)/$(file_name) -C $(INSTALL_PATH) lockgit

.PHONY: install.docker
install.docker:
	apt-get update
	apt-get install -y ca-certificates curl
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	chmod a+r /etc/apt/keyrings/docker.asc
	echo \
		"deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		bookworm stable" | \
		tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get update
	apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	docker run hello-world

.PHONY: install.snap
install.snap:
	apt update
	apt install -y snapd
	snap install core
	snap install hello-world

.PHONY: install.certbot
install.certbot: install.snap
	snap install --classic certbot
	ln -s /snap/bin/certbot /usr/bin/certbot

.PHONY: install.warp
install.warp:
	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | \
		gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bookworm main" | \
		tee /etc/apt/sources.list.d/cloudflare-client.list
	apt update && apt install -y cloudflare-warp
	warp-cli registration new
	warp-cli set-mode proxy
	warp-cli connect

.PHONY: install.brutal
install.brutal:
	bash <(curl -fsSL https://tcp.hy2.sh/)

.PHONY: install.timesyncd
install.timesyncd:
	apt install systemd-timesyncd
	systemctl enable systemd-timesyncd
	systemctl start systemd-timesyncd
	timedatectl status

.PHONY: install.sysstat
install.sysstat:
	apt install -y sysstat

.PHONY: install.iperf3
install.iperf3:
	apt install -y iperf3

install.ssh.config: CONFIG_PATH := ./config/ssh/config
install.ssh.config: KEYS_PATH   := ./config/ssh/authorized_keys
.PHONY install.ssh.config
install.ssh.config: open.config
	cp -f $(CONFIG_PATH) $(KEYS_PATH) ~/.ssh
	chmod 0600 $(CONFIG_PATH) $(KEYS_PATH)
