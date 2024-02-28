FROM ubuntu:18.04
# install etcdctl
COPY ./etcdctl /usr/local/bin/
COPY ./etcdhelper /usr/local/bin/

# install common utils
RUN sed -i "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list
RUN apt update && apt install -y --fix-missing vim curl make dnsutils iputils-ping wget net-tools apt-utils  \
    apt-transport-https ca-certificates software-properties-common gnupg gnupg2 lsb-release bridge-utils git

# install zsh
RUN apt install -y zsh
RUN chsh -s $(which zsh)
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN sed -i "s/(git)/(git zsh-autosuggestions zsh-syntax-highlighting)/g" ~/.zshrc
RUN sed -i "s/robbyrussell/af-magic/g" ~/.zshrc
RUN sed -i "/source \$ZSH\/oh-my-zsh.sh/i\source \/etc\/profile" ~/.zshrc

# install kubectl
RUN curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
RUN cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
RUN apt update && apt install -y --fix-missing kubelet kubeadm kubectl

# install tzdata
RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata

# install go
RUN mkdir -p ~/home/gosdk && mkdir -p ~/home/gopath && mkdir -p ~/home/workspace
RUN wget https://dl.google.com/go/go1.20.5.linux-amd64.tar.gz
RUN tar -zvxf go1.20.5.linux-amd64.tar.gz -C ~/home/gosdk/ && mv ~/home/gosdk/go ~/home/gosdk/go-1.20 && rm go1.20.5.linux-amd64.tar.gz

RUN cp /etc/profile /etc/profile.bak
RUN cat <<EOF >>/etc/profile
export TMOUT=86400
export HISTSIZE=10000

# Go env
export GOROOT=/root/home/gosdk/go-1.20
export GOPATH=/root/home/gopath
export GO111MODULE=auto

export PATH=\${GOROOT}/bin:\${GOPATH}/bin:\${PATH}
EOF

# install kind
RUN /bin/bash -c "source /etc/profile && GOPROXY=https://goproxy.cn,direct go install sigs.k8s.io/kind@v0.20.0"

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["/bin/zsh"]
