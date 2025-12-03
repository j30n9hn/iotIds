# iotIds

ids container

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

# ids
## docker
```
docker exec -it ids-container /bin/bash
```
## snort
```
cd /opt
snort -c ./snort3/lua/snort.lua -i br-da27e6c37eea -A alert_fast -l ./
```
br-xxxxx는 ifconfig에서 찾아서 수정

# attacker
## docker
```
docker exec -it attacker /bin/bash

```
## attack
```
nmap -sS -p 1-1000 10.10.0.30
```
nmap만 설치. 필요 시 추가
