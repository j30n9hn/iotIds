FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        net-tools \
        iputils-ping \
        nmap \
        iproute2 \
        hping3 \
        hydra \
        tshark \
        metasploit-framework \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 공통 게이트웨이 설정 스크립트 복사
COPY common/set-gateway.sh /usr/local/bin/set-gateway.sh
RUN chmod +x /usr/local/bin/set-gateway.sh

ENTRYPOINT ["/usr/local/bin/set-gateway.sh"]

WORKDIR /opt
CMD ["/bin/bash"]

