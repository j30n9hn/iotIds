FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

# 1) 패키지 설치 (ca-certificates 포함)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        net-tools \
        iputils-ping \
        nmap \
        iproute2 \
        hping3 \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2) Metasploit msfinstall 다운로드 & 설치를 별도 RUN 으로 분리
RUN curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -o /tmp/msfinstall \
    && chmod 755 /tmp/msfinstall \
    && /tmp/msfinstall \
    && rm /tmp/msfinstall

# 공통 게이트웨이 설정 스크립트 복사
COPY common/set-gateway.sh /usr/local/bin/set-gateway.sh
RUN chmod +x /usr/local/bin/set-gateway.sh

ENTRYPOINT ["/usr/local/bin/set-gateway.sh"]

WORKDIR /opt
CMD ["/bin/bash"]

