#!/usr/bin/env bash
set -euo pipefail
``
cd "$(dirname "$0")/.."

# 출력 위치(톰캣이 읽는 위치)
OUT="src/main/webapp/WEB-INF/classes"
mkdir -p "$OUT"

# Tomcat이 제공하는 servlet-api와 websocket-api로 컴파일
SERVLET_API="$HOME/tomcat9/lib/servlet-api.jar"
WEBSOCKET_API="$HOME/tomcat9/lib/websocket-api.jar"
if [[ ! -f "$SERVLET_API" ]]; then
  echo "ERROR: servlet-api.jar not found at: $SERVLET_API"
  echo "Check your Tomcat path (~/tomcat9)."
  exit 1
fi
if [[ ! -f "$WEBSOCKET_API" ]]; then
  echo "ERROR: websocket-api.jar not found at: $WEBSOCKET_API"
  echo "Check your Tomcat path (~/tomcat9)."
  exit 1
fi

# WEB-INF/lib 아래 jar들도 같이 classpath에 포함(있으면)
LIBS=$(find src/main/webapp/WEB-INF/lib -name "*.jar" 2>/dev/null | tr '\n' ':')

# Java 소스 위치
SRC_DIR="src/main/java"
if [[ ! -d "$SRC_DIR" ]]; then
  echo "ERROR: source dir not found: $SRC_DIR"
  exit 1
fi

SOURCES=$(find "$SRC_DIR" -name "*.java" || true)
if [[ -z "$SOURCES" ]]; then
  echo "No Java sources found under $SRC_DIR (nothing to compile)."
  exit 0
fi

echo "[build] Compiling to $OUT ..."
javac --release 8 -encoding UTF-8 \
  -cp "$SERVLET_API:$WEBSOCKET_API:$LIBS" \
  -d "$OUT" \
  $SOURCES

echo "[build] Done."
