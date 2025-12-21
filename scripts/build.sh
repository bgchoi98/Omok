#!/bin/bash

echo "🔨 빌드 시작..."

# 프로젝트 루트 디렉토리
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 산출물 디렉토리
OUTPUT_DIR="src/main/webapp/WEB-INF/classes"
SOURCE_DIR="src/main/java"

# Tomcat 경로
TOMCAT_HOME="$HOME/tomcat9"

# Classpath 구성
CLASSPATH="$OUTPUT_DIR"
CLASSPATH="$CLASSPATH:$TOMCAT_HOME/lib/servlet-api.jar"
CLASSPATH="$CLASSPATH:$TOMCAT_HOME/lib/websocket-api.jar"

# WEB-INF/lib의 모든 jar 추가
for jar in src/main/webapp/WEB-INF/lib/*.jar; do
    if [ -f "$jar" ]; then
        CLASSPATH="$CLASSPATH:$jar"
    fi
done

# 산출물 디렉토리 생성
mkdir -p "$OUTPUT_DIR"

# Java 파일 찾기
JAVA_FILES=$(find "$SOURCE_DIR" -name "*.java")

if [ -z "$JAVA_FILES" ]; then
    echo "❌ 컴파일할 Java 파일을 찾을 수 없습니다."
    exit 1
fi

# 컴파일
echo "📦 컴파일 중..."
javac --release 8 \
    -encoding UTF-8 \
    -d "$OUTPUT_DIR" \
    -cp "$CLASSPATH" \
    $JAVA_FILES

if [ $? -eq 0 ]; then
    echo "✅ 빌드 성공!"
    echo "📂 산출물 위치: $OUTPUT_DIR"
else
    echo "❌ 빌드 실패!"
    exit 1
fi
