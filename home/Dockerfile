FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y net-tools iputils-ping mosquitto mosquitto-clients systemd

WORKDIR /opt

CMD ["/bin/bash"]
