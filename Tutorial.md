# Tutorial: Desarrollo del Proyecto BigQuery Model with Looker 🛒📊

Este tutorial te guiará paso a paso para desarrollar el proyecto de **BigQuery Model with Looker**, donde trabajaremos con datos públicos de Google Analytics para crear un modelo predictivo de compras y visualizar los resultados en Looker.

---

## 🛠️ Requisitos Previos

Antes de comenzar, asegúrate de tener lo siguiente:

1. **Cuenta en Google Cloud Platform (GCP)**: Necesitarás acceso a BigQuery y permisos para crear modelos y tablas.
2. **Looker**: Configura Looker para conectarse a tu instancia de BigQuery.
3. **Conocimientos básicos de SQL**: Para ejecutar las consultas en BigQuery.
4. **Datos públicos de Google Analytics**: Utilizaremos el conjunto de datos `bigquery-public-data.google_analytics_sample`.

---

## 🚀 Paso a Paso del Proyecto

### 1. **Preprocesamiento de Datos** 🛠️

#### Paso 1.1: Explorar los datos de una partición
Comenzamos explorando los datos de un día específico para familiarizarnos con la estructura de los datos.

```sql
SELECT *
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
LIMIT 100;
```

#### Paso 1.2: Consultar datos de múltiples particiones
Ahora, consultamos datos de un rango de fechas para tener una visión más amplia.

```sql
SELECT *
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
AND visitorId IS NOT NULL;
```

#### Paso 1.3: Convertir diccionarios a columnas
Para facilitar el análisis, convertimos los datos anidados en columnas.

```sql
SELECT fullVisitorId,
        visitId,
        hit.hitNumber,
        hit.page.pagePath
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
      UNNEST(hits) AS hit
WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170131';
```

---

### 2. **Análisis de Datos** 📈

#### Paso 2.1: Número total de transacciones por navegador y tipo de dispositivo
Analizamos las transacciones generadas por tipo de dispositivo y navegador.

```sql
SELECT device.deviceCategory,
       device.browser,
       SUM(totals.transactions) AS total_transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20161101' AND '20161130'
GROUP BY 1,2
HAVING SUM(totals.transactions) IS NOT NULL
ORDER BY 1, 3 DESC;
```

#### Paso 2.2: Porcentaje de rechazo por origen de tráfico
Calculamos el porcentaje de rechazo (bounce rate) por origen de tráfico.

```sql
SELECT source,
        total_visits,
        total_bounces,
        ((total_bounces / total_visits ) * 100 ) AS bounce_rate
FROM (SELECT trafficSource.source AS source,
             COUNT ( trafficSource.source ) AS total_visits,
             SUM ( totals.bounces ) AS total_bounces
      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
      WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
      GROUP BY 1
      )
ORDER BY 1 DESC;
```

---

### 3. **Creación del Modelo Predictivo** 🤖

#### Paso 3.1: Crear el primer modelo
Creamos un modelo básico de regresión logística para predecir transacciones.

```sql
CREATE MODEL `bqml_gaSessions.primer_model`
OPTIONS(
  model_type='logistic_reg',
  data_split_method='RANDOM',
  data_split_eval_fraction=0.2
) AS
SELECT
  IF(totals.transactions IS NULL, 0, 1) AS label,
  IFNULL(device.operatingSystem, "") AS os,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.country, "") AS country,
  IFNULL(totals.pageviews, 0) AS pageviews,
  IFNULL(totals.timeOnSite, 0) AS time_on_site,
  IFNULL(trafficSource.medium, "") AS traffic_medium
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170531';
```

#### Paso 3.2: Evaluar el modelo
Evaluamos el modelo utilizando una matriz de confusión y métricas de evaluación.

```sql
WITH TEST_DATA AS (
  SELECT
    IF(totals.transactions IS NULL, 0, 1) AS label,
    IFNULL(device.operatingSystem, "") AS os,
    device.isMobile AS is_mobile,
    IFNULL(geoNetwork.country, "") AS country,
    IFNULL(totals.pageviews, 0) AS pageviews,
    IFNULL(totals.timeOnSite, 0) AS time_on_site,
    IFNULL(trafficSource.medium, "") AS traffic_medium
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'
)
SELECT *
FROM ML.CONFUSION_MATRIX(MODEL `bqml_gaSessions.primer_model`, (SELECT * FROM TEST_DATA));
```

---

### 4. **Visualización en Looker** 📊

#### Paso 4.1: Crear una tabla para las predicciones
Creamos una tabla en BigQuery para almacenar las predicciones diarias del modelo.

```sql
CREATE OR REPLACE TABLE `bootcampxperience.bqml_gaSessions.daily_predictions` (
  unique_session_id STRING,
  label INT64,
  operatingSystem STRING,
  isMobile BOOLEAN,
  country STRING,
  region STRING,
  deviceCategory STRING,
  browser STRING,
  pageViews INT64,
  hits INT64,
  timeOnSite INT64,
  trafficMedium STRING,
  trafficSource STRING,
  campaign STRING,
  visitHour INT64,
  isOrganic INT64,
  eveningVisit INT64,
  avgTimePerPageView FLOAT64,
  bounceRate FLOAT64,
  conversionRate FLOAT64,
  visitFrequency INT64,
  totalTransactionValue FLOAT64,
  predictedLabel INT64,
  predictedProbability FLOAT64,
  predictionDate DATE
)
PARTITION BY predictionDate;
```

#### Paso 4.2: Conectar Looker a BigQuery
Conecta Looker a la tabla de predicciones y crea un dashboard para visualizar las métricas clave, como:
- Tasa de rebote (bounce rate).
- Tasa de conversión.
- Frecuencia de visitas.
- Probabilidad de predicción de compra.

---

## 🎉 ¡Felicidades!

Has completado el proyecto **BigQuery Model with Looker**. Ahora tienes un modelo predictivo de compras y un dashboard en Looker para visualizar los resultados. ¡Sigue explorando y mejorando el modelo! 🚀
