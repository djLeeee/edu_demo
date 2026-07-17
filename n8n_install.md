# n8n Docker 설치 가이드

Docker Desktop을 이용해 n8n을 실행하는 방법입니다.

이 가이드는 n8n의 워크플로우, 계정 정보, 인증 정보 등을 Docker 볼륨에 저장하는 방식으로 구성되어 있습니다.

---

## 공통 준비사항

먼저 Docker Desktop을 설치하고 실행합니다.

- Windows: PowerShell 사용
- Mac: 터미널 사용
- n8n 접속 주소: <http://localhost:5678>

---

# 1. Windows 설치 방법

## 1.1 Docker 볼륨 생성

PowerShell을 실행한 후 아래 명령어를 입력합니다.

```powershell
docker volume create n8n_data
```

`n8n_data`라는 Docker 볼륨이 생성됩니다.

이 볼륨에는 다음과 같은 n8n 데이터가 저장됩니다.

- 사용자 계정
- 워크플로우
- 인증 정보
- 실행 기록
- n8n 설정

---

## 1.2 n8n 실행

PowerShell에서 아래 명령어를 입력합니다.

```powershell
docker run -d `
  --name n8n `
  -p 5678:5678 `
  -e GENERIC_TIMEZONE=Asia/Seoul `
  -e TZ=Asia/Seoul `
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true `
  -v n8n_data:/home/node/.n8n `
  docker.n8n.io/n8nio/n8n
```

### 한 줄 명령어

여러 줄 명령어 실행이 어려운 경우 아래 명령어를 사용합니다.

```powershell
docker run -d --name n8n -p 5678:5678 -e GENERIC_TIMEZONE=Asia/Seoul -e TZ=Asia/Seoul -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
```

---

## 1.3 n8n 접속

웹 브라우저에서 아래 주소로 접속합니다.

```text
http://localhost:5678
```

최초 접속 시 n8n 사용자 계정을 생성합니다.

---

# 2. Mac 설치 방법

## 2.1 Docker 볼륨 생성

터미널을 실행한 후 아래 명령어를 입력합니다.

```bash
docker volume create n8n_data
```

---

## 2.2 n8n 실행

터미널에서 아래 명령어를 입력합니다.

```bash
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e GENERIC_TIMEZONE=Asia/Seoul \
  -e TZ=Asia/Seoul \
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n
```

### 한 줄 명령어

```bash
docker run -d --name n8n -p 5678:5678 -e GENERIC_TIMEZONE=Asia/Seoul -e TZ=Asia/Seoul -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
```

---

## 2.3 n8n 접속

웹 브라우저에서 아래 주소로 접속합니다.

```text
http://localhost:5678
```

---

# 3. 컨테이너 관리 명령어

Windows PowerShell과 Mac 터미널에서 동일하게 사용할 수 있습니다.

## n8n 상태 확인

```bash
docker ps
```

중지된 컨테이너까지 확인하려면 다음 명령어를 사용합니다.

```bash
docker ps -a
```

---

## n8n 중지

```bash
docker stop n8n
```

---

## n8n 다시 시작

```bash
docker start n8n
```

기존에 생성한 컨테이너를 다시 시작하는 경우 별도의 `docker run` 명령어를 입력할 필요가 없습니다.

---

## n8n 로그 확인

```bash
docker logs n8n
```

실시간으로 로그를 확인하려면 다음 명령어를 사용합니다.

```bash
docker logs -f n8n
```

실시간 로그 확인을 종료하려면 `Ctrl + C`를 누릅니다.

---

## n8n 컨테이너 삭제

```bash
docker rm -f n8n
```

컨테이너를 삭제하더라도 `n8n_data` 볼륨을 삭제하지 않으면 기존 워크플로우와 계정 정보는 유지됩니다.

이후 동일한 볼륨을 연결해 n8n을 다시 실행하면 기존 데이터를 사용할 수 있습니다.

---

# 4. 기존 데이터를 유지한 채 n8n 다시 설치

기존 컨테이너를 삭제합니다.

```bash
docker rm -f n8n
```

이후 Windows 또는 Mac용 실행 명령어를 다시 입력합니다.

실행 명령어에 다음 볼륨 설정이 포함되어 있어야 합니다.

```text
-v n8n_data:/home/node/.n8n
```

이 설정을 통해 기존 `n8n_data` 볼륨에 저장된 데이터를 다시 불러옵니다.

---

# 5. 실습 데이터를 완전히 초기화하는 방법

## 5.1 n8n 컨테이너 삭제

```bash
docker rm -f n8n
```

## 5.2 데이터 볼륨 삭제

```bash
docker volume rm n8n_data
```

주의: `n8n_data` 볼륨을 삭제하면 아래 데이터가 모두 삭제됩니다.

- 사용자 계정
- 워크플로우
- 인증 정보
- 실행 기록
- n8n 설정

삭제된 데이터는 일반적으로 복구할 수 없습니다.

---

# 6. 자주 발생하는 오류

## 컨테이너 이름 충돌

다음과 유사한 오류가 발생할 수 있습니다.

```text
The container name "/n8n" is already in use
```

기존 컨테이너를 확인합니다.

```bash
docker ps -a
```

기존 컨테이너를 다시 사용할 경우:

```bash
docker start n8n
```

기존 컨테이너를 삭제하고 새로 실행할 경우:

```bash
docker rm -f n8n
```

이후 n8n 실행 명령어를 다시 입력합니다.

---

## 5678 포트가 이미 사용 중인 경우

다른 프로그램이 5678 포트를 사용하고 있다면 외부 포트를 변경할 수 있습니다.

```bash
docker run -d \
  --name n8n \
  -p 5679:5678 \
  -e GENERIC_TIMEZONE=Asia/Seoul \
  -e TZ=Asia/Seoul \
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n
```

이 경우 접속 주소는 다음과 같습니다.

```text
http://localhost:5679
```

---

# 7. 핵심 요약

## Windows

```powershell
docker volume create n8n_data

docker run -d `
  --name n8n `
  -p 5678:5678 `
  -e GENERIC_TIMEZONE=Asia/Seoul `
  -e TZ=Asia/Seoul `
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true `
  -v n8n_data:/home/node/.n8n `
  docker.n8n.io/n8nio/n8n
```

## Mac

```bash
docker volume create n8n_data

docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e GENERIC_TIMEZONE=Asia/Seoul \
  -e TZ=Asia/Seoul \
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n
```

## 접속 주소

```text
http://localhost:5678
```
