-- ==============================================================
-- PROYECTO A: SISTEMA RAG EDUCATIVO (Guillermo Bazán)
-- ==============================================================

-- Tabla 1: Documentos procesados


CREATE TABLE IF NOT EXISTS documentos ( 
    id SERIAL PRIMARY KEY, 
    nombre VARCHAR(255) NOT NULL, 
    ruta_archivo TEXT, 
    num_chunks INTEGER, 
    fecha_procesado TIMESTAMP DEFAULT NOW() 
); 
-- Índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_documentos_nombre ON documentos(nombre);

-- Tabla 2: Historial de consultas RAG

CREATE TABLE IF NOT EXISTS consultas_rag ( 
    id SERIAL PRIMARY KEY, 
    pregunta TEXT NOT NULL, 
    respuesta TEXT NOT NULL, 
    documentos_usados TEXT[], -- Array de nombres de docs 
    timestamp TIMESTAMP DEFAULT NOW() 
); 
-- Índice para consultas recientes
CREATE INDEX IF NOT EXISTS idx_consultas_timestamp ON consultas_rag(timestamp DESC);

-- ==============================================================
-- PROYECTO B: CHATBOT MULTIHERRAMIENTA (Abdul Hakim)
-- ==============================================================

-- Tabla 3: Historial conversacional del Chatbot
CREATE TABLE IF NOT EXISTS historial_chatbot (
    id SERIAL PRIMARY KEY,
    mensaje_usuario TEXT NOT NULL,
    intencion_detectada VARCHAR(50),     -- Ej: CLIMA, PAÍSES, WIKIPEDIA, CHISTE, GENERAL
    respuesta_bot TEXT NOT NULL,
    herramienta_usada VARCHAR(100),      -- Ej: OpenMeteo, RESTCountries, JokeAPI, Wikipedia
    timestamp TIMESTAMP DEFAULT NOW()
);
-- Índice para consultas recientes del chatbot
CREATE INDEX IF NOT EXISTS idx_historial_chatbot_timestamp ON historial_chatbot(timestamp DESC);
