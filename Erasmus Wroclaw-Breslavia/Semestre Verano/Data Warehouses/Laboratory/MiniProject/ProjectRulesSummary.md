# Data Warehouse Mini-Project — Rules & Constraints Summary

## Overview

The goal is to build a **complete, end-to-end analytical data platform** following a data warehouse architecture. The project is split into **4 stages**, each with its own **deliverable work** and a **group presentation**.

---

## General Principles

- Keep it manageable — this is a **mini-project**, not a corporate-grade data warehouse.
- Experiment freely — the environment is safe; mistakes cost nothing.
- Cover the **full pipeline**: from raw data sources all the way to user-facing reports.
- Work in **groups of 2**.

---

## Project Stages

### Stage 1 — Analysis
**Focus: Data Selection & Requirement Analysis**

#### Work deliverable
- Find and select your dataset(s).
- Perform **basic data profiling** (understand structure, quality, volume).
- Describe the **analytical needs** of your target users (OLAP requirements).
- Identify candidate **dimensions**, **facts**, and **measures**.

#### Presentation
- Introduce the **domain** (core concepts, business context).
- Describe **1–2 end-user types** and their decision-support needs.
- Provide **data source details**: access method, format, change rate, granularity.
- Give a **dataset overview**: content, model structure, availability.
- Present a **dimensional synopsis**: name the underlying business process (events/statuses) and potential dimensions (context/perspectives).
- Highlight **specific selected user needs** focused on decision support.
- Comment on **expected analytical results** from an end-user perspective.
- Duration: **10–15 minutes** depending on the number of groups.

---

### Stage 2 — Design
**Focus: Multidimensional Model & ETL Design**

#### Work deliverable
- Design the **multidimensional model** (star/snowflake schema).
- Create a **Logical Data Map** (source-to-target mapping).
- Plan and design the **ETL process**: extract → clean → transform → load.

#### Presentation
- Present the model design and mapping decisions to the group.

---

### Stage 3 — Implementation
**Focus: ETL & OLAP Cube**

#### Work deliverable
- Implement the full **ETL pipeline** using **SQL Server Integration Services (SSIS)**.
  - Staging layer: extracted data must be staged in a **separate relational database**.
- Implement the **multidimensional cube** using **SQL Server Analysis Services (SSAS)**.
  - A single dimensional data cube is required.

#### Presentation
- Demonstrate the working ETL process and cube.

---

### Stage 4 — Usage (OLAP & Visualisation)
**Focus: Reporting & Dashboards**

#### Work deliverable
- Connect to the implemented cube and perform **data analysis and visualisation** using **Tableau** or **Power BI Desktop**.
- Deliver a set of **well-designed reports, visualisations, and interactive dashboards** that address all identified user OLAP needs.

#### Presentation
- Present and walk through the final dashboards and analytical insights.

---

## Data Requirements & Constraints

### Sources
| Requirement | Detail |
|---|---|
| Minimum number of sources | **At least 2 separate data sources** (e.g., sales orders + weather, taxi rides + bike share) |
| Single-source exception | Allowed only with **explicit justification**; may negatively affect score |
| Formats | CSV, TSV, TXT, database dumps, live DB connections — **mixture strongly encouraged** |
| Nature of data | Must be **operational** (close to raw data generation) — avoid pre-aggregated or analysis-ready datasets |

### Model Requirements
| Requirement | Minimum | Recommended |
|---|---|---|
| Measures (facts) | 3 | 4+ |
| Dimensions | 4 | 4–5 |
| Attributes per dimension | 5 | 5–10 |

### Content Checklist
- Data should represent a **series of measurable events or statuses** over time.
- Events examples: product sales, room rentals, social media comments, item reviews, meeting attendance.
- Measures examples: sales amount, rental rate, sentiment score, review score, processing time.
- Dimension/perspective examples: Product, Customer, Location, Time, Employee, Room, News Outlet.

### Prohibited
- ❌ **AdventureWorks** database cannot be used.
- ❌ Highly aggregated or pre-processed "analysis-ready" datasets.

---

## Architecture Requirements

The platform must follow this layered architecture:

```
External Data Sources
        ↓
   [ETL — SSIS]
        ↓
  Staging Database (relational, separate)
        ↓
  Data Mart (multidimensional model)
        ↓
  OLAP Cube (SSAS — single cube)
        ↓
  Reports & Dashboards (Tableau / Power BI)
```

---

## Suggested Public Data Sources

- [Kaggle](https://www.kaggle.com)
- [data.world](https://data.world)
- [Knoema](https://knoema.com)
- [r/datasets](https://reddit.com/r/datasets)
- [data.gov](https://data.gov)
- [dane.gov.pl](https://dane.gov.pl)
- [IoT Surrey datasets](http://iot.ee.surrey.ac.uk:8080/datasets.html) (road traffic, weather, parking, events)
- [NYC TLC Trip Records](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

---

## Scoring Notes

- Dataset selection **directly affects your final score** — richer, more interesting data scores higher.
- Using a single data source without justification **will negatively affect your score**.
- The project must cover **the entire pipeline** from ingestion to consumption.
- Heterogeneous data formats are **highly encouraged**.
