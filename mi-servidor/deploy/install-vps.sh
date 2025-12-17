#!/bin/bash
# ========================================
# Script de Despliegue en VPS
# ========================================
# Este script automatiza el despliegue del servidor JSON en un VPS Debian 13
#
# Requisitos previos:
# - VPS con Debian 13
# - Acceso root o sudo
# - DNS configurado: api.qu3v3d0.tech → IP del VPS
#
# Uso:
#   sudo bash install-vps.sh

set -e  # Salir si hay error

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🚀 Instalación VPS - Servidor JSON   ║${NC}"
echo -e "${BLUE}║  Dominio: api.qu3v3d0.tech             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Este script debe ejecutarse como root${NC}"
    echo "Usa: sudo bash $0"
    exit 1
fi

# ========================================
# PASO 1: Actualizar sistema
# ========================================
echo -e "${YELLOW}[1/8]${NC} Actualizando sistema..."
apt update && apt upgrade -y

# ========================================
# PASO 2: Instalar Node.js y npm
# ========================================
echo -e "${YELLOW}[2/8]${NC} Instalando Node.js y npm..."

# Verificar si ya está instalado
if command -v node &> /dev/null; then
    echo -e "${GREEN}✓${NC} Node.js ya instalado ($(node --version))"
else
    apt install -y nodejs npm
    echo -e "${GREEN}✓${NC} Node.js instalado: $(node --version)"
fi

# ========================================
# PASO 3: Instalar Nginx
# ========================================
echo -e "${YELLOW}[3/8]${NC} Instalando Nginx..."

if command -v nginx &> /dev/null; then
    echo -e "${GREEN}✓${NC} Nginx ya instalado ($(nginx -v 2>&1 | cut -d/ -f2))"
else
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo -e "${GREEN}✓${NC} Nginx instalado y activo"
fi

# ========================================
# PASO 4: Instalar Git
# ========================================
echo -e "${YELLOW}[4/8]${NC} Instalando Git..."

if command -v git &> /dev/null; then
    echo -e "${GREEN}✓${NC} Git ya instalado ($(git --version | cut -d' ' -f3))"
else
    apt install -y git
    echo -e "${GREEN}✓${NC} Git instalado"
fi

# ========================================
# PASO 5: Clonar repositorio
# ========================================
echo -e "${YELLOW}[5/8]${NC} Clonando repositorio..."

INSTALL_DIR="/opt/mi-servidor-json"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠${NC}  Directorio $INSTALL_DIR ya existe"
    read -p "¿Quieres eliminar y clonar de nuevo? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        rm -rf "$INSTALL_DIR"
    else
        echo "Usando repositorio existente"
    fi
fi

if [ ! -d "$INSTALL_DIR" ]; then
    git clone https://github.com/fp-bits/mi-servidor-json.git "$INSTALL_DIR"
    echo -e "${GREEN}✓${NC} Repositorio clonado"
fi

# Cambiar a la rama nginx@vps
cd "$INSTALL_DIR"
git checkout nginx@vps 2>/dev/null || echo "Ya en rama nginx@vps"

# Instalar dependencias npm
cd "$INSTALL_DIR/mi-servidor"
npm install
echo -e "${GREEN}✓${NC} Dependencias Node.js instaladas"

# ========================================
# PASO 6: Configurar servicio systemd
# ========================================
echo -e "${YELLOW}[6/8]${NC} Configurando servicio systemd..."

# Copiar archivo de servicio
cp "$INSTALL_DIR/mi-servidor/deploy/systemd/mi-servidor-json.service" \
   /etc/systemd/system/mi-servidor-json.service

# Ajustar permisos del directorio para www-data
chown -R www-data:www-data "$INSTALL_DIR"

# Recargar systemd y habilitar servicio
systemctl daemon-reload
systemctl enable mi-servidor-json
systemctl start mi-servidor-json

# Verificar estado
if systemctl is-active --quiet mi-servidor-json; then
    echo -e "${GREEN}✓${NC} Servicio Node.js activo y habilitado"
else
    echo -e "${RED}❌ Error: El servicio no arrancó correctamente${NC}"
    echo "Ver logs con: sudo journalctl -u mi-servidor-json -n 50"
    exit 1
fi

# ========================================
# PASO 7: Configurar Nginx
# ========================================
echo -e "${YELLOW}[7/8]${NC} Configurando Nginx como reverse proxy..."

# Copiar configuración
cp "$INSTALL_DIR/mi-servidor/deploy/nginx/mi-servidor-json.conf" \
   /etc/nginx/sites-available/mi-servidor-json

# Crear enlace simbólico
ln -sf /etc/nginx/sites-available/mi-servidor-json \
       /etc/nginx/sites-enabled/mi-servidor-json

# Eliminar configuración default si existe
rm -f /etc/nginx/sites-enabled/default

# Probar configuración
if nginx -t 2>&1 | grep -q "syntax is ok"; then
    echo -e "${GREEN}✓${NC} Configuración de Nginx válida"
    systemctl reload nginx
    echo -e "${GREEN}✓${NC} Nginx recargado"
else
    echo -e "${RED}❌ Error en configuración de Nginx${NC}"
    nginx -t
    exit 1
fi

# ========================================
# PASO 8: Verificar instalación
# ========================================
echo -e "${YELLOW}[8/8]${NC} Verificando instalación..."

sleep 2

# Probar endpoint local
if curl -s http://localhost:3000/api/status > /dev/null; then
    echo -e "${GREEN}✓${NC} Node.js responde en localhost:3000"
else
    echo -e "${RED}❌ Node.js no responde${NC}"
fi

# Probar Nginx
if curl -s http://localhost/api/status > /dev/null; then
    echo -e "${GREEN}✓${NC} Nginx reverse proxy funciona"
else
    echo -e "${RED}❌ Nginx no reenvía correctamente${NC}"
fi

# ========================================
# RESUMEN
# ========================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Instalación completada             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Estado de los servicios:${NC}"
systemctl status mi-servidor-json --no-pager | head -3
systemctl status nginx --no-pager | head -3
echo ""
echo -e "${BLUE}🌐 URLs de acceso:${NC}"
echo "   Local:     http://localhost/api/status"
echo "   Público:   http://api.qu3v3d0.tech/api/status"
echo ""
echo -e "${BLUE}📝 Comandos útiles:${NC}"
echo "   Ver logs Node.js:  sudo journalctl -u mi-servidor-json -f"
echo "   Ver logs Nginx:    sudo tail -f /var/log/nginx/mi-servidor-json.access.log"
echo "   Reiniciar Node:    sudo systemctl restart mi-servidor-json"
echo "   Reiniciar Nginx:   sudo systemctl reload nginx"
echo ""
echo -e "${YELLOW}⚠️  Pasos pendientes:${NC}"
echo "   1. Verificar que DNS apunta a este servidor: api.qu3v3d0.tech → $(hostname -I | awk '{print $1}')"
echo "   2. Instalar SSL con Let's Encrypt:"
echo "      sudo apt install certbot python3-certbot-nginx"
echo "      sudo certbot --nginx -d api.qu3v3d0.tech"
echo ""
