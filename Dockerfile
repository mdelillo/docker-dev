FROM mdelillo/base

ARG golang_version=1.8.3
ARG ruby_version=2.4.1
ARG chruby_version=0.3.9
ARG ruby_install_version=0.6.1

RUN apt-add-repository ppa:git-core/ppa && \
      apt-get -y update && \
      apt-get -y install git

RUN apt-get install -y \
      g++ \
      gcc \
      libc6-dev \
      make \
      pkg-config
RUN curl -L "https://golang.org/dl/go${golang_version}.linux-amd64.tar.gz" | tar -C /usr/local -xvz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 755 "$GOPATH"
RUN go get github.com/onsi/ginkgo/ginkgo

RUN curl -L "https://github.com/postmodern/chruby/archive/v${chruby_version}.tar.gz" | tar -C /tmp -xvz && \
      cd /tmp/chruby-${chruby_version} && \
      make install && \
      rm -rf /tmp/chruby-${chruby_version}
RUN curl -L "https://github.com/postmodern/ruby-install/archive/v${ruby_install_version}.tar.gz" | tar -C /tmp -xvz && \
      cd /tmp/ruby-install-${ruby_install_version} && \
      make install && \
      rm -rf /tmp/ruby-install-${ruby_install_version}
RUN ruby-install ruby-${ruby_version}
RUN echo "source /usr/local/share/chruby/chruby.sh" >> $HOME/.bashrc
RUN echo "source /usr/local/share/chruby/auto.sh" >> $HOME/.bashrc
RUN echo "ruby-${ruby_version}" > /.ruby-version

CMD ["/bin/bash"]
