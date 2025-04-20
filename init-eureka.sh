#!/bin/bash

# 명령어 실패 시 스크립트 종료
set -euo pipefail

# 로그 출력 함수
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# 에러 발생 시 로그와 함께 종료하는 함수
error() {
  log "Error on line $1"
  exit 1
}

trap 'error $LINENO' ERR

log "스크립트 실행 시작."

# docker network 생성
if docker network ls --format '{{.Name}}' | grep -q '^nansan-network$'; then
  log "Docker network named 'nansan-network' is already existed."
else
  log "Docker network named 'nansan-network' is creating..."
  docker network create --driver bridge nansan-network
fi

# Build Gradle
log "build gradle"
./gradlew clean build

# 실행중인 Eureka Container 삭제
log "eureka container remove."
docker rm -f eureka

# 기존 eureka 이미지를 삭제하고 새로 빌드
log "eureka image remove and build."
docker rmi eureka:latest || true
docker build -t eureka:latest .

# Docker로 Eureka-server 서비스 실행
log "Execute eureka..."
docker run -d \
  --name eureka \
  --restart unless-stopped \
  --network nansan-network \
  eureka:latest

echo "==== Succeed!!! ===="
