# iotIds – Docker 기반 IoT 침입 탐지/차단 실습 환경

Docker 기반으로 외부 공격자 → 라우터 → 내부 IoT 네트워크 → IDS(Snort3) 의 구조를 재현하여
IoT 장비(CCTV, Hub 등)에 대한 공격을 탐지·차단하는 실습용 환경

구성 요소:
- attacker (외부망)
- router (NAT + 라우팅 + 포워딩)
- wifi / hub / home (내부 IoT 네트워크)
- ids (Snort3) – host network 를 사용하여 모든 브리지 트래픽 모니터링

# 실행 순서
## 환경 다운로드

```
git clone https://github.com/j30n9hn/iotIds.git
cd iotIds
docker compose up -d
```
Dockerfile 또는 docker-compose.yml 수정 시 `docker compose up -d` 실행 전 다음 명령어 실행
```
docker compose build --no-cache
```
호스트 PC 재부팅 시 iotIds 폴더에서 `docker compose up -d` 명령어 실행 후 아래 과정 진행

# 네트워크 구조

|네트워크|역할|게이트웨이(br-xxxx)|범위|
|---|---|---|---|
|external_net|외부(Internet 역할)|192.168.50.1|192.168.50.0/24|
|lab_net|내부 IoT 네트워크|10.10.0.1|10.10.0.0/24|

## 컨테이너 배치

```
(attacker: 192.168.50.10)
        ↓
(external_net)
        ↓
(router: 192.168.50.254 ↔ 10.10.0.254)
        ↓
(lab_net)
        ↓
wifi (10.10.0.20)
hub  (10.10.0.30)
home (10.10.0.70)
printer (10.10.0.40)
vacuum (10.10.0.41)
fridge (10.10.0.42)
heater (10.10.0.43)
```
IDS는 호스트 네트워크에서 두 개의 Docker 브리지를 직접 모니터링함
```
br-XXXX (external_net) → 192.168.50.1
br-YYYY (lab_net)      → 10.10.0.1
```

# Router
## 역할
`router-entrypoint.sh` 에 의해 다음 기능 수행:
- IP forwarding 활성화
- NAT(MASQUERADE) 구성
- FORWARD 체인 패킷 허용
- external_net ↔ lab_net 라우팅 허용

모든 IoT 기기(wifi, hub, home)와 attacker는
`set-gateway.sh` 에 의해 router를 기본 게이트웨이로 사용:
```
default via 192.168.50.254 (attacker)
default via 10.10.0.254    (wifi/hub/home)
```
실제 공격 구조:
```
attacker → router → hub
```

# IDS
## IP 추가
새로운 IP 추가 시 다음과 같은 형식으로 `snort.lua`에 작성
```
-- default_variables 변수 추가
default_variables.nets.HUB    = '10.10.0.30'
default_variables.nets.WIFI   = '10.10.0.20'
default_variables.nets.OPHONE = '10.10.0.50'
```
## docker
```
docker exec -it ids-container /bin/bash
```
## snort
```
cd /opt
snort -c ./snort3/lua/snort.lua -i br-da27e6c37eea -A alert_fast -l ./
```
br-xxxxx는 ifconfig에서 찾아서 수정.<br>
외부망에 대한 탐지는 `external-net`에 해당하는 `br-xxx`를 사용하며 `inet 192.168.50.1`을 사용.<br>
내부망에 대한 탐지는 `lab-net`에 해당하는 `br-xxx`를 사용하며 `inet 10.10.0.1`을 사용.<br>

# Attacker
## docker
```
docker exec -it attacker /bin/bash
```
## attack
```
nmap -sS -p 1-1000 10.10.0.30
```
nmap만 설치. 필요 시 추가
