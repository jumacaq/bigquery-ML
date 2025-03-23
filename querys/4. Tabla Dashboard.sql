--deploy
--Creando una tabla para guardar los datos
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

--Insertando los resultados de la predicción en la tabla de resultados
INSERT INTO `bootcampxperience.bqml_gaSessions.daily_predictions`
--Es vuestro turno, ¿podran construir la consulta BigQuery para llenar los atributos de la tabla?