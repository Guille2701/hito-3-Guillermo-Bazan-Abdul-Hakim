# 🚀 HITO 3: Automatización Inteligente - Checklist del Proyecto

**Equipo:**
- **Guillermo Bazán:** Proyecto A (Sistema RAG Educativo)
- **Abdul Hakim:** Proyecto B (Chatbot Multiherramienta)

---

## 🛠️ Fase 1: Configuración Base e Infraestructura (TRABAJO CONJUNTO)

### 1.1 Repositorio y Estructura
- [x] Inicializar el repositorio Git (`git init`).
- [x] Crear archivo `.gitignore` (excluir node_modules, .env, etc.).
- [x] Crear la estructura de carpetas exacta:
  - [x] `docker/`
  - [x] `n8n/workflows/`
  - [x] `postgres/`
  - [x] `tests/`
  - [x] `docs/capturas/`

### 1.2 Docker y Servicios
- [x] Crear archivo `docker/.env.example` (sin contraseñas reales).
- [x] Crear archivo `docker/docker-compose.yml` que incluya:
  - [x] Servicio **n8n** (puerto 5678, volúmenes de datos).
  - [x] Servicio **Ollama** (ideal usar modelos más ligeros si va lento, como `llama3.2`, `phi` o `gemma`).
  - [x] Servicio **PostgreSQL** (volúmenes de datos, variables de entorno, carga del `init.sql`).
  - [x] Servicio **Qdrant** (puerto 6333 para la API, puerto 6334 para el servicio gRPC).
- [x] Verificar que todo levanta correctamente con `docker compose up --build`.

### 1.3 Esquema de Base de Datos (`postgres/init.sql`)
- [x] **Tablas para Guillermo (RAG):**
  - [x] Tabla `documentos` (id, nombre, ruta_archivo, num_chunks, fecha_procesado).
  - [x] Tabla `consultas_rag` (id, pregunta, respuesta, documentos_usados, timestamp).
- [x] **Tablas para Abdul (Chatbot):**
  - [x] Tabla `historial_chatbot` (id, usuario_mensaje, intencion_detectada, herramienta_usada, bot_respuesta, timestamp).

---

## 🧠 Fase 2: Proyecto A - Sistema RAG Educativo (GUILLERMO BAZÁN)

### 2.1 Workflow 1: Ingesta de Documentos (`n8n/workflows/rag-ingesta.json`)
- [x] Nodo **Webhook** configurado para recibir archivos (PDF/TXT/MD).
- [x] Nodo(s) para **leer/extraer** el texto del documento.
- [x] Nodo para **dividir el texto en chunks** (~500 palabras, overlap de 50).
- [x] Nodo **Ollama** configurado para generar *embeddings* de los chunks devueltos.
- [x] Nodo **Qdrant** para guardar los vectores generados e indexarlos.
- [x] Nodo **PostgreSQL** para insertar los metadatos de la carga en la tabla `documentos`.
- [x] Validaciones básicas y manejo de errores implementados en el flow.

### 2.2 Workflow 2: Consultas RAG (`n8n/workflows/rag-consultas.json`)
- [x] Nodo **Webhook** configurado para recibir la pregunta del usuario.
- [x] Nodo **Ollama** para generar el *embedding* de la pregunta.
- [x] Nodo **Qdrant** para buscar los chunks más similares al vector de la pregunta.
- [x] Nodo **Ollama** parametrizado que recibe los chunks recuperados (como contexto) y la pregunta para generar una respuesta coherente, indicando que responda en base al doc aportado.
- [x] Nodo **PostgreSQL** para guardar la pregunta original y la respuesta obtenida en la tabla `consultas_rag`.
- [x] Al terminar ambos, exportar los JSON de los workflows a `n8n/workflows/`.

---

## 🤖 Fase 3: Chatbot Multiherramienta (ABDUL HAKIM)

### 3.1 Workflow Principal y Análisis de Intención (`n8n/workflows/chatbot-multiherramienta.json`)
- [ ] Nodo **Webhook** configurado para recibir el mensaje en JSON del usuario.
- [ ] Nodo **Ollama** configurado con un *System Prompt* estricto para analizar la intención de la pregunta.
  - [ ] Debe devolver *únicamente* una categoría: `CLIMA`, `PAISES`, `WIKIPEDIA`, `CHISTE`, o `GENERAL`.
- [ ] Nodo **Switch** configurado para redirigir el flujo a 5 salidas distintas en función de la categoría detectada.

### 3.2 Integración de APIs (Nodos HTTP Request)
- [ ] **Rama 1 (Clima):** Configurar HTTP Request a OpenMeteo (usar parámetros dinámicos si se detecta ciudad, o coordenadas base).
- [ ] **Rama 2 (Países):** Configurar HTTP Request a REST Countries.
- [ ] **Rama 3 (Wikipedia):** Configurar HTTP Request a la API de Wikipedia.
- [ ] **Rama 4 (Chistes):** Configurar HTTP Request a JokeAPI (Asegurarse que sea ES ó programación).
- [ ] **Rama 5 (General):** Puente directo al Nodo Ollama Final (Conversación normal).

### 3.3 Consolidación, Respuesta Natural y Persistencia
- [ ] Nodos **Merge** o lógica equivalente para unificar el flujo después de llamar a las APIs.
- [ ] Nodo **Ollama** final: Su labor es tomar los JSON o texto en bruto que devuelvan las APIs (ej: `{ "temp": 15, "city": "Madrid" }`) y transformarlos en texto conversacional de la mano del input original del usuario ("Hace una temperatura ideal de 15 grados en Madrid").
- [ ] Nodo **PostgreSQL** para guardar la interacción en la base de datos (mensaje origen, intención detectada por el primer Ollama, respuesta final).
- [ ] Manejo de Errores Críticos: Añadir ramas de *fallback* para el caso en el que la API devuelva un 404 o timeout.
- [ ] Exportar el JSON del workflow a la carpeta `n8n/workflows/`.

---

## 🧪 Fase 4: Pruebas y Post-Producción (TRABAJO CONJUNTO)

### 4.1 Testing Integrado
- [ ] Crear el archivo `tests/pruebas.http`.
- [ ] Documentar llamadas POST a los 3 Webhooks (Ingesta, Consulta RAG, Mensaje Chatbot) para probar fácilmente.
- [ ] Validar que todas las interacciones persisten correctamente en las tablas de PostgreSQL.

### 4.2 Documentación (`README.md` y `docs/`)
- [ ] Hacer capturas de pantalla de los workflows de n8n, de pruebas lanzadas con éxito, base de datos etc. Guardarlas en `docs/capturas/`.
- [ ] Documentar en `docs/DEMO.md` casos de uso específicos simulando las pruebas.
- [ ] Escribir el `README.md` abordando:
  - [ ] Detalles de instalación y levantado de `docker-compose`.
  - [ ] Explicación de las funcionalidades clave del RAG (Guillermo) y Chatbot (Abdul).
  - [ ] Link visible al vídeo demostrativo.

### 4.3 Git y Flujo de Trabajo
- [ ] Más de 8-10 commits incrementales a lo largo de los días de desarrollo.
- [ ] Commits bien estructurados (`feat: añade rama chistes`, `fix: error timeout olla`, etc.).
- [ ] Usar la etiqueta `Co-authored-by:` en el cuerpo del mensaje del commit cuando el trabajo se comparta.

### 4.4 Grabación del Vídeo Demostración (4-6 minutos)
- [ ] **(30s)** Intro: Presentación de Guillermo y Abdul, y de los proyectos.
- [ ] **(1m)** Arquitectura: Explicación MUY breve de cómo comunican los containers docker.
- [ ] **(1m)** Workflows: Mostrar rápidamente los 3 flujos por pantalla en n8n.
- [ ] **(1m)** Demo RAG (Guillermo): Subir PDF a Postman/VSCode, mostrar vector en Qdrant, hacer pregunta y visualizar DB.
- [ ] **(1.5m)** Demo Chatbot (Abdul): Lanzar 4 peticiones distintas para disparar las 4 APIs y la de conversa, acabar enseñando que todas las peticiones están en PostgreSQL.
- [ ] **(30s)** Conclusión y posibles áreas de mejora en el futuro.
- [ ] Subir video a YouTube (como *No listado*) u otra plataforma e incluir enlace en el README y PR.

### 4.5 Cierre y Entrega Final (Límite: 08/03/2026 23:59)
- [ ] Push final de código a la rama principal.
- [ ] Crear Pull Request (o equivalente) con Título: `Entrega HITO 3 - [Nombre] - [Proyecto A - Proyecto B]`.
- [ ] Marcar en la PR la checklist de requisitos asegurando funcionamiento *end-to-end*.
