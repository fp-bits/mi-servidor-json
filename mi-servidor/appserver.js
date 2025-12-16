// ========================================
// SERVIDOR WEB CON EXPRESS - SERVIR JSON
// ========================================
// Guía didáctica: servidor básico que sirve JSON
// Autor: Lab ASIR/DAW
// Fecha: 2025-12-16

// 1. Importa el framework Express
const express = require('express');

// 2. Crea una instancia de la aplicación Express
const app = express();

// 3. Define el puerto en el que escuchará el servidor
const port = 3000;

// ========================================
// RUTA PRINCIPAL (HTML)
// ========================================
// Esta ruta sirve texto plano/HTML
app.get('/', (req, res) => {
  res.send(`
    <h1>🚀 Servidor JSON con Express</h1>
    <h2>Endpoints disponibles:</h2>
    <ul>
      <li><a href="/api/status">/api/status</a> - Estado del servidor</li>
      <li><a href="/api/data">/api/data</a> - Datos de ejemplo</li>
      <li><a href="/api/echo/HolaMundo">/api/echo/:mensaje</a> - Echo con parámetro</li>
    </ul>
  `);
});

// ========================================
// ENDPOINTS JSON
// ========================================

// ENDPOINT 1: /api/status
// Devuelve el estado del servidor en formato JSON
// Método: GET
// Respuesta: JSON con información del servidor
app.get('/api/status', (req, res) => {
  // res.json() automáticamente:
  // - Establece Content-Type: application/json
  // - Convierte el objeto JavaScript a JSON
  // - Envía la respuesta
  res.json({
    status: 'OK',
    uptime: process.uptime(), // Segundos que lleva ejecutándose
    timestamp: new Date().toISOString(),
    mensaje: 'Servidor funcionando correctamente'
  });
});

// ENDPOINT 2: /api/data
// Devuelve un array de datos de ejemplo
// Método: GET
// Respuesta: JSON con array de objetos
app.get('/api/data', (req, res) => {
  const datosEjemplo = [
    { id: 1, nombre: 'Alice', edad: 25, ciudad: 'Madrid' },
    { id: 2, nombre: 'Bob', edad: 30, ciudad: 'Barcelona' },
    { id: 3, nombre: 'Charlie', edad: 28, ciudad: 'Valencia' }
  ];

  res.json({
    success: true,
    count: datosEjemplo.length,
    data: datosEjemplo
  });
});

// ENDPOINT 3: /api/echo/:mensaje
// Recibe un parámetro en la URL y lo devuelve en JSON
// Método: GET
// Parámetro: mensaje (string en la URL)
// Ejemplo: /api/echo/HolaMundo
// Respuesta: JSON con el mensaje recibido
app.get('/api/echo/:mensaje', (req, res) => {
  // req.params contiene los parámetros de la URL
  const mensaje = req.params.mensaje;

  res.json({
    recibido: mensaje,
    longitud: mensaje.length,
    mayusculas: mensaje.toUpperCase(),
    minusculas: mensaje.toLowerCase(),
    timestamp: new Date().toISOString()
  });
});

// ========================================
// MANEJO DE RUTAS NO ENCONTRADAS (404)
// ========================================
// Esta ruta debe ir AL FINAL, después de todas las demás
app.use((req, res) => {
  res.status(404).json({
    error: 'Endpoint no encontrado',
    ruta: req.url,
    metodo: req.method,
    sugerencia: 'Visita http://localhost:3000/ para ver los endpoints disponibles'
  });
});

// ========================================
// INICIAR SERVIDOR
// ========================================
app.listen(port, () => {
  console.log(`
╔════════════════════════════════════════╗
║  🚀 Servidor JSON iniciado            ║
║  📡 Puerto: ${port}                      ║
║  🌐 URL: http://localhost:${port}      ║
║                                        ║
║  Endpoints disponibles:                ║
║  • GET /api/status                     ║
║  • GET /api/data                       ║
║  • GET /api/echo/:mensaje              ║
╚════════════════════════════════════════╝
  `);
});
