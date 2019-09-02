FROM ubuntu:18.04

MAINTAINER markdelillo@gmail.com

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

ARG bbl_version=8.2.14
ARG bosh_version=6.0.0
ARG chruby_version=0.3.9
ARG credhub_version=2.5.2
ARG fly_version=5.4.1
ARG jq_version=1.6
ARG nvm_version=0.34.0
ARG ruby_install_version=0.7.0
ARG yj_version=4.0.0

RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get install -y software-properties-common && \
    add-apt-repository multiverse && \
    add-apt-repository ppa:git-core/ppa && \
    add-apt-repository ppa:neovim-ppa/stable && \
    apt-get update && \
    apt-get install -y \
      apt-transport-https \
      curl \
      direnv \
      g++ \
      gcc \
      git \
      lastpass-cli \
      libc6-dev \
      make \
      neovim \
      pkg-config \
      python-dev \
      python-pip \
      python3-dev \
      python3-pip \
      sudo \
      telnet \
      tree \
      unrar \
      unzip \
      vim \
      wget

RUN pip2 install --user pynvim && \
    pip3 install --user pynvim

RUN golang_url="$(curl -q https://golang.org/dl/ | grep -oP 'https:\/\/dl\.google\.com\/go\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1 )" && \
    echo "$golang_url" && \
    curl -L "$golang_url" | tar -C /usr/local -xvz

RUN curl -L "https://github.com/postmodern/chruby/archive/v${chruby_version}.tar.gz" | tar -C /tmp -xvz && \
    cd "/tmp/chruby-${chruby_version}" && \
    make install && \
    rm -rf "/tmp/chruby-${chruby_version}"
RUN curl -L "https://github.com/postmodern/ruby-install/archive/v${ruby_install_version}.tar.gz" | tar -C /tmp -xvz && \
    cd "/tmp/ruby-install-${ruby_install_version}" && \
    make install && \
    rm -rf "/tmp/ruby-install-${ruby_install_version}"
RUN ruby-install ruby

RUN curl -L -o /usr/local/bin/bbl "https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${bbl_version}/bbl-v${bbl_version}_linux_x86-64" && \
    chmod +x /usr/local/bin/bbl

RUN curl -L -o /usr/local/bin/bosh "https://github.com/cloudfoundry/bosh-cli/releases/download/v${bosh_version}/bosh-cli-${bosh_version}-linux-amd64" && \
    chmod +x /usr/local/bin/bosh

RUN curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" | tar -zx -C /usr/local/bin cf && \
    chmod +x /usr/local/bin/cf

RUN curl -L "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${credhub_version}/credhub-linux-${credhub_version}.tgz" | tar -zx -C /usr/local/bin ./credhub && \
    chmod +x /usr/local/bin/credhub

RUN curl -L "https://github.com/concourse/concourse/releases/download/v${fly_version}/fly-${fly_version}-linux-amd64.tgz" | tar -zx -C /usr/local/bin fly && \
    chmod +x /usr/local/bin/fly

RUN curl -L -o /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-${jq_version}/jq-linux64" && \
    chmod +x /usr/local/bin/jq

RUN curl -L -o /usr/local/bin/yj "https://github.com/sclevine/yj/releases/download/v${yj_version}/yj-linux" && \
    chmod +x /usr/local/bin/yj

RUN update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && \
    update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60 && \
    update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60

RUN useradd -m -s /bin/bash -G sudo mark && \
    echo "mark:mark" | chpasswd && \
    echo "mark ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/mark && \
    chmod 0440 /etc/sudoers.d/mark
USER mark
WORKDIR /home/mark
ENV HOME /home/mark

ENV GOPATH "$HOME/go"
ENV PATH "$GOPATH/bin:/usr/local/go/bin:$PATH"
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
    go get github.com/onsi/ginkgo/ginkgo

RUN echo "source /usr/local/share/chruby/chruby.sh" >> "$HOME/.bashrc" && \
    echo "source /usr/local/share/chruby/auto.sh" >> "$HOME/.bashrc" && \
    ls /opt/rubies | head -n 1 > "$HOME/.ruby-version"

ENV NVM_DIR $HOME/.nvm
RUN mkdir -p "$NVM_DIR" && \
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh" | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install node

RUN git clone https://github.com/luan/vimfiles "$HOME/.vim" && \
    . "$NVM_DIR/nvm.sh" && \
    "$HOME/.vim/update"

CMD ["/bin/bash"]
