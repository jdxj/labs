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
install.wget: install.upgrade
	apt install -y wget

# git
.PHONY: install.git
install.git: install.upgrade
	apt install -y git

# ca
.PHONY: install.ca
install.ca: install.upgrade
	apt install -y ca-certificates

# gpg
.PHONY: install.gpg
install.gpg: install.upgrade
	apt install -y gpg

# snap
.PHONY: install.snap
install.snap: install.upgrade
	apt install -y snapd
	snap install core
	snap install hello-world

# ssh
.PHONY: install.ssh
install.ssh: lockgit.open
	cp -fp ./config/ssh/config/* ~/.ssh
	cat config/ssh/pc/id_ed25519.pub config/ssh/mbp/id_ed25519.pub \
		config/ssh/config/id_ed25519.pub > ~/.ssh/authorized_keys
	chmod 0600 ~/.ssh/authorized_keys

# warp
.PHONY: install.warp
install.warp: install.curl install.gpg
	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | \
		gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bookworm main" | \
		tee /etc/apt/sources.list.d/cloudflare-client.list
	apt update && apt install -y cloudflare-warp
	warp-cli registration new
	warp-cli mode proxy
	warp-cli connect

# brutal
.PHONY: install.brutal
install.brutal: install.curl
	bash -c "$$(curl -fsSL https://tcp.hy2.sh/)"

# vim leaf
.PHONY: install.vim
install.vim: install.upgrade git.pull
	apt install -y vim
	cp -f config/vim/.vimrc ~

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
	@read -p "labs lockgit key:" key && lockgit set-key $$key --force

# certbot leaf required
.PHONY: install.certbot
install.certbot: install.snap
	snap install --classic certbot
	ln -sf /snap/bin/certbot /usr/bin/certbot

# timesyncd leaf required
.PHONY: install.systemd-timesyncd
install.systemd-timesyncd: install.upgrade
	apt install -y systemd-timesyncd
	systemctl enable systemd-timesyncd
	systemctl start systemd-timesyncd
	timedatectl status

# sshd
.PHONY: install.sshd
install.sshd: install.ssh
	rm -vf /etc/ssh/sshd_config.d/*.conf
	cp ./config/sshd/env.conf /etc/ssh/sshd_config.d
	systemctl restart sshd

# sysstat leaf
.PHONY: install.sysstat
install.sysstat: install.upgrade
	apt install -y sysstat

# iperf3 leaf
.PHONY: install.iperf3
install.iperf3: install.upgrade
	apt install -y iperf3

# net-tools leaf required
.PHONY: install.net-tools
install.net-tools: install.upgrade
	apt install -y net-tools

# hostname leaf required
.PHONY: install.hostname
install.hostname:
	@read -p "hostname:" hm && hostnamectl hostname $$hm
	@hostnamectl status

# sysctl leaf required
.PHONY: install.sysctl
install.sysctl: install.upgrade
	apt install -y procps
	cp -f ./config/kernel/sysctl.conf /etc/sysctl.conf
	sysctl -p

# passwd
.PHONY: install.passwd
install.passwd:
	passwd

# all
.PHONY: install.all
install.all: install.docker install.lockgit install.certbot install.systemd-timesyncd \
	install.vim install.net-tools install.sysctl install.passwd \
	install.hostname install.zsh
