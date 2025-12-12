# iotIds – Docker 기반 IoT 침입 탐지/차단 실습 환경

Docker 기반으로 외부 공격자 → 라우터 → 내부 IoT 네트워크 → IDS(Snort3) 의 구조를 재현하여
IoT 장비(CCTV, Hub 등)에 대한 공격을 탐지·차단하는 실습용 환경

IDS는 Snort3 Inline 모드(NFQUEUE, DAQ: nfq)로 실행되어 라우터의 iptables(FORWARD 체인)와 연동하여 실제처럼 패킷을 탐지 및 차단

구성 요소:
- attacker (외부망)
- router (NAT, IP forwarding, 외부망 ↔ 내부망 라우팅)
- wifi / hub / home / printer / vacuum / fridge / heater (내부 IoT 네트워크)
- ids (Snort3) – NFQUEUE 기반 IDS/IPS - router를 통과하는 트래픽을 인라인 검사

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

|네트워크|역할|게이트웨이|범위|
|---|---|---|---|
|external_net|외부(Internet 역할)|192.168.50.254|192.168.50.0/24|
|lab_net|내부 IoT 네트워크|10.10.0.254|10.10.0.0/24|

## 컨테이너 배치

```
(attacker: 192.168.50.10)
        ↓
(external_net)
        ↓
(router: 192.168.50.254(eth0) ↔ 10.10.0.254(eth1)) ← Snort가 감시
        ↓
(lab_net)
        ↓
wifi (10.10.0.20)
hub  (10.10.0.30)
curtain (10.10.0.31)
door (10.10.0.32)
home (10.10.0.70)
printer (10.10.0.40)
vacuum (10.10.0.41)
fridge (10.10.0.42)
heater (10.10.0.43)
```

# Router
## 역할
`router-entrypoint.sh` 에 의해 다음 기능 수행:
- IP forwarding 활성화
- NAT(MASQUERADE) 구성
- FORWARD 체인 기본 정책 및 라우팅 허용
- external_net ↔ lab_net 방향 트래픽을 NFQUEUE(큐 번호 0)로 전달하여 Snort와 연동

모든 IoT 기기(wifi, hub, home)와 attacker는
`set-gateway.sh` 에 의해 router를 기본 게이트웨이로 사용:
```
default via 192.168.50.254 (attacker)
default via 10.10.0.254    (wifi/hub/home)
```
실제 공격 구조:
```
attacker → router (NFQUEUE) → Snort → (허용 시) hub
```

# IDS
## 설명
Snort3 IDS는 router 컨테이너와 동일한 네트워크 네임스페이스에서 실행(network_mode: container:router)

라우터의 iptables(FORWARD 체인)에 설정된 NFQUEUE --queue-num 0 으로 외부 ↔ 내부(lab_net) 트래픽이 큐에 전달됨

Snort는 DAQ: nfq 를 사용해 NFQUEUE(0번 큐)를 인라인으로 처리하면서 패킷을 허용 또는 drop 한다.

즉, Snort는 네트워크 구조상 Router를 통과하는 모든 외부↔내부 트래픽의 “목”에 위치한 IPS 역할을 수행하며, 실제 기업 네트워크에서 방화벽 앞단/뒤단에 배치된 인라인 IPS와 거의 동일한 구성을 갖는다.

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
## snort3
```
cd /opt
snort -Q --daq nfq --daq-mode inline --daq-var queue=0 -c ./snort3/lua/snort.lua
```
- IDS 컨테이너는 router 컨테이너의 네트워크 스택을 공유(network_mode: container:router)
- snort를 실행해야만 서로 통신이 됨
- 패킷은 먼저 router iptables 의 NFQUEUE(0번 큐)로 들어가고, Snort가 이를 인라인으로 검사한 뒤 허용/차단(drop) 을 결정

# Attacker
## docker
```
docker exec -it attacker /bin/bash
```
## attack
```
nmap -sS -p 1-1000 10.10.0.30
```
## 설치된 도구
- nmap
- hping3
- metasploit
- hydara
