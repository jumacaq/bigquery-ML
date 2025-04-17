--New model using random forest
CREATE MODEL `bqml_ga_sessions1.random_forest`
  OPTIONS(
  model_type='random_forest_classifier',
  data_split_method='RANDOM',
  data_split_eval_fraction=0.2,
  l2_reg=0.1,
  l1_reg=0.05,
  NUM_PARALLEL_TREE=50,
  MAX_TREE_DEPTH=10
) AS

WITH traffic_metrics AS (
  SELECT
    trafficSource.source AS source,
    ROUND(SUM(totals.bounces) / COUNT(trafficSource.source) * 100, 2) AS bounce_rate
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170531'
  GROUP BY 1
),
conversion_metrics AS (
  SELECT
    device.operatingSystem AS operating_system,
    device.deviceCategory AS device_category,
    device.browser AS browser,
    ROUND(SUM(IF(totals.transactions IS NULL, 0, 1)) / COUNT(*) * 100, 2) AS conversion_rate
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170531'
  GROUP BY 1, 2, 3
)
SELECT
  IF(sessions.totals.transactions IS NULL, 0, 1) AS label,
  IFNULL(sessions.device.operatingSystem, "") AS op_syst,
  sessions.device.isMobile AS is_mobile,
  IFNULL(sessions.geoNetwork.country, "") AS country,
  IFNULL(sessions.geoNetwork.region, "") AS region,
  IFNULL(sessions.device.deviceCategory, "") AS dev_category,
  IFNULL(sessions.device.browser, "") AS browser,
  IFNULL(sessions.totals.pageviews, 0) AS pageviews,
  IFNULL(sessions.totals.hits, 0) AS hits,
  IFNULL(sessions.totals.timeOnSite, 0) AS time_on_site,
  IFNULL(sessions.trafficSource.medium, "") AS traffic_medium,
  IFNULL(sessions.trafficSource.source, "") AS traffic_source,
  IFNULL(sessions.trafficSource.campaign, "") AS campaign,
  EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) AS visit_hour,
  traffic_metrics.bounce_rate,
  conversion_metrics.conversion_rate,
  IF(sessions.trafficSource.medium = 'organic', 1, 0) AS is_organic,
  IF(EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) >= 18 AND EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) <= 23, 1, 0) AS evening_visit,
  ROUND(IFNULL(totals.timeOnSite, 0) / GREATEST(IFNULL(totals.pageviews, 0), 1), 2) AS avg_time_pageview,
  (
    SELECT
      COUNT(*)
    FROM
      `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS inner_sessions
    WHERE
      inner_sessions.fullVisitorId = sessions.fullVisitorId
      AND PARSE_DATE('%Y%m%d', inner_sessions.date) < PARSE_DATE('%Y%m%d', sessions.date)
  ) AS visit_frequency,
  (
    SELECT
      SUM(totals.transactionRevenue)
    FROM
      `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS inner_sessions
    WHERE
      inner_sessions.fullVisitorId = sessions.fullVisitorId
      AND PARSE_DATE('%Y%m%d', inner_sessions.date) < PARSE_DATE('%Y%m%d', sessions.date)
  ) AS total_transaction_value,
  PARSE_DATE('%Y%m%d', sessions.date) AS visit_date
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS sessions
LEFT JOIN traffic_metrics ON sessions.trafficSource.source = traffic_metrics.source
LEFT JOIN conversion_metrics ON sessions.device.operatingSystem = conversion_metrics.operating_system
AND sessions.device.deviceCategory = conversion_metrics.device_category
AND sessions.device.browser = conversion_metrics.browser
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170531'
AND(sessions.totals.transactions IS NOT NULL OR RAND() <0.05);




--Metrics and assessment with test data

(WITH traffic_metrics AS

  (SELECT

  trafficSource.source AS source,

  COUNT(trafficSource.source) AS total_visits,

  SUM(totals.bounces) AS total_no_of_bounces,

  ROUND(SUM(totals.bounces)/COUNT(trafficSource.source)*100,2) AS bounce_rate

  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`

  WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'

  GROUP BY 1),

  conversion_metrics AS

  (SELECT

  device.operatingSystem  AS operating_system,

  device.deviceCategory AS device_category,

  device.browser AS browser,

  COUNT(*) AS total_sessions,

  SUM(IF(totals.transactions IS NULL,0,1)) AS total_transactions,

  ROUND(SUM(IF(totals.transactions IS NULL,0,1))/COUNT(*)*100,2)AS conversion_rate

  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`

  WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'

  GROUP BY 1,2,3)

  

  SELECT

  IF(sessions.totals.transactions IS NULL, 0, 1) AS label,

  IFNULL(sessions.device.operatingSystem, "") AS op_syst,

  sessions.device.isMobile AS is_mobile,

  IFNULL(sessions.geoNetwork.country, "") AS country,

  IFNULL(sessions.geoNetwork.region, "") AS region,

  IFNULL(sessions.device.deviceCategory, "") AS dev_category,

  IFNULL(sessions.device.browser, "") AS browser,

  IFNULL(sessions.totals.pageviews, 0) AS pageviews,

  IFNULL(sessions.totals.hits, 0) AS hits,

  IFNULL(sessions.totals.timeOnSite, 0) AS time_on_site,

  IFNULL(sessions.trafficSource.medium, "") AS traffic_medium,

  IFNULL(sessions.trafficSource.source, "") AS traffic_source,

  IFNULL(sessions.trafficSource.campaign, "") AS campaign,

  EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) AS visit_hour,

  traffic_metrics.bounce_rate,

  conversion_metrics.conversion_rate,

  IF(sessions.trafficSource.medium='organic',1,0) AS is_organic,

  IF(EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime))>=18 AND EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) <= 23,1,0 ) AS evening_visit,

  ROUND(IFNULL(totals.timeOnSite,0)/ GREATEST(IFNULL(totals.pageviews,0),1),2) AS avg_time_pageview,

  (SELECT COUNT(*)FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`AS inner_sessions

  WHERE inner_sessions.fullVisitorId = sessions.fullVisitorId

  AND PARSE_DATE('%Y%m%d',inner_sessions.date)<PARSE_DATE('%Y%m%d',sessions.date)) AS visit_frequency,

  (SELECT SUM(totals.transactionRevenue) FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`AS inner_sessions

  WHERE inner_sessions.fullVisitorId = sessions.fullVisitorId

  AND PARSE_DATE('%Y%m%d',inner_sessions.date)<PARSE_DATE('%Y%m%d',sessions.date)) AS total_transaction_value,

  PARSE_DATE('%Y%m%d',sessions.date) as visit_date,

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`AS sessions

LEFT JOIN traffic_metrics

ON sessions.trafficSource.source = traffic_metrics.source

LEFT JOIN conversion_metrics

ON sessions.device.operatingSystem = conversion_metrics.operating_system

AND sessions.device.deviceCategory = conversion_metrics.device_category
AND sessions.device.browser = conversion_metrics.browser
WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'
AND(sessions.totals.transactions IS NOT NULL OR RAND() <0.05));




--Confusion matrix
SELECT * --seleccionar todas las columnas del resultado de la función ML.CONFUSION_MATRIX.
FROM ML.CONFUSION_MATRIX(MODEL `bqml_ga_sessions1.random_forest`, --Llama a la función ML.CONFUSION_MATRIX` de BigQuery ML.Dentro de la función, se especifica el modelo Random Forest ya entrenado del cual quieres obtener la matriz de confusión. Este nombre (bqml_ga_sessions1.random_forest`) debe coincidir con el nombre de tu modelo.,La coma separa el modelo de los datos de evaluación que se utilizarán para generar la matriz.
 (WITH traffic_metrics AS --introduce una expresión de tabla común (CTE) llamada traffic_metrics. Las CTEs son como subconsultas temporales con nombre que puedes referenciar dentro de tu query principal. La CTE traffic_metrics calcula métricas relacionadas con la fuente de tráfico:
  (SELECT 
  trafficSource.source AS source, --Selecciona la fuente de tráfico y la renombra como source
  COUNT(trafficSource.source) AS total_visits, -- Cuenta el número total de visitas para cada fuente de tráfico y lo renombra como total_visits
  SUM(totals.bounces) AS total_no_of_bounces, --Suma el número total de rebotes(totals.bounces) para cada fuente de tráfico y lo renombra como total_no_of_bounces
  ROUND(SUM(totals.bounces)/COUNT(trafficSource.source)*100,2) AS bounce_rate -- Calcula la tasa de rebote para cada fuente de tráfico dividiendo el número total de rebotes por el número total de visitas, multiplicándolo por 100 y redondeando a dos decimales.
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` --Especifica la tabla de datos de Google Analytics.
  WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801' --incluye solo las sesiones entre el 1 de junio de 2017 y el 1 de agosto de 2017.
  GROUP BY 1),--Agrupa los resultados por la primera columna seleccionada, que es trafficSource.source
  conversion_metrics AS --define otra CTE llamada conversion_metrics que calcula métricas de conversión por sistema operativo, categoría de dispositivo y navegador:
  (SELECT 
  device.operatingSystem  AS operating_system, --Selecciona el sistema operativo del dispositivo y lo renombra como operating_system
  device.deviceCategory AS device_category,--Selecciona la categoría del dispositivo y la renombra como device_category
  device.browser AS browser,--Selecciona el navegador y lo renombra como browser
  COUNT(*) AS total_sessions,--Cuenta el número total de sesiones para cada combinación de sistema operativo, categoría de dispositivo y navegador y lo renombra como total_sessions.
  SUM(IF(totals.transactions IS NULL,0,1)) AS total_transactions, --Cuenta el número de sesiones con al menos una transacción para cada combinación. Si totals.transactions es NULL (no hubo transacción), suma 0, de lo contrario suma 1, y lo renombra como total_transactions
  ROUND(SUM(IF(totals.transactions IS NULL,0,1))/COUNT(*)*100,2)AS conversion_rate --Calcula la tasa de conversión dividiendo el número total de transacciones por el número total de sesiones, multiplicándolo por 100 y redondeando a dos decimales
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'
  GROUP BY 1,2,3)--Agrupa los resultados por sistema operativo, categoría de dispositivo y navegador.
  --Cierra la definición de las CTEs dentro del paréntesis que sigue a la función ML.CONFUSION_MATRIX
  SELECT --Inicia la subconsulta que proporciona los datos de evaluación al ML.CONFUSION_MATRIX. Selecciona varias características de la tabla ga_sessions_* y las une con las CTEs traffic_metrics y conversion_metrics
  IF(sessions.totals.transactions IS NULL, 0, 1) AS label,--Define la etiqueta para la clasificación. Si sessions.totals.transactions es NULL (no hubo transacción), la etiqueta es 0; de lo contrario, es 1. Esta es la columna que el modelo predijo y contra la cual se compara para la matriz de confusión
  IFNULL(sessions.device.operatingSystem, "") AS op_syst, --Selecciona el sistema operativo del dispositivo y reemplaza los valores NULL con una cadena vacía
  sessions.device.isMobile AS is_mobile, --Selecciona si el dispositivo es móvil
  IFNULL(sessions.geoNetwork.country, "") AS country,-- Selecciona el país y reemplaza los valores NULL con una cadena vacía.
  IFNULL(sessions.geoNetwork.region, "") AS region, -- Selecciona la región y reemplaza los valores NULL con una cadena vacía.
  IFNULL(sessions.device.deviceCategory, "") AS dev_category,--Selecciona la categoría del dispositivo y reemplaza los valores NULL con una cadena vacía
  IFNULL(sessions.device.browser, "") AS browser,--Selecciona el navegador y reemplaza los valores NULL con una cadena vacía
  IFNULL(sessions.totals.pageviews, 0) AS pageviews, -- Selecciona el número de páginas vistas y reemplaza los valores NULL con 0.
  IFNULL(sessions.totals.hits, 0) AS hits,--Selecciona el número de hits y reemplaza los valores NULL con 0.
  IFNULL(sessions.totals.timeOnSite, 0) AS time_on_site,-- Selecciona el tiempo en el sitio y reemplaza los valores NULL con 0.
  IFNULL(sessions.trafficSource.medium, "") AS traffic_medium,--Selecciona el medio de tráfico y reemplaza los valores NULL con una cadena vacía
  IFNULL(sessions.trafficSource.source, "") AS traffic_source,--Selecciona la fuente de tráfico y reemplaza los valores NULL con una cadena vacía
  IFNULL(sessions.trafficSource.campaign, "") AS campaign,--Selecciona la campaña y reemplaza los valores NULL con una cadena vacía
  EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) AS visit_hour,--Extrae la hora de la visita
  traffic_metrics.bounce_rate,--Incluye la tasa de rebote calculada en la CTE traffic_metrics basada en la fuente de tráfico
  conversion_metrics.conversion_rate,--tasa de conversión calculada en la CTE conversion_metrics basada en el sistema operativo, categoría del dispositivo y navegador
  IF(sessions.trafficSource.medium='organic',1,0) AS is_organic,--Crea una variable binaria que indica si el medio de tráfico es 'organic'.
  IF(EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime))>=18 AND EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) <= 23,1,0 ) AS evening_visit,--Crea una variable binaria que indica si la visita fue entre las 6 PM y las 11 PM.
  ROUND(IFNULL(totals.timeOnSite,0)/ GREATEST(IFNULL(totals.pageviews,0),1),2) AS avg_time_pageview,-- Calcula el tiempo promedio por página vista
  (SELECT COUNT(*)FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`AS inner_sessions
  WHERE inner_sessions.fullVisitorId = sessions.fullVisitorId
  AND PARSE_DATE('%Y%m%d',inner_sessions.date)<PARSE_DATE('%Y%m%d',sessions.date)) AS visit_frequency,--Subconsulta para calcular la frecuencia de visita del usuario contando las visitas anteriores a la fecha actual
  (SELECT SUM(totals.transactionRevenue) FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`AS inner_sessions
  WHERE inner_sessions.fullVisitorId = sessions.fullVisitorId
  AND PARSE_DATE('%Y%m%d',inner_sessions.date)<PARSE_DATE('%Y%m%d',sessions.date)) AS total_transaction_value,--Subconsulta para calcular el valor total de las transacciones anteriores del usuario
  PARSE_DATE('%Y%m%d',sessions.date) as visit_date,-- Convierte la columna de fecha a un tipo DATE.
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`AS sessions --Especifica la tabla principal de sesiones y le asigna el alias 'sessions`.
LEFT JOIN traffic_metrics
ON sessions.trafficSource.source = traffic_metrics.source --Realiza una unión izquierda con la CTE traffic_metrics basándose en la coincidencia de la fuente de tráfico.
LEFT JOIN conversion_metrics
ON sessions.device.operatingSystem = conversion_metrics.operating_system --Realiza una unión izquierda con la CTE conversion_metrics basándose en la coincidencia del sistema operativo, categoría del dispositivo y navegador
AND sessions.device.deviceCategory = conversion_metrics.device_category --Esta condición asegura que una fila de la tabla sessions (que contiene información sobre una sesión específica) se una con una fila de la CTE conversion_metrics solo si la categoría del dispositivo de la sesión coincide con la categoría del dispositivo para la cual se calculó la tasa de conversión en conversion_metrics. Por ejemplo, una sesión que ocurrió en un desktop se unirá con la tasa de conversión calculada específicamente para desktop en la CTE
AND sessions.device.browser = conversion_metrics.browser --De manera similar, esta condición exige que la unión ocurra solo si el navegador utilizado en la sesión coincide con el navegador para el cual se calculó la tasa de conversión en conversion_metrics. Así, una sesión en Chrome se unirá con la tasa de conversión calculada para Chrome
WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'
AND (sessions.totals.transactions IS NOT NULL OR RAND() < 0.05)--Esto es un filtro importante para seleccionar los datos de evaluación. Incluye todas las sesiones que tuvieron una transacción (sessions.totals.transaction IS NOT NULL) y una muestra aleatoria del 5% de las sesiones que no tuvieron transacción (RAND() < 0.05). Esto se hace para equilibrar las clases y hacer que la evaluación sea más eficiente
));--Cierra el paréntesis de la subconsulta que proporciona los datos de evaluación y el paréntesis de la función ML.CONFUSION_MATRIX





--Model evaluation 
SELECT
  *
FROM
  ML.EVALUATE(MODEL `bqml_ga_sessions1.random_forest`,
    (WITH traffic_metrics AS (
      SELECT
        trafficSource.source AS source,
        ROUND(SUM(totals.bounces) / COUNT(trafficSource.source) * 100, 2) AS bounce_rate
      FROM
        `bigquery-public-data.google_analytics_sample.ga_sessions_*`
      WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'
      GROUP BY 1
    ),
    conversion_metrics AS (
      SELECT
        device.operatingSystem AS operating_system,
        device.deviceCategory AS device_category,
        device.browser AS browser,
        ROUND(SUM(IF(totals.transactions IS NULL, 0, 1)) / COUNT(*) * 100, 2) AS conversion_rate
      FROM
        `bigquery-public-data.google_analytics_sample.ga_sessions_*`
      WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'
      GROUP BY 1, 2, 3
    )
    SELECT
      IF(sessions.totals.transactions IS NULL, 0, 1) AS label,
      IFNULL(sessions.device.operatingSystem, "") AS op_syst,
      sessions.device.isMobile AS is_mobile,
      IFNULL(sessions.geoNetwork.country, "") AS country,
      IFNULL(sessions.geoNetwork.region, "") AS region,
      IFNULL(sessions.device.deviceCategory, "") AS dev_category,
      IFNULL(sessions.device.browser, "") AS browser,
      IFNULL(sessions.totals.pageviews, 0) AS pageviews,
      IFNULL(sessions.totals.hits, 0) AS hits,
      IFNULL(sessions.totals.timeOnSite, 0) AS time_on_site,
      IFNULL(sessions.trafficSource.medium, "") AS traffic_medium,
      IFNULL(sessions.trafficSource.source, "") AS traffic_source,
      IFNULL(sessions.trafficSource.campaign, "") AS campaign,
      EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) AS visit_hour,
      traffic_metrics.bounce_rate,
      conversion_metrics.conversion_rate,
      IF(sessions.trafficSource.medium = 'organic', 1, 0) AS is_organic,
      IF(EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) >= 18 AND EXTRACT(HOUR FROM TIMESTAMP_SECONDS(sessions.visitStartTime)) <= 23, 1, 0) AS evening_visit,
      ROUND(IFNULL(totals.timeOnSite, 0) / GREATEST(IFNULL(totals.pageviews, 0), 1), 2) AS avg_time_pageview,
      (
        SELECT
          COUNT(*)
        FROM
          `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS inner_sessions
        WHERE
          inner_sessions.fullVisitorId = sessions.fullVisitorId
          AND PARSE_DATE('%Y%m%d', inner_sessions.date) < PARSE_DATE('%Y%m%d', sessions.date)
      ) AS visit_frequency,
      (
        SELECT
          SUM(totals.transactionRevenue)
        FROM
          `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS inner_sessions
        WHERE
          inner_sessions.fullVisitorId = sessions.fullVisitorId
          AND PARSE_DATE('%Y%m%d', inner_sessions.date) < PARSE_DATE('%Y%m%d', sessions.date)
      ) AS total_transaction_value,
      PARSE_DATE('%Y%m%d', sessions.date) AS visit_date
    FROM
      `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS sessions
    LEFT JOIN traffic_metrics ON sessions.trafficSource.source = traffic_metrics.source
    LEFT JOIN conversion_metrics ON sessions.device.operatingSystem = conversion_metrics.operating_system
    AND sessions.device.deviceCategory = conversion_metrics.device_category
    AND sessions.device.browser = conversion_metrics.browser
    WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'
    AND (sessions.totals.transactions IS NOT NULL OR RAND() < 0.05)
  )
);
