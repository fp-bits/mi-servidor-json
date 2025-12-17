# 🚀 Archivos de Despliegue - VPS + Nginx

Esta carpeta contiene todos los archivos necesarios para desplegar el servidor JSON en un VPS con Debian 13 y Nginx.

**Dominio configurado:** `api.qu3v3d0.tech`

---

## 📁 Estructura

```
deploy/
├── README.md                    ← Este archivo
├── DESPLIEGUE-VPS.md           ← Guía completa paso a paso
├── install-vps.sh              ← Script de instalación automática
├── nginx/
│   └── mi-servidor-json.conf   ← Configuración Nginx (reverse proxy)
└── systemd/
    └── mi-servidor-json.service ← Servicio systemd para Node.js
```

---

## 🚀 Inicio Rápido

### Despliegue Automático (Recomendado)

```bash
# 1. Conectar al VPS
ssh root@IP_DEL_VPS

# 2. Descargar y ejecutar script
wget https://raw.githubusercontent.com/fp-bits/mi-servidor-json/nginx%40vps/mi-servidor/deploy/install-vps.sh
chmod +x install-vps.sh
sudo bash install-vps.sh
```

El script instala y configura todo automáticamente.

---

## 📚 Archivos Detallados

### 1. `install-vps.sh` - Script de Instalación

**Qué hace:**
- ✅ Actualiza el sistema (apt update/upgrade)
- ✅ Instala Node.js, npm, Nginx, Git
- ✅ Clona el repositorio en `/opt/mi-servidor-json`
- ✅ Instala dependencias npm
- ✅ Configura servicio systemd
- ✅ Configura Nginx como reverse proxy
- ✅ Verifica que todo funciona

**Tiempo:** ~5-10 minutos

**Uso:**
```bash
sudo bash install-vps.sh
```

---

### 2. `nginx/mi-servidor-json.conf` - Configuración Nginx

**Funcionalidad:**
- Escucha en puerto 80 (HTTP)
- Reenvía peticiones a Node.js (localhost:3000)
- Añade headers necesarios para proxying
- Gestiona logs separados
- Preparado para HTTPS (comentado)

**Dominio configurado:** `api.qu3v3d0.tech`

**Instalación manual:**
```bash
sudo cp nginx/mi-servidor-json.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/mi-servidor-json /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

**Características:**
- ✅ Headers de proxy correctos (`X-Real-IP`, `X-Forwarded-For`)
- ✅ Soporte WebSocket (para futuras mejoras)
- ✅ Endpoint `/health` para healthchecks
- ✅ Oculta versión de Nginx
- ✅ Bloquea archivos ocultos (.git, .env)
- ✅ Preparado para SSL/TLS

---

### 3. `systemd/mi-servidor-json.service` - Servicio systemd

**Funcionalidad:**
- Ejecuta Node.js como servicio del sistema
- Arranque automático al iniciar el VPS
- Reinicio automático si crashea
- Logs con journald

**Usuario:** `www-data` (seguridad)

**Instalación manual:**
```bash
sudo cp systemd/mi-servidor-json.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mi-servidor-json
sudo systemctl start mi-servidor-json
```

**Comandos útiles:**
```bash
# Ver estado
sudo systemctl status mi-servidor-json

# Ver logs en tiempo real
sudo journalctl -u mi-servidor-json -f

# Reiniciar
sudo systemctl restart mi-servidor-json
```

---

### 4. `DESPLIEGUE-VPS.md` - Guía Completa

**Contenido:**
- 📚 Conceptos: VPS, reverse proxy, systemd
- 🚀 Requisitos previos y configuración DNS
- 📦 Instalación automática y manual
- 🔒 Configuración SSL/TLS con Let's Encrypt
- 📊 Monitorización y logs
- 🐛 Resolución de problemas comunes
- 🔄 Procedimiento de actualización
- 🎓 Ejercicios para estudiantes

**Público:** Estudiantes ASIR/DAW nivel intermedio/avanzado

---

## 🏗️ Arquitectura Desplegada

```
Internet (https://api.qu3v3d0.tech)
          ↓
     Nginx :80/443
          ↓
   Node.js :3000 (localhost)
```

**Ventajas de esta arquitectura:**
1. Nginx gestiona SSL/TLS → Let's Encrypt automático
2. Mejor rendimiento → Nginx sirve archivos estáticos
3. Seguridad → Node.js no expuesto directamente
4. Escalabilidad → Múltiples apps en un solo VPS

---

## 📋 Requisitos Previos

### En el VPS
- ✅ Debian 13
- ✅ Acceso SSH como root
- ✅ IP pública
- ✅ Puertos 80 y 443 abiertos

### DNS
- ✅ Registro A configurado:
  ```
  api.qu3v3d0.tech → IP_DEL_VPS
  ```

**Verificar DNS:**
```bash
dig api.qu3v3d0.tech
# O
nslookup api.qu3v3d0.tech
```

---

## ✅ Verificación Post-Despliegue

```bash
# 1. Verificar servicios
systemctl status mi-servidor-json
systemctl status nginx

# 2. Probar endpoints localmente
curl http://localhost:3000/api/status
curl http://localhost/api/status

# 3. Probar públicamente (desde tu ordenador)
curl http://api.qu3v3d0.tech/api/status

# 4. Si tienes SSL
curl https://api.qu3v3d0.tech/api/status
```

**Respuesta esperada:**
```json
{
  "status": "OK",
  "uptime": 123.456,
  "timestamp": "2025-12-16T...",
  "mensaje": "Servidor funcionando correctamente"
}
```

---

## 🔒 Instalar SSL (HTTPS)

```bash
# 1. Instalar certbot
sudo apt install certbot python3-certbot-nginx

# 2. Obtener certificado
sudo certbot --nginx -d api.qu3v3d0.tech

# 3. Verificar
curl https://api.qu3v3d0.tech/api/status
```

Certbot modifica automáticamente la configuración de Nginx y añade renovación automática.

---

## 🐛 Troubleshooting Rápido

| Problema | Causa | Solución |
|----------|-------|----------|
| 502 Bad Gateway | Node.js parado | `systemctl restart mi-servidor-json` |
| DNS no resuelve | Registro A incorrecto | Verificar con `dig` |
| Puerto bloqueado | Firewall | `ufw allow 80` `ufw allow 443` |
| SSL falla | DNS no propagado | Esperar 24-48h |

Ver guía completa en `DESPLIEGUE-VPS.md` para más detalles.

---

## 📊 Logs y Monitorización

```bash
# Logs Node.js (journald)
sudo journalctl -u mi-servidor-json -f

# Logs Nginx
sudo tail -f /var/log/nginx/mi-servidor-json.access.log
sudo tail -f /var/log/nginx/mi-servidor-json.error.log

# Estado de servicios
systemctl status mi-servidor-json nginx
```

---

## 🔄 Actualizar Aplicación

```bash
cd /opt/mi-servidor-json
git pull origin nginx@vps
cd mi-servidor
npm install
sudo systemctl restart mi-servidor-json
```

---

## 📚 Para Estudiantes

**Antes de desplegar:**
1. Lee `DESPLIEGUE-VPS.md` completo
2. Asegúrate de tener DNS configurado
3. Ten acceso SSH al VPS

**Método recomendado:**
- Primera vez: Usa `install-vps.sh` (automático)
- Segunda vez: Repite manual para entender cada paso

**Después del despliegue:**
- Practica comandos de gestión (systemctl, journalctl)
- Analiza logs de acceso
- Experimenta añadiendo endpoints
- Instala SSL con Let's Encrypt

---

## 🎯 Próximos Pasos

Una vez desplegado correctamente:

1. **Instalar SSL** con Let's Encrypt
2. **Monitorización** con Nagios/Zabbix
3. **Backups automáticos** del código y logs
4. **CI/CD** con GitHub Actions
5. **Rate limiting** en Nginx
6. **Integración con base de datos**

---

*Archivos preparados para estudiantes ASIR/DAW - Despliegue de Aplicaciones Web*
