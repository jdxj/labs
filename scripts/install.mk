# 手动安装 make

.PHONY: install.upgrade
install.upgrade:
	apt update
	apt upgrade -y

# curl
.PHONY: install.curl
install.curl: install.upgrade
	apt install -y curl

# wget
.PHONY: install.wget
install.curl: install.upgrade
	apt install -y wget

# git
.PHONY: install.git
install.git: install.upgrade
	apt install -y git

# ca
.PHONY: install.ca
install.ca: install.upgrade
	apt install -y ca-certificates

# snap
.PHONY: install.snap
install.snap: install.upgrade
	apt install -y snapd
	snap install core
	snap install hello-world

# zsh leaf required
.PHONY: install.zsh
install.zsh: install.upgrade install.curl install.git
	rm -rf ~/.oh-my-zsh
	apt install -y zsh
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	sed -i '11s/robbyrussell/jonathan/' ~/.zshrc

# docker leaf required
.PHONY: install.docker
install.docker: install.upgrade install.ca install.curl
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	chmod a+r /etc/apt/keyrings/docker.asc
	echo \
		"deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		bookworm stable" | \
		tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt update
	apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	docker run hello-world

# lockgit leaf required
install.lockgit: tmp := $(shell mktemp -d)
install.lockgit: file_name := lockgit_0.9.0_linux_amd64.tar.gz
.PHONY: install.lockgit
install.lockgit: install.wget
	wget -O $(tmp)/$(file_name) \
		https://github.com/jswidler/lockgit/releases/download/v0.9.0/$(file_name)
	tar -zxvf $(tmp)/$(file_name) -C $(INSTALL_PATH) lockgit

# certbot leaf required
.PHONY: install.certbot
install.certbot: install.snap
	snap install --classic certbot
	ln -sf /snap/bin/certbot /usr/bin/certbot

# warp leaf?
.PHONY: install.warp
install.warp: install.curl
	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | \
		gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bookworm main" | \
		tee /etc/apt/sources.list.d/cloudflare-client.list
	apt update && apt install -y cloudflare-warp
	warp-cli registration new
	warp-cli set-mode proxy
	warp-cli connect

# brutal leaf
.PHONY: install.brutal
install.brutal: install.curl
	bash -c "$$(curl -fsSL https://tcp.hy2.sh/)"

# timesyncd leaf required
.PHONY: install.timesyncd
install.timesyncd: install.upgrade
	apt install -y systemd-timesyncd
	systemctl enable systemd-timesyncd
	systemctl start systemd-timesyncd
	timedatectl status

# sysstat leaf
.PHONY: install.sysstat
install.sysstat: install.upgrade
	apt install -y sysstat

# iperf3 leaf
.PHONY: install.iperf3
install.iperf3: install.upgrade
	apt install -y iperf3


# base leaf required
.PHONY: install.base
install.base: install.upgrade
	apt install -y vim unzip

# all
.PHONY: install.all
install.all: install.docker install.lockgit install.certbot install.timesyncd \
	install.base install.zsh
