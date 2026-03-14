# 🚀 HITO 3: Automatización Inteligente con n8n, Ollama, Qdrant y PostgreSQL

Este repositorio contiene la implementación conjunta de dos proyectos complementarios:
- **Proyecto A (Guillermo Bazán):** Sistema avanzado de **Generación Aumentada por Recuperación (RAG)** que opera 100% en local.
- **Proyecto B (Abdul Hakim):** **Chatbot Multiherramienta** diseñado para detectar intenciones y usar APIs dinámicas basándose en el análisis de Ollama.

Ambos sistemas convergen para brindar soluciones potentes, operando con una arquitectura backend local que garantiza la privacidad de los datos.

## 📋 Índice
1. [Arquitectura del Sistema](#-arquitectura-del-sistema)
2. [Proyecto A: Flujos RAG (Guillermo)](#-proyecto-a-flujos-rag-guillermo)
3. [Proyecto B: Chatbot Multiherramienta (Abdul)](#-proyecto-b-chatbot-multiherramienta-abdul)
4. [Configuración de IA y Modelos](#-configuración-de-ia-y-modelos)
5. [Base de Datos y Persistencia](#-base-de-datos-y-persistencia)
6. [Instalación y Despliegue](#-instalación-y-despliegue)
7. [Pruebas y Validación](#-pruebas-y-validación)

---

## 🏗️ Arquitectura del Sistema

El sistema utiliza una arquitectura de microservicios orquestada por Docker:
- **n8n:** Motor de automatización y orquestación de los flujos RAG.
- **Qdrant:** Base de datos vectorial para almacenamiento y búsqueda semántica de documentos.
- **PostgreSQL:** Almacenamiento relacional para auditoría de consultas y metadatos.
- **Ollama:** Servidor local de inferencia para el LLM y generación de embeddings.

---

## 🔄 Proyecto A: Flujos RAG (Guillermo)

### 1. Ingesta de Documentos (Multiformato)
El flujo de ingesta ha sido diseñado para ser flexible y resiliente:
- **Entrada:** Un Webhook recibe archivos mediante peticiones `POST` (multipart/form-data).
- **Lógica de Ramificación:** Un nodo `Switch` detecta la extensión del archivo (`.pdf` vs `.txt`).
- **Procesamiento:** - Los **PDF** se procesan con el nodo *Extract from File* (PDF).
    - Los **TXT** se convierten de binario a texto plano garantizando la integridad de caracteres.
- **Fragmentación:** Uso de `Recursive Character Text Splitter` para dividir el texto en chunks óptimos.
- **Vectorización:** Los fragmentos se convierten a vectores usando el modelo `nomic-embed-text` y se indexan en Qdrant.

![Workflow ingesta](/docs/capturas/workflow_ingesta.jpg)

### 2. Consulta y Chatbot de Telegram
El flujo de usuario final optimizado para producción:
- **Telegram Trigger:** Utiliza *Long Polling* para eliminar la necesidad de túneles SSL/HTTPS (como Ngrok).
- **AI Agent (ReAct):** Un agente con razonamiento lógico que utiliza la herramienta de búsqueda en Qdrant.
- **Memoria de Sesión:** Implementación de `Window Buffer Memory` vinculada al `Chat ID` de Telegram, permitiendo conversaciones fluidas y aisladas por usuario.

![Workflow consulta](/docs/capturas/workflow_consultas.jpg)


---

## 🛠️ Proyecto B: Chatbot Multiherramienta (Abdul)

El **Chatbot Multiherramienta** permite procesar las intenciones de un usuario en lenguaje natural e invocar fuentes externas de datos o APIs para proveer respuestas completas.

### 1. Enrutamiento e Intención 
El núcleo del flujo depende de un clasificador **Ollama** con prompt estricto que evalúa el texto del usuario y encauza la solicitud hacia una de estas cinco ramas (Switch Node):
- **🌤️ Clima**: Usa un nodo intermedio de IA para extraer la ciudad del mensaje y luego pregunta a la API **OpenMeteo**.
- **🌍 Países**: Consulta la información demográfica o banderas desde **REST Countries**.
- **📚 Wikipedia**: Recupera de la **API de Wikipedia** extractos textuales que explican un concepto.
- **😂 Chiste**: Consume la **JokeAPI** para buscar un chiste (ej. de programación).
- **💬 General**: Responde directamente (Saludos, despedidas, charlas no técnicas) sin APIs externas.

### 2. Consolidación y Conversación Natural
Para evitar que el usuario reciba un JSON ilegible, todas las ramas poseen nodos **Ollama** finales que toman la información recuperada de las APIs (por ejemplo `{"temp":12, "weather":"cloudy"}`) y redactan una respuesta natural, en español y adecuada a la intención detectada, para finalmente guardarse como historial.

---

## 🧠 Configuración de IA y Modelos

### Modelo de Lenguaje (LLM)
Se ha seleccionado **Qwen 3 (14B)** ejecutado en Ollama. Este modelo ofrece un equilibrio superior entre velocidad y precisión técnica.

### Optimización de Respuestas
Para garantizar una experiencia de usuario limpia, se implementó:
- **Eliminación de razonamiento:** Un nodo de código JavaScript limpia las etiquetas `<think>` generadas por el modelo, entregando solo la respuesta final.
- **System Prompt Estricto:** Instrucciones para forzar el idioma español y evitar alucinaciones ("Si no está en el documento, di que no lo sabes").
- **Temperatura 0.1:** Ajuste para maximizar la consistencia y reducir la creatividad innecesaria en consultas técnicas.

---

## 🗄️ Base de Datos y Persistencia

El sistema cumple con el requisito de trazabilidad guardando cada interacción en **PostgreSQL**.

### Proyecto A (RAG)
**Tabla: `consultas_rag`**
| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | Serial | Clave primaria única |
| `pregunta` | Text | Texto enviado por el usuario desde Telegram |
| `respuesta` | Text | Respuesta final generada |
| `documentos_usados` | Array/JSON | Referencia en Qdrant |
| `fecha` | Timestamp | Momento de la consulta |

### Proyecto B (Chatbot Multiherramienta)
**Tabla: `historial_chatbot`**
| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | Serial | Clave primaria única |
| `mensaje_usuario` | Text | Texto que el usuario envió al bot vía Webhook |
| `intencion_detectada`| String | Intención clasificada (CLIMA, WIKI, PAISES...) |
| `respuesta_bot` | Text | Texto final y natural formulado por la IA tras usar la API |
| `herramienta_usada` | String | Intermediario usado (OpenMeteo, Wikipedia, etc.) |
| `timestamp` | Timestamp| Fecha y hora de la interacción |

---
