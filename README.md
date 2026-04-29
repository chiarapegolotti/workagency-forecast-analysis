# WorkAgency – Forecast vs Actual Analysis

## Overview

This project analyzes the difference between forecasted and actual performance in a simulated staffing agency scenario.

The objective is to measure variance at contract level and understand where and why it occurs.

The dataset was generated to reflect a realistic business environment. SQL was used to clean and transform the data, while Power BI was used to build a dashboard for analysis and insights.


## Business Problem

In a staffing agency, variance between forecasted and actual performance is expected. Forecasts are typically based on standard working hours, while real operations include overtime and absences.

These differences directly impact costs and margins. Absence hours often represent an internal cost, while overtime can become a significant expense if it exceeds contractual or annual limits.

For this reason, understanding where variance occurs and what drives it is essential for monitoring performance and preventing cost inefficiencies.

Additional factors such as misaligned invoicing or payroll adjustments can also affect the analysis and must be handled carefully during the data preparation phase.

## Key Questions

- Where does variance occur: at worker contract level or at client level?
- At which point in time does variance mainly arise?
- What are the main drivers of variance between forecast and actual performance?
- Which business areas (clients, branches, workers) are most affected by variance?

## Data Description

The dataset is generated through a custom script simulating a real-world staffing agency environment.

The model includes at least six branches, where workers can be assigned to multiple clients over time, typically within a limited number of contract extensions (prorogations).

Forecast's costs and revenues are based on hourly rates and are processed through SQL transformations to reflect a monthly granularity.

The actuals dataset is derived from the forecast data, with a controlled random variance of approximately ±5% applied to both costs and revenues to simulate real operational differences.

Actuals represent invoice-level data, reflecting the financial reality of a staffing agency at monthly level.

## Data Modeling

The dataset follows a star schema architecture.

Data is first ingested into a raw layer, where initial checks are performed to identify anomalies, null values, and consistency issues.

It is then cleaned and transformed in a staging layer to align with business requirements.

Forecast data is expanded to a monthly granularity by prorating hourly cost and revenue (weekly hours * 4.333 factor), after filtering for the latest snapshot.

The model includes the following dimension tables:
- Branch (6+ branches)
- Clients
- Workers
- Internal Sales

The fact table combines both forecast and actuals data, distinguished by a `source_table` field.

Additional data quality checks are applied at fact level, along with logging mechanisms to track forecast snapshot differences.

A data mart layer is also included to enable faster analysis and reporting.


## Challenges & Solutions

### 1. Grain expansion in forecast data

One of the first challenges was correctly handling the grain expansion in the forecast dataset.

During early development, it was difficult to control how many rows should be generated after expanding the data to a monthly level, which led to inconsistencies in aggregation and data volume.

This required refining the logic behind the time expansion to ensure a consistent and predictable monthly granularity.

---

### 2. Contract end-date logic

Another challenge was managing different scenarios related to contract end dates:

- contracts with a defined end date
- contracts still ongoing
- missing or incomplete end dates

The implemented logic prioritizes:
1. actual end date, if available  
2. planned end date, if actual is missing  
3. a fallback future date (set to 2050 in this model) for open-ended contracts

This approach ensures continuity in time-based calculations while preserving business realism.

---

### 3. Data cardinality and worker ID inconsistencies

The most critical issue was related to worker ID integrity.

The original assumption was that each worker ID had a 1:1 relationship with a worker. However, the data revealed a many-to-one relationship due to inconsistencies in the generated dataset.

This led to incorrect assumptions in the dimensional model.

The issue was resolved by rebuilding the worker dimension based on a cleaned mapping between worker names and standardized IDs:

- grouping workers by normalized worker name
- using a deterministic ranking system to generate surrogate keys
- validating missing mappings through join checks between staging and dimension tables

This ensured a consistent and reliable worker dimension model.

## Dashboard Overview

The dashboard is organized into four main quadrants.

The top-left section contains key KPI cards, including actual revenue, variance percentage, and margin. A client-level slicer allows filtering performance by customer.

The top-right section provides a deeper analysis of variance at worker contract level. This approach ensures a more accurate interpretation of variance, as aggregating at client level can offset deviations between workers (e.g., overtime and absences balancing each other out).

A time filter is also available to analyze trends over different periods.

The bottom-left section contains a detailed table with key KPIs and performance drivers at branch level.

The bottom-right section shows a time series comparison between forecasted and actual revenue, helping to identify when deviations occur over time.

![Dashboard](images/dashboard.png)

## Key Insights

The analysis shows that variance is not evenly distributed over time and can present significant spikes that heavily influence overall performance metrics.

In a staffing agency context, these fluctuations are often driven by operational factors such as absences and overtime.

Absences, especially during the first days of sick leave, are typically covered by the agency and can increase costs. In some cases, agencies adjust hourly rates to compensate for recurring absence-related costs, especially when this becomes a consistent pattern across clients or workers.

On the other hand, overtime can increase revenue in the short term but becomes a critical cost driver when it exceeds contractual or annual thresholds (e.g. ~20 overtime hours per month). Beyond this point, taxation and additional labor costs can significantly impact margins, potentially requiring renegotiation of client pricing or the hiring of additional workers.

These dynamics are often seasonal, with higher volatility observed during peak periods such as July–August and December–January.