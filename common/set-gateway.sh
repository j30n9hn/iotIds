#!/bin/sh
set -e

# ROUTER_GW 환경변수로 게이트웨이 IP를 받는다.
if [ -z "$ROUTER_GW" ]; then
  echo "[set-gateway] ROUTER_GW is not set, skip route change."
else
  echo "[set-gateway] Setting default gateway to $ROUTER_GW ..."

  # 기존 Docker default route 삭제 
  ip route del default || true

  # 새 default route 추가
  ip route add default via "$ROUTER_GW"

  echo "[set-gateway] Current routes:"
  ip route
fi

echo "[set-gateway] Executing main command: $@"
exec "$@"

