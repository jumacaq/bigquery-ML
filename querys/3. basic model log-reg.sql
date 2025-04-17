--Creando 1er Modelo
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

--Metricas y Evaluación con base de prueba
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
--Matriz de confusion
SELECT *
FROM ML.CONFUSION_MATRIX(MODEL `bqml_gaSessions.primer_model`, (SELECT * FROM TEST_DATA));

--Evaluación del modelo 
SELECT   *
FROM   ml.EVALUATE(MODEL `bqml_gaSessions.primer_model`, (SELECT * FROM TEST_DATA));

