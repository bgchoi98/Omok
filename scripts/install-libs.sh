#!/bin/bash

# Omok Game - Library Installation Script
# This script downloads required libraries for the Omok game

echo "========================================="
echo "Omok Game - Library Installation"
echo "========================================="
echo ""

# Create lib directory if not exists
LIB_DIR="src/main/webapp/WEB-INF/lib"
mkdir -p "$LIB_DIR"

# Gson library
GSON_VERSION="2.10.1"
GSON_JAR="gson-${GSON_VERSION}.jar"
GSON_URL="https://repo1.maven.org/maven2/com/google/code/gson/gson/${GSON_VERSION}/${GSON_JAR}"

echo "Downloading Gson ${GSON_VERSION}..."
if command -v wget &> /dev/null; then
    wget -q -O "${LIB_DIR}/${GSON_JAR}" "${GSON_URL}"
elif command -v curl &> /dev/null; then
    curl -s -L -o "${LIB_DIR}/${GSON_JAR}" "${GSON_URL}"
else
    echo "Error: Neither wget nor curl is available. Please install one of them."
    exit 1
fi

if [ -f "${LIB_DIR}/${GSON_JAR}" ]; then
    echo "✓ Gson downloaded successfully: ${LIB_DIR}/${GSON_JAR}"
else
    echo "✗ Failed to download Gson"
    exit 1
fi

echo ""
echo "========================================="
echo "Installation completed!"
echo "========================================="
echo ""
echo "Required libraries:"
echo "  ✓ Gson ${GSON_VERSION}"
echo ""
echo "Note: javax.websocket-api is provided by Tomcat 8+."
echo "      If using older Tomcat, add it manually."
echo ""
echo "Next steps:"
echo "  1. Deploy to Tomcat 8 or higher"
echo "  2. Access http://localhost:8088/{your-context}/main.jsp"
echo "  3. Click '랜덤 매칭' or '게임 시작' to play Omok!"
echo ""
