#!/bin/bash
# ========================================
# Script de prueba del servidor JSON
# ========================================
# Este script:
# 1. Arranca el servidor
# 2. Espera a que esté listo
# 3. Prueba todos los endpoints
# 4. Detiene el servidor
#
# Uso: bash test-server.sh

echo "═══════════════════════════════════════"
echo "🧪 Script de Prueba - Servidor JSON"
echo "═══════════════════════════════════════"
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. Matar cualquier instancia previa
echo -e "${YELLOW}[1/5]${NC} Limpiando procesos anteriores..."
pkill -f "node.*appserver" 2>/dev/null
sleep 1

# 2. Arrancar servidor en background
echo -e "${YELLOW}[2/5]${NC} Arrancando servidor..."
node appserver.js > /tmp/server-test.log 2>&1 &
SERVER_PID=$!
echo "      PID del servidor: $SERVER_PID"

# 3. Esperar a que el servidor esté listo
echo -e "${YELLOW}[3/5]${NC} Esperando a que el servidor esté listo..."
sleep 2

# Verificar que el puerto está escuchando
MAX_RETRIES=10
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        break
    fi
    RETRY=$((RETRY+1))
    sleep 0.5
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo -e "${RED}❌ Error: El servidor no responde${NC}"
    echo "Log del servidor:"
    cat /tmp/server-test.log 2>/dev/null || echo "No hay log"

    # Verificar si el proceso sigue vivo
    if ps -p $SERVER_PID > /dev/null 2>&1; then
        echo "El proceso sigue ejecutándose (PID: $SERVER_PID)"
        kill $SERVER_PID 2>/dev/null
    else
        echo "El proceso terminó prematuramente"
    fi
    exit 1
fi

echo -e "${GREEN}✓${NC} Servidor listo!"
echo ""

# 4. Probar endpoints
echo -e "${YELLOW}[4/5]${NC} Probando endpoints..."
echo ""

# Función para probar un endpoint
test_endpoint() {
    local name=$1
    local url=$2

    echo -e "${BLUE}━━━ Test: $name ━━━${NC}"
    echo "URL: $url"
    echo ""

    # Hacer la petición y guardar resultado
    response=$(curl -s -w "\n%{http_code}" "$url")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)

    # Mostrar código HTTP
    if [ "$http_code" -eq 200 ]; then
        echo -e "HTTP Status: ${GREEN}$http_code OK${NC}"
    elif [ "$http_code" -eq 404 ]; then
        echo -e "HTTP Status: ${YELLOW}$http_code NOT FOUND${NC}"
    else
        echo -e "HTTP Status: ${RED}$http_code${NC}"
    fi

    # Mostrar respuesta (formateada con jq si está disponible)
    echo "Respuesta:"
    if command -v jq &> /dev/null; then
        echo "$body" | jq . 2>/dev/null || echo "$body"
    else
        echo "$body"
    fi

    echo ""
}

# Probar cada endpoint
test_endpoint "Estado del servidor" "http://localhost:3000/api/status"
test_endpoint "Datos de ejemplo" "http://localhost:3000/api/data"
test_endpoint "Echo con parámetro" "http://localhost:3000/api/echo/ASIR2024"
test_endpoint "Ruta inexistente (404)" "http://localhost:3000/no-existe"

# 5. Detener servidor
echo -e "${YELLOW}[5/5]${NC} Deteniendo servidor..."
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Pruebas completadas exitosamente${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "💡 Tips para estudiantes:"
echo "   • Usa 'curl URL' para probar endpoints desde terminal"
echo "   • Usa 'curl URL | jq .' para formatear JSON"
echo "   • Abre http://localhost:3000 en el navegador"
echo "   • Instala extensión JSONView en tu navegador"
echo ""
