# BigQuery Model with Looker 🛒📊

Este repositorio muestra cómo trabajar con los datos públicos de **Google Analytics** (Google Store) para crear un modelo de predicción de compra y visualizar los resultados en **Looker**. El proyecto se divide en varias etapas, desde el preprocesamiento de los datos hasta la creación de un modelo predictivo y su visualización en un dashboard interactivo.

---

## 🚀 Estructura del Proyecto

El proyecto se divide en las siguientes secciones:

### 1. **Preprocesamiento de Datos** 🛠️
En esta etapa, se realizan consultas a los datos de Google Analytics para explorar y preparar los datos antes de su análisis. Se incluyen consultas para:
- Conocer los datos de una partición específica.
- Consultar datos de múltiples particiones.
- Convertir diccionarios a columnas para facilitar el análisis.

### 2. **Análisis de Datos** 📈
Se realizan varias consultas para analizar los datos, incluyendo:
- Número total de transacciones por navegador y tipo de dispositivo.
- Porcentaje de rechazo (**bounce rate**) por origen de tráfico.
- Porcentaje de conversión por sistema operativo, categoría de dispositivo y navegador.
- Porcentaje de visitantes que realizaron una compra en el sitio web.

### 3. **Creación del Modelo Predictivo** 🤖
Se crean dos modelos de regresión logística utilizando **BigQuery ML**:
- **Primer Modelo**: Un modelo básico que predice la probabilidad de que un usuario realice una transacción.
- **Segundo Modelo (Mejorado)**: Un modelo más avanzado que incluye más características y ajustes para mejorar la precisión.

Se evalúan ambos modelos utilizando métricas como la **matriz de confusión** y otras métricas de evaluación proporcionadas por BigQuery ML.

### 4. **Tabla de Dashboard en Looker** 📊
Se crea una tabla en BigQuery para almacenar las predicciones diarias del modelo. Esta tabla se utiliza para alimentar un **dashboard en Looker**, donde se visualizan métricas clave como:
- Tasa de rebote (**bounce rate**).
- Tasa de conversión.
- Frecuencia de visitas.
- Valor total de las transacciones.
- Probabilidad de predicción de compra.
- Accede al Dahboard aquí: https://lookerstudio.google.com/reporting/84e7eb54-8baa-4003-99dd-9715ce279c9f

---

## 🛠️ Cómo Usar Este Repositorio

1. **Clona el repositorio**:
   ```bash
   git clone https://github.com/BootcampXperience/DS_BigQuery_Looker.git
