# 📺 Guía de Demostración - HITO 3

Este documento detalla los pasos y casos de uso para realizar una demostración completa del sistema, validando tanto el **Proyecto A (RAG)** como el **Proyecto B (Chatbot Multiherramienta)**.

---

## 🛠️ Guía de Pruebas Rápidas

### Proyecto A: Sistema RAG (Guillermo Bazán)
El objetivo es demostrar que el sistema puede leer un documento local y responder preguntas basadas *exclusivamente* en él.

**Caso de Uso 1: Ingesta de PDF**
1. Envía un archivo PDF (ej: `temario.pdf`) al Webhook de Ingesta desde Postman o VSCode (`tests/pruebas.http`).
2. **Resultado esperado:** n8n debe procesar el archivo, dividirlo en chunks, generar vectores y guardarlos en Qdrant. Verás un nuevo registro en la tabla `documentos`.

**Caso de Uso 2: Consulta semántica**
1. Pregunta algo específico que solo esté en ese documento.
2. **Resultado esperado:** El Agente de IA recupera los fragmentos de Qdrant y responde de forma coherente. La interacción se guarda en `consultas_rag`.

---

### Proyecto B: Chatbot Multiherramienta (Abdul Hakim)
El objetivo es demostrar la capacidad del bot para detectar intenciones y usar las APIs correctas.

**Escenarios de Demostración:**

| Intención | Entrada del Usuario (Ejemplo) | Acción del Bot (Interna) | Resultado Esperado |
| :--- | :--- | :--- | :--- |
| **CLIMA** | "¿Qué tiempo hace en Valencia?" | Geocoding API + OpenMeteo | Temperatura actual y respuesta amigable. |
| **PAISES** | "Dime datos sobre Japón" | RESTCountries API | Capital, población y curiosidades. |
| **WIKIPEDIA** | "¿Quién fue Nikola Tesla?" | Wikipedia REST API | Resumen conversacional sobre su vida. |
| **CHISTE** | "Cuéntame un chiste de ordenadores" | JokeAPI (Programming) | Chiste técnico contado con humor. |
| **GENERAL** | "¡Hola! ¿Cómo estás?" | Fallback (Ollama Directo) | Saludo natural y amigable. |

---

## 📊 Validación en Base de Datos

Para demostrar que el sistema es "consciente" de lo que hace, tras cada prueba puedes mostrar que los datos se han guardado en **PostgreSQL**.

### 1. Ver historial del Chatbot (Modo Elegante)
Ejecuta esto para ver las últimas 3 interacciones de forma clara:
```bash
docker exec -it postgres psql -U n8n_user -d automatizacion_db -c "\x" -c "SELECT mensaje_usuario, intencion_detectada, respuesta_bot FROM historial_chatbot ORDER BY timestamp DESC LIMIT 3;"
```

### 2. Verificar documentos en el RAG
```bash
docker exec -it postgres psql -U n8n_user -d automatizacion_db -c "SELECT nombre, num_chunks FROM documentos;"
```

---

## 💡 Áreas de Mejora para el Futuro
* Implementar memoria a largo plazo (Postgres Chat Message History).
* Añadir soporte para archivos de imagen (Multimodal) en el chatbot.
* Interfaz web para el sistema RAG (actualmente por Telegram/Webhook).
