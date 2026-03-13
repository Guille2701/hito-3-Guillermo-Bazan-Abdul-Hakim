# 🤖 Proyecto A: Arquitectura RAG Profesional con n8n, Telegram y Ollama

Este repositorio contiene la implementación completa del **Proyecto A**, un sistema avanzado de **Generación Aumentada por Recuperación (RAG)** diseñado para operar de forma 100% local. El sistema permite a los usuarios interactuar con documentación técnica (PDF/TXT) a través de un bot de Telegram, garantizando la privacidad de los datos y respuestas precisas mediante IA.

## 📋 Índice
1. [Arquitectura del Sistema](#-arquitectura-del-sistema)
2. [Flujos de Trabajo (Workflows)](#-flujos-de-trabajo)
3. [Configuración de IA y Modelos](#-configuración-de-ia-y-modelos)
4. [Base de Datos y Persistencia](#-base-de-datos-y-persistencia)
5. [Instalación y Despliegue](#-instalación-y-despliegue)
6. [Pruebas y Validación](#-pruebas-y-validación)

---

## 🏗️ Arquitectura del Sistema

El sistema utiliza una arquitectura de microservicios orquestada por Docker:
- **n8n:** Motor de automatización y orquestación de los flujos RAG.
- **Qdrant:** Base de datos vectorial para almacenamiento y búsqueda semántica de documentos.
- **PostgreSQL:** Almacenamiento relacional para auditoría de consultas y metadatos.
- **Ollama:** Servidor local de inferencia para el LLM y generación de embeddings.

---

## 🔄 Flujos de Trabajo (Workflows)

### 1. Ingesta de Documentos (Multiformato)
El flujo de ingesta ha sido diseñado para ser flexible y resiliente:
- **Entrada:** Un Webhook recibe archivos mediante peticiones `POST` (multipart/form-data).
- **Lógica de Ramificación:** Un nodo `Switch` detecta la extensión del archivo (`.pdf` vs `.txt`).
- **Procesamiento:** - Los **PDF** se procesan con el nodo *Extract from File* (PDF).
    - Los **TXT** se convierten de binario a texto plano garantizando la integridad de caracteres.
- **Fragmentación:** Uso de `Recursive Character Text Splitter` para dividir el texto en chunks óptimos.
- **Vectorización:** Los fragmentos se convierten a vectores usando el modelo `nomic-embed-text` y se indexan en Qdrant.

### 2. Consulta y Chatbot de Telegram
El flujo de usuario final optimizado para producción:
- **Telegram Trigger:** Utiliza *Long Polling* para eliminar la necesidad de túneles SSL/HTTPS (como Ngrok).
- **AI Agent (ReAct):** Un agente con razonamiento lógico que utiliza la herramienta de búsqueda en Qdrant.
- **Memoria de Sesión:** Implementación de `Window Buffer Memory` vinculada al `Chat ID` de Telegram, permitiendo conversaciones fluidas y aisladas por usuario.

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

**Tabla: `consultas_rag`**
| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | Serial | Clave primaria única |
| `pregunta` | Text | Texto enviado por el usuario desde Telegram |
| `respuesta` | Text | Respuesta final generada por la IA (limpia) |
| `documentos_usados` | Array/JSON | Referencia a la fuente de información en Qdrant |
| `fecha` | Timestamp | Momento exacto de la consulta |

---

