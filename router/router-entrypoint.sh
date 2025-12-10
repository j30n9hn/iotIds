#!/bin/sh

# 실행되는 명령 출력 
set -x

echo "[router] starting router container..."

EXT_IP="192.168.50.254"
INT_IP="10.10.0.254"

echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# 해당 IP를 가진 인터페이스 이름 자동 탐지
EXT_IF=$(ip -4 addr show | awk -v ip="$EXT_IP" '$0 ~ ip {gsub(":", "", $NF); print $NF}')
INT_IF=$(ip -4 addr show | awk -v ip="$INT_IP" '$0 ~ ip {gsub(":", "", $NF); print $NF}')

echo "[router] detected external interface: $EXT_IF (ip: $EXT_IP)"
echo "[router] detected internal interface: $INT_IF (ip: $INT_IP)"

if [ -z "$EXT_IF" ] || [ -z "$INT_IF" ]; then
  echo "[router] WARNING: could not detect EXT_IF or INT_IF"
  ip a
  echo "[router] staying alive for debugging..."
  sleep infinity
fi

# 1) IP 포워딩 켜기 
if command -v sysctl >/dev/null 2>&1; then
  sysctl -w net.ipv4.ip_forward=1 || echo "[router] WARNING: sysctl failed"
else
  echo "[router] WARNING: sysctl command not found"
fi

# 2) iptables 초기화
iptables -F || echo "[router] WARNING: iptables -F failed"
iptables -t nat -F || echo "[router] WARNING: iptables -t nat -F failed"
iptables -X || echo "[router] WARNING: iptables -X failed"

# 3) 기본 FORWARD 정책 허용
iptables -P FORWARD ACCEPT || echo "[router] WARNING: iptables -P FORWARD failed"

# 4) NAT 설정 (외부 인터페이스 기준)
iptables -t nat -A POSTROUTING -o "$EXT_IF" -j MASQUERADE || echo "[router] WARNING: NAT rule failed"

# 5) 포워딩 룰 (양방향 허용)
iptables -A FORWARD -i "$EXT_IF" -o "$INT_IF" -j ACCEPT || echo "[router] WARNING: FORWARD ext->int failed"
iptables -A FORWARD -i "$INT_IF" -o "$EXT_IF" -j ACCEPT || echo "[router] WARNING: FORWARD int->ext failed"

echo "[router] iptables filter table:"
iptables -vnL || true
echo "[router] iptables nat table:"
iptables -t nat -vnL || true

echo "[router] router is up and running. Sleeping forever..."
sleep infinity

