.PHONY: install.base
install.base:
	apt update
	apt upgrade
	apt install -y wget make vim unzip curl zsh git

install.ethr: tmp := $(mktemp -d)
install.ethr: file_name := ethr_linux.zip
.PHONY: install.ethr
install.ethr: install.base
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
