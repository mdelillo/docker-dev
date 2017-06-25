FROM mdelillo/base

RUN apt-add-repository ppa:git-core/ppa && \
      apt-get -y update && \
      apt-get -y install git

RUN apt-get install -y \
      g++ \
      gcc \
      libc6-dev \
      make \
      pkg-config
RUN curl -L "https://golang.org/dl/go1.8.3.linux-amd64.tar.gz" | tar -C /usr/local -xvz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 755 "$GOPATH"
RUN go get github.com/onsi/ginkgo/ginkgo

CMD ["/bin/bash"]
