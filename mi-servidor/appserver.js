// 1. Importa el framework Express
const express = require('express');
// 2. Crea una instancia de la aplicación Express
const app = express();
// 3. Define el puerto en el que escuchará el servidor
const port = 3000;

// 4. Define una ruta para la página principal (/)
app.get('/', (req, res) => {
  // 5. Envía una respuesta al cliente
  res.send('¡Hola Mundo desde mi servidor JS!');
});

// 6. Inicia el servidor y lo pone a escuchar en el puerto definido
app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});
