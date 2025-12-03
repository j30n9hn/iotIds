# iotIds

ids container

# 실행 순서

```
git clone https://github.com/j30n9hn/iotIds.git
cd iotIds
docker compose up -d
docker exec <ids id> -it /bin/bash
docker exec <hub or something id> -it /bin/bash
```

# ids
```
cd /opt
snort -Q -c ./snort3/lua/snort.lua -i br-xxxxx -A alert_fast
```
br-xxxxx는 ifconfig에서 찾아 수정
# external => attacker
ping or attack
