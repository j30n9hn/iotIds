FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y net-tools iputils-ping nmap

WORKDIR /opt

CMD ["/bin/bash"]
