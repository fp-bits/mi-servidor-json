# Guía de Despliegue en VPS con Nginx

**Dominio:** api.qu3v3d0.tech
**Sistema:** Debian 13
**Arquitectura:** Node.js + Express + Nginx (reverse proxy)
**Fecha:** 2025-12-16
**Nivel:** Intermedio/Avanzado

---

## 📚 Conceptos Clave

### ¿Qué es un VPS?

**VPS (Virtual Private Server)** = Servidor privado virtual

- Máquina Linux dedicada en la nube
- Acceso root completo
- IP pública estática
- Recursos garantizados (RAM, CPU, disco)
- Ejemplos: DigitalOcean, Hetzner, OVH, AWS EC2

### ¿Por qué Nginx + Node.js?

**Arquitectura:**
```
Internet
   ↓
Nginx (puerto 80/443)
   ↓
Node.js (puerto 3000, localhost)
```

**Ventajas:**
1. **Nginx gestiona SSL/TLS** → Let's Encrypt automático
2. **Mejor rendimiento** → Nginx sirve archivos estáticos
3. **Seguridad** → Node.js no expuesto directamente
4. **Múltiples apps** → Un Nginx, varias apps Node.js
5. **Profesional** → Arquitectura estándar en producción

---

## 🚀 Requisitos Previos

### En el VPS

- [x] Debian 13 instalado
- [x] Acceso SSH como root
- [x] IP pública del servidor
- [x] Puerto 80 y 443 abiertos en firewall

### En tu DNS

Configurar registro A:
```
api.qu3v3d0.tech  →  IP_DEL_VPS
```

**Verificar DNS (desde tu ordenador):**
```bash
dig api.qu3v3d0.tech
# O
nslookup api.qu3v3d0.tech
```

Debe devolver la IP de tu VPS.

---

## 📦 Instalación Automática

### Opción 1: Script automatizado (recomendado)

```bash
# 1. Conectar al VPS
ssh root@IP_DEL_VPS

# 2. Descargar y ejecutar script
wget https://raw.githubusercontent.com/fp-bits/mi-servidor-json/nginx%40vps/mi-servidor/deploy/install-vps.sh
chmod +x install-vps.sh
sudo bash install-vps.sh
```

El script hace automáticamente:
- ✅ Actualiza el sistema
- ✅ Instala Node.js, npm, Nginx, Git
- ✅ Clona el repositorio
- ✅ Configura servicio systemd
- ✅ Configura Nginx como reverse proxy
- ✅ Verifica que todo funciona

**Tiempo estimado:** 5-10 minutos

---

## 🔧 Instalación Manual (paso a paso)

Si prefieres entender cada paso:

### Paso 1: Actualizar sistema

```bash
ssh root@IP_DEL_VPS
apt update && apt upgrade -y
```

### Paso 2: Instalar Node.js y npm

```bash
# Verificar versión disponible
apt search nodejs

# Instalar
apt install -y nodejs npm

# Verificar instalación
node --version  # Debe mostrar v18 o superior
npm --version
```

### Paso 3: Instalar Nginx

```bash
apt install -y nginx

# Habilitar y arrancar
systemctl enable nginx
systemctl start nginx

# Verificar estado
systemctl status nginx

# Verificar que responde
curl http://localhost
```

### Paso 4: Clonar repositorio

```bash
cd /opt
git clone https://github.com/fp-bits/mi-servidor-json.git
cd mi-servidor-json

# Cambiar a rama nginx@vps
git checkout nginx@vps

# Instalar dependencias
cd mi-servidor
npm install
```

### Paso 5: Probar servidor manualmente (opcional)

```bash
# Ejecutar servidor
node appserver.js

# En otra terminal, probar:
curl http://localhost:3000/api/status

# Detener con Ctrl+C
```

### Paso 6: Configurar servicio systemd

**¿Por qué systemd?**
- Arranca el servidor automáticamente al iniciar el VPS
- Reinicia automáticamente si crashea
- Gestiona logs con journald
- Control con `systemctl`

```bash
# Copiar archivo de servicio
cp /opt/mi-servidor-json/mi-servidor/deploy/systemd/mi-servidor-json.service \
   /etc/systemd/system/

# Ajustar permisos (importante para seguridad)
chown -R www-data:www-data /opt/mi-servidor-json

# Recargar systemd
systemctl daemon-reload

# Habilitar servicio (arranque automático)
systemctl enable mi-servidor-json

# Iniciar servicio
systemctl start mi-servidor-json

# Verificar estado
systemctl status mi-servidor-json

# Ver logs en tiempo real
journalctl -u mi-servidor-json -f
```

### Paso 7: Configurar Nginx

```bash
# Copiar configuración
cp /opt/mi-servidor-json/mi-servidor/deploy/nginx/mi-servidor-json.conf \
   /etc/nginx/sites-available/mi-servidor-json

# Crear enlace simbólico
ln -s /etc/nginx/sites-available/mi-servidor-json \
      /etc/nginx/sites-enabled/mi-servidor-json

# Eliminar configuración default (opcional)
rm /etc/nginx/sites-enabled/default

# Probar configuración
nginx -t

# Si OK, recargar Nginx
systemctl reload nginx
```

### Paso 8: Verificar funcionamiento

```bash
# Probar Node.js directamente
curl http://localhost:3000/api/status

# Probar a través de Nginx
curl http://localhost/api/status

# Probar desde el exterior (en tu ordenador, no en el VPS)
curl http://api.qu3v3d0.tech/api/status
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

## 🔒 Instalar SSL/TLS (HTTPS)

### Con Let's Encrypt (gratis)

```bash
# 1. Instalar certbot
apt install -y certbot python3-certbot-nginx

# 2. Obtener certificado (automático)
certbot --nginx -d api.qu3v3d0.tech

# Seguir las instrucciones:
# - Email para notificaciones
# - Aceptar términos
# - Redirigir HTTP a HTTPS: Sí

# 3. Verificar
curl https://api.qu3v3d0.tech/api/status
```

**Certbot hace automáticamente:**
- ✅ Obtiene certificado SSL
- ✅ Modifica configuración de Nginx
- ✅ Añade redirección HTTP → HTTPS
- ✅ Configura renovación automática

**Renovación automática:**
```bash
# Verificar timer de renovación
systemctl status certbot.timer

# Probar renovación manual
certbot renew --dry-run
```

---

## 📊 Monitorización y Logs

### Ver logs del servidor Node.js

```bash
# Logs en tiempo real
journalctl -u mi-servidor-json -f

# Últimas 50 líneas
journalctl -u mi-servidor-json -n 50

# Logs de hoy
journalctl -u mi-servidor-json --since today

# Logs con errores
journalctl -u mi-servidor-json -p err
```

### Ver logs de Nginx

```bash
# Access log (peticiones)
tail -f /var/log/nginx/mi-servidor-json.access.log

# Error log
tail -f /var/log/nginx/mi-servidor-json.error.log

# Analizar peticiones por IP
awk '{print $1}' /var/log/nginx/mi-servidor-json.access.log | sort | uniq -c | sort -nr | head -10
```

### Comandos de gestión

```bash
# Estado de servicios
systemctl status mi-servidor-json
systemctl status nginx

# Reiniciar servicios
systemctl restart mi-servidor-json
systemctl reload nginx

# Ver procesos Node.js
ps aux | grep node

# Ver uso de recursos
htop
```

---

## 🐛 Resolución de Problemas

### Problema 1: "502 Bad Gateway" en Nginx

**Causa:** Node.js no está corriendo

**Solución:**
```bash
# Verificar estado del servicio
systemctl status mi-servidor-json

# Ver qué falló
journalctl -u mi-servidor-json -n 50

# Reiniciar
systemctl restart mi-servidor-json
```

### Problema 2: DNS no resuelve

**Causa:** Registro A no configurado o propagación DNS

**Verificar:**
```bash
# En tu ordenador
dig api.qu3v3d0.tech

# Debe devolver la IP del VPS
# Si no, revisar configuración DNS del dominio
```

**Propagación DNS:** Puede tardar hasta 24-48h

### Problema 3: Puerto 80/443 bloqueado

**Causa:** Firewall del VPS

**Solución:**
```bash
# Si usas ufw
ufw allow 80/tcp
ufw allow 443/tcp
ufw status

# Si usas iptables
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables-save > /etc/iptables/rules.v4
```

### Problema 4: Certificado SSL no se obtiene

**Causa:** DNS no apunta al servidor o puerto 80 bloqueado

**Verificar:**
```bash
# 1. DNS correcto
dig api.qu3v3d0.tech

# 2. Puerto 80 accesible desde fuera
# (en tu ordenador)
telnet api.qu3v3d0.tech 80

# 3. Ver logs de certbot
cat /var/log/letsencrypt/letsencrypt.log
```

---

## 🔄 Actualizar la Aplicación

### Opción 1: Pull manual

```bash
cd /opt/mi-servidor-json
git pull origin nginx@vps
cd mi-servidor
npm install  # Si hay nuevas dependencias
systemctl restart mi-servidor-json
```

### Opción 2: Script de actualización

```bash
#!/bin/bash
# update-app.sh

cd /opt/mi-servidor-json
git pull origin nginx@vps
cd mi-servidor
npm install
systemctl restart mi-servidor-json
echo "✅ Aplicación actualizada"
```

Usar:
```bash
chmod +x update-app.sh
sudo ./update-app.sh
```

---

## 📊 Arquitectura Final

```
┌─────────────────────────────────────────┐
│  Internet                               │
│  (https://api.qu3v3d0.tech)            │
└──────────────┬──────────────────────────┘
               │
               │ HTTPS (443) / HTTP (80)
               ↓
┌──────────────────────────────────────────┐
│  Nginx (Reverse Proxy)                   │
│  - Gestiona SSL/TLS                      │
│  - Logs de acceso                        │
│  - Headers de proxy                      │
└──────────────┬───────────────────────────┘
               │
               │ HTTP (localhost:3000)
               ↓
┌──────────────────────────────────────────┐
│  Node.js + Express                       │
│  - Servicio systemd                      │
│  - Usuario: www-data                     │
│  - Logs: journald                        │
└──────────────────────────────────────────┘
```

---

## ✅ Checklist de Despliegue

### Configuración DNS
- [ ] Registro A configurado: api.qu3v3d0.tech → IP
- [ ] DNS propagado (verificado con `dig`)

### Instalación VPS
- [ ] Sistema actualizado
- [ ] Node.js y npm instalados
- [ ] Nginx instalado y activo
- [ ] Repositorio clonado en /opt
- [ ] Dependencias npm instaladas

### Configuración Servicios
- [ ] Servicio systemd configurado
- [ ] Servicio habilitado (arranque automático)
- [ ] Servicio activo y funcionando
- [ ] Nginx configurado como reverse proxy
- [ ] Configuración Nginx validada (`nginx -t`)

### Verificación
- [ ] Node.js responde en localhost:3000
- [ ] Nginx reenvía correctamente
- [ ] Acceso público funciona: http://api.qu3v3d0.tech
- [ ] SSL instalado (opcional pero recomendado)
- [ ] HTTPS funciona: https://api.qu3v3d0.tech

### Producción
- [ ] Logs configurados
- [ ] Renovación SSL automática
- [ ] Firewall configurado
- [ ] Procedimiento de actualización documentado

---

## 🎓 Ejercicios para Estudiantes

### Ejercicio 1: Añadir nuevo endpoint

1. Modificar `appserver.js` localmente
2. Hacer commit y push
3. En el VPS, hacer pull
4. Reiniciar servicio
5. Verificar que el nuevo endpoint funciona

### Ejercicio 2: Configurar logs personalizados

Modificar `mi-servidor-json.conf` para:
- Logs en formato JSON
- Separar logs por código de estado (200, 404, 500)
- Rotar logs diariamente

### Ejercicio 3: Optimizar Nginx

Añadir a la configuración:
- Compresión gzip
- Cache de respuestas estáticas
- Rate limiting (protección anti-DDoS)

---

## 📚 Recursos Adicionales

- [Nginx: Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [systemd: Getting Started](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Let's Encrypt: How It Works](https://letsencrypt.org/how-it-works/)
- [DigitalOcean: Initial Server Setup (Debian)](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-debian-12)

---

*Guía creada para estudiantes de ASIR/DAW - Despliegue de Aplicaciones Web*
