# BigQuery Model with Looker 🛒📊

## 1. Description

This repository demonstrates how to work with public **Google Analytics** data (Google Store) to create a purchase prediction model and visualize the results in **Looker**. The project is divided into several stages, from data preprocessing to creating a predictive model and visualizing it in an interactive dashboard..

---

## 2.🚀 Project Structure

The project is divided into two sections:

### 2.1 **Preprocessing Data** 🛠️
In this stage, queries are run on Google Analytics data to explore and prepare it for analysis. These queries include:
- Viewing data from a specific partition.
- Querying data from multiple partitions.
- Converting dictionaries to columns to facilitate analysis.

### 2.2 **Data Analysis** 📈
Several queries are run to analyze the data, including:
- Total number of transactions by browser and device type.
- Bounce rate by traffic source.
- Conversion rate by operating system, device category, and browser.
- Percentage of visitors who made a purchase on the website.

---

## 3. **Creation of Predictive Model** 🤖

Two **logistic regression** models are created using **BigQuery ML**:
- **First Model**: A basic model that predicts the likelihood of a user making a transaction.
- **Second Model (Enhanced)**: An improved model that includes basic feature engineering and adjustments to enhance assessment metrics, as a result I obtained this outcome with training data:
  
Threshold : 0.500

Precision : 0.824

Recall    : 0.621

Accuracy  : 0.943

F1-Score  : 0.708

Log-loss  : 0.147

ROC-AUC   : 0.978

Finally a **random forest** model was created to achieve a better result:
- **Third Model (Advanced)**: A more advanced model that includes advanced techniques of feature engineering, and data balancing, which obtained even better results than the above model with training data:
  
Threshold : 0.500

Precision : 0.841

Recall    : 0.938

Accuracy  : 0.951

F1-Score  : 0.887

Log-loss  : 0.209

ROC-AUC   : 0.987

Both models are evaluated using metrics such as the **confusion matrix** and other evaluation metrics provided by BigQuery ML.

---

## 4. **Dashboard Table in Looker** 📊
A table is created in BigQuery to store the model's daily predictions. This table is used to feed a **dashboard in Looker**, where key variables are displayed such as:
- label --> target variable
- op_syst,
- is_mobile,
- country,
- region,
- dev_category,
- browser,
- pageviews,
- hits,
- time_on_site,
- traffic_medium,
- traffic_source,
- campaign,
- visit_hour,
- is_organic,
- evening_visit,
- avg_time_pageview
- Access to [Dashboard 1](https://lookerstudio.google.com/reporting/cf58aef6-4ac7-4e92-a95b-535a2d26214d)
            [Dashboard 2](https://lookerstudio.google.com/reporting/de8628c4-8b9f-4291-a5c4-40924ae21044)


---

## 5. 🛠️ How to use this repository

1. **Clone the repository**:
   ```]bash
   git clone (https://github.com/jumacaq/bigquery-ML.git)

2. 🛠️ **Prerequisites**

Before you begin, make sure you have the following:

1. **Google Cloud Platform (GCP) Account**: You'll need access to BigQuery and permissions to create models and tables.
2. **Looker**: Configure Looker to connect to your BigQuery instance.
3. **Basic SQL Knowledge**: To run queries in BigQuery.
4. **Google Analytics Public Data**: We'll be using the `bigquery-public-data.google_analytics_sample` dataset.
