FROM debian:12-slim

# iproute2: ip, ip a, ip route
# iptables: 방화벽/NAT 설정
# iputils-ping: ping 테스트
# tcpdump: 패킷 캡쳐
# procps: sysctl 명령 포함
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        iproute2 \
        iptables \
        iputils-ping \
        tcpdump \
        procps \
    && rm -rf /var/lib/apt/lists/*

# 엔트리포인트 스크립트 복사
COPY router/router-entrypoint.sh /usr/local/bin/router-entrypoint.sh
RUN chmod +x /usr/local/bin/router-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/router-entrypoint.sh"]

