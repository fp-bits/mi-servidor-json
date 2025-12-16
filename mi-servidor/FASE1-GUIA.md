# Fase 1: Servidor JSON Básico (KISS) ✓ COMPLETADA

**Fecha:** 2025-12-16
**Objetivo:** Aprender a servir JSON con Express de forma simple
**Tiempo estimado:** 30 minutos
**Nivel:** Básico/Intermedio

---

## 📚 Conceptos Aprendidos

1. **`res.json()` vs `res.send()`**
   - `res.send()` → Envía texto plano o HTML
   - `res.json()` → Envía JSON (establece automáticamente `Content-Type: application/json`)

2. **Parámetros dinámicos en rutas**
   - Sintaxis: `/api/echo/:parametro`
   - Acceso: `req.params.parametro`

3. **Códigos de estado HTTP**
   - `200 OK` → Petición exitosa
   - `404 Not Found` → Recurso no encontrado

4. **Middleware de manejo de errores**
   - `app.use()` al final captura rutas no encontradas

---

## 🔧 Cambios Realizados en `appserver.js`

### Antes (17 líneas)
```javascript
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('¡Hola Mundo desde mi servidor JS!');
});

app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});
```

### Después (121 líneas)
✅ **Añadidos 3 endpoints JSON:**
- `GET /api/status` → Estado del servidor
- `GET /api/data` → Array de datos de ejemplo
- `GET /api/echo/:mensaje` → Eco con parámetro dinámico

✅ **Manejador 404 personalizado** (devuelve JSON, no HTML)

✅ **Página de inicio con links** a todos los endpoints

✅ **Comentarios didácticos** en cada sección

---

## 🚀 Cómo Probar

### Opción 1: Script automático (recomendado)
```bash
bash test-server.sh
```

Este script:
1. Limpia puertos ocupados
2. Arranca el servidor
3. Prueba todos los endpoints
4. Muestra resultados formateados
5. Detiene el servidor automáticamente

### Opción 2: Manualmente

#### Paso 1: Arrancar servidor
```bash
node appserver.js
```

Deberías ver:
```
╔════════════════════════════════════════╗
║  🚀 Servidor JSON iniciado            ║
║  📡 Puerto: 3000                      ║
║  🌐 URL: http://localhost:3000      ║
║                                        ║
║  Endpoints disponibles:                ║
║  • GET /api/status                     ║
║  • GET /api/data                       ║
║  • GET /api/echo/:mensaje              ║
╚════════════════════════════════════════╝
```

#### Paso 2: Probar endpoints (en otra terminal)

**Endpoint 1: Estado del servidor**
```bash
curl http://localhost:3000/api/status
```

**Respuesta esperada:**
```json
{
  "status": "OK",
  "uptime": 12.345,
  "timestamp": "2025-12-16T15:46:34.872Z",
  "mensaje": "Servidor funcionando correctamente"
}
```

**Endpoint 2: Datos de ejemplo**
```bash
curl http://localhost:3000/api/data
```

**Respuesta esperada:**
```json
{
  "success": true,
  "count": 3,
  "data": [
    { "id": 1, "nombre": "Alice", "edad": 25, "ciudad": "Madrid" },
    { "id": 2, "nombre": "Bob", "edad": 30, "ciudad": "Barcelona" },
    { "id": 3, "nombre": "Charlie", "edad": 28, "ciudad": "Valencia" }
  ]
}
```

**Endpoint 3: Echo con parámetro**
```bash
curl http://localhost:3000/api/echo/ASIR2024
```

**Respuesta esperada:**
```json
{
  "recibido": "ASIR2024",
  "longitud": 8,
  "mayusculas": "ASIR2024",
  "minusculas": "asir2024",
  "timestamp": "2025-12-16T15:46:34.911Z"
}
```

**Endpoint inexistente (404)**
```bash
curl http://localhost:3000/no-existe
```

**Respuesta esperada:**
```json
{
  "error": "Endpoint no encontrado",
  "ruta": "/no-existe",
  "metodo": "GET",
  "sugerencia": "Visita http://localhost:3000/ para ver los endpoints disponibles"
}
```

#### Paso 3: Probar en navegador

Abre: http://localhost:3000

Verás una página HTML con enlaces clicables a cada endpoint.

---

## 🐛 Resolución de Problemas

### Problema: "Error: listen EADDRINUSE: address already in use :::3000"

**Causa:** El puerto 3000 está ocupado por otro proceso.

**Solución 1:** Matar el proceso que ocupa el puerto
```bash
# Ver qué proceso usa el puerto
lsof -i :3000

# Matar el proceso (reemplaza PID con el número que aparece)
kill PID
```

**Solución 2:** Cambiar el puerto del servidor
```javascript
const port = 3001; // O cualquier otro puerto libre
```

### Problema: "Cannot GET /api/status" (404 en endpoints existentes)

**Causa:** Hay otro servidor (como browser-sync) interceptando las peticiones.

**Solución:**
```bash
# Buscar procesos Node.js
ps aux | grep node

# Matar procesos específicos
kill PID1 PID2 PID3

# O matar todos los procesos node (¡cuidado!)
pkill node
```

---

## 💡 Ejercicios Propuestos para Estudiantes

### Ejercicio 1: Nuevo endpoint `/api/fecha`
Crea un endpoint que devuelva la fecha actual en varios formatos:
```json
{
  "iso": "2025-12-16T15:46:34.872Z",
  "local": "16/12/2025, 16:46:34",
  "unix": 1734361594872,
  "dia": "lunes"
}
```

<details>
<summary>💡 Pista</summary>

```javascript
app.get('/api/fecha', (req, res) => {
  const ahora = new Date();
  res.json({
    iso: ahora.toISOString(),
    local: ahora.toLocaleString('es-ES'),
    unix: ahora.getTime(),
    dia: ahora.toLocaleDateString('es-ES', { weekday: 'long' })
  });
});
```
</details>

### Ejercicio 2: Endpoint con cálculo `/api/suma/:a/:b`
Crea un endpoint que sume dos números pasados como parámetros:
```bash
curl http://localhost:3000/api/suma/15/27
# Respuesta: {"a": 15, "b": 27, "resultado": 42}
```

<details>
<summary>💡 Pista</summary>

```javascript
app.get('/api/suma/:a/:b', (req, res) => {
  const a = parseInt(req.params.a);
  const b = parseInt(req.params.b);

  res.json({
    a: a,
    b: b,
    resultado: a + b
  });
});
```
</details>

### Ejercicio 3: Validación de datos
Modifica el endpoint `/api/echo/:mensaje` para rechazar mensajes vacíos o muy largos:
- Mínimo 3 caracteres
- Máximo 50 caracteres
- Devolver error 400 si no cumple

<details>
<summary>💡 Pista</summary>

```javascript
app.get('/api/echo/:mensaje', (req, res) => {
  const mensaje = req.params.mensaje;

  // Validaciones
  if (mensaje.length < 3) {
    return res.status(400).json({
      error: "Mensaje muy corto",
      minimo: 3,
      recibido: mensaje.length
    });
  }

  if (mensaje.length > 50) {
    return res.status(400).json({
      error: "Mensaje muy largo",
      maximo: 50,
      recibido: mensaje.length
    });
  }

  // Todo OK
  res.json({
    recibido: mensaje,
    longitud: mensaje.length,
    mayusculas: mensaje.toUpperCase(),
    minusculas: mensaje.toLowerCase(),
    timestamp: new Date().toISOString()
  });
});
```
</details>

---

## 🔗 Recursos Adicionales

- [MDN: Trabajando con JSON](https://developer.mozilla.org/es/docs/Learn/JavaScript/Objects/JSON)
- [Express.js: Documentación de `res.json()`](https://expressjs.com/es/api.html#res.json)
- [MDN: Códigos de estado HTTP](https://developer.mozilla.org/es/docs/Web/HTTP/Status)
- [Express.js: Routing](https://expressjs.com/es/guide/routing.html)

---

## 📝 Checklist para Estudiantes

- [ ] He ejecutado el servidor y funciona
- [ ] He probado todos los endpoints con `curl`
- [ ] He probado los endpoints en el navegador
- [ ] He entendido la diferencia entre `res.send()` y `res.json()`
- [ ] He creado al menos un endpoint nuevo (ejercicio)
- [ ] He probado el manejo de errores (404)
- [ ] He leído y entendido todos los comentarios del código

---

## 🎯 Próximos Pasos

Una vez completada esta fase, estás listo para:

1. **Fase 2:** Crear rama `nginx@vps` y preparar arquitectura de producción
2. **Fase 3:** Desplegar en VPS con Nginx como reverse proxy
3. **Fase 4:** Crear API REST completa con CRUD, middleware y validaciones

---

## 📊 Resultados de Prueba

```
═══════════════════════════════════════
🧪 Script de Prueba - Servidor JSON
═══════════════════════════════════════

[1/5] Limpiando procesos anteriores...
[2/5] Arrancando servidor...
[3/5] Esperando a que el servidor esté listo...
✓ Servidor listo!

[4/5] Probando endpoints...

━━━ Test: Estado del servidor ━━━
HTTP Status: 200 OK ✓

━━━ Test: Datos de ejemplo ━━━
HTTP Status: 200 OK ✓

━━━ Test: Echo con parámetro ━━━
HTTP Status: 200 OK ✓

━━━ Test: Ruta inexistente (404) ━━━
HTTP Status: 404 NOT FOUND ✓

[5/5] Deteniendo servidor...

═══════════════════════════════════════
✓ Pruebas completadas exitosamente
═══════════════════════════════════════
```

**Fecha de prueba:** 2025-12-16 16:46:34
**Resultado:** ✅ TODOS LOS TESTS PASARON

---

*Guía creada para estudiantes de ASIR/DAW - Lab de Sistemas y Redes*
