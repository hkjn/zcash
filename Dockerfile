FROM debian:jessie

MAINTAINER Henrik Jonsson <me@hkjn.me>

ENV ZCASH_URL=https://github.com/zcash/zcash.git \
    ZCASH_VERSION=v1.0.0-rc4 \
    ZCASH_CONF=/home/zcash/.zcash/zcash.conf

RUN apt-get autoclean && \
    apt-get autoremove && \
    apt-get update && \
    apt-get -qqy install --no-install-recommends build-essential \
    automake ncurses-dev libcurl4-openssl-dev libssl-dev libgtest-dev \
    make autoconf automake libtool git apt-utils pkg-config libc6-dev \
    libcurl3-dev libudev-dev m4 g++-multilib unzip git python zlib1g-dev \
    wget ca-certificates pwgen bsdmainutils && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /src/zcash/; cd /src/zcash; \
    git clone ${ZCASH_URL} zcash && \
    cd zcash && \
    git checkout ${ZCASH_VERSION} && \
    ./zcutil/fetch-params.sh && \
    ./zcutil/build.sh -j4 && \
    cd /src/zcash/zcash/src && \
    /usr/bin/install -c zcashd zcash-cli zcash-gtest -t /usr/local/bin/ && \
    rm -rf /src/zcash/ && \
    adduser --uid 1000 --system zcash && \
    mv /root/.zcash-params /home/zcash/ && \
    mkdir -p /home/zcash/.zcash/ && \
    chown -R zcash /home/zcash && \
    echo "Success"

USER zcash
RUN echo "rpcuser=zcash" > ${ZCASH_CONF} && \
  echo "rpcpassword=$(pwgen 40 1)" >> ${ZCASH_CONF} && \
  echo "testnet=0" >> ${ZCASH_CONF} && \
  echo "addnode=mainnet.z.cash" >> ${ZCASH_CONF} && \
  echo "genproclimit=4" >> ${ZCASH_CONF} && \
  echo "equihashsolver=tromp" >> ${ZCASH_CONF} && \
  echo "Success"

VOLUME ["/home/zcash/.zcash"]

# Set number of mining threads:
# zcashd -gen -t 16

#
# zcash-cli getinfo