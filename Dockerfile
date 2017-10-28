FROM debian:stretch-slim
LABEL Version=0.1.0
LABEL Name=selenium-ruby-docker

RUN mkdir -p /data /output && chmod 755 /data /output

VOLUME ["/data", "/output"]

ENV LANG en_US.utf8
ENV TERM xterm-256color
ENV TZ=Europe/Prague

# manage locales, apt-utils, node, gnupg, etc.
COPY dpkg_exclude_doc.conf /etc/dpkg/dpkg.cfg.d/01_no_documentation
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils apt-transport-https locales curl gnupg && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    curl -sL https://deb.nodesource.com/setup_8.x | /bin/bash -

# install RVM and stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential nodejs procps python net-tools netcat lsb-release ssh-client make dos2unix git
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

# install ruby
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby --rails

# install selenium and rspec gems
RUN echo 'source /usr/local/rvm/scripts/rvm' >> ~/.bashrc
RUN /usr/local/rvm/bin/rvm-shell -c "rvm requirements"
RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc
RUN /bin/bash -l -c "gem install selenium-webdriver rspec"

# cleanup
RUN DEBIAN_FRONTEND=noninteractive apt-get clean -y && rm -rf /var/lib/apt/lists/*
