FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y net-tools iputils-ping nmap iproute2

# 공통 게이트웨이 설정 스크립트 복사
COPY common/set-gateway.sh /usr/local/bin/set-gateway.sh
RUN chmod +x /usr/local/bin/set-gateway.sh

# 엔트리포인트에서 게이트웨이 먼저 설정한 뒤 CMD 실행
ENTRYPOINT ["/usr/local/bin/set-gateway.sh"]

WORKDIR /opt

CMD ["/bin/bash"]
