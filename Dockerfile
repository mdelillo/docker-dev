FROM mdelillo/base

RUN apt-add-repository ppa:git-core/ppa && \
      apt-get -y update && \
      apt-get -y install git

CMD ["/bin/bash"]
