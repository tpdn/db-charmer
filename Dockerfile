FROM ubuntu:trusty
ENV RUBY_VERSION 2.3.6

RUN echo "Asia/Tokyo" | tee /etc/timezone

RUN apt-get --yes update && DEBIAN_FRONTEND=noninteractive apt-get install --yes git language-pack-ja curl libssl-dev make mysql-server libmysqlclient-dev libreadline-dev build-essential
RUN apt-get clean

RUN locale-gen ja_JP.UTF-8
RUN /usr/sbin/update-locale LANG=ja_JP.UTF-8
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN dpkg-reconfigure locales

RUN mkdir -p /etc/mysql/conf.d
RUN printf "[client]\ndefault-character-set = utf8\n[mysqld]\ncharacter-set-server = utf8\nskip-character-set-client-handshake\nmax_connections = 10000\n[mysqldump]\ndefault-character-set=utf8\n[mysql]\ndefault-character-set=utf8\n" >> /etc/mysql/conf.d/character_set.cnf

RUN update-rc.d mysql defaults

RUN echo "Host github.com\nStrictHostKeyChecking no\n" > /etc/ssh/ssh_config

# install ruby-build
RUN git clone https://github.com/rbenv/ruby-build.git /root/ruby-build
RUN /root/ruby-build/install.sh

# install ruby
RUN ruby-build $RUBY_VERSION /opt/ruby/$RUBY_VERSION
ENV PATH /opt/ruby/$RUBY_VERSION/bin:$PATH
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN gem install bundler -v 1.17.1

# add source
ADD . /root/db-charmer

# init ci
RUN cd /root/db-charmer/ && ./ci_build
