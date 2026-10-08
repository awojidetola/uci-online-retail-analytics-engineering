# UCI Online Retail — Analytics Engineering Project

## Overview

This project analyses the **UCI Online Retail dataset**, which contains transactional data from a UK-based online retailer covering the period **2009–2011**.

The project began as a SQL-based analysis of sales, customers, products and geography. It was subsequently **refactored into a structured analytics engineering pipeline using dbt and BigQuery**, separating data cleaning, transformation, dimensional modelling and reporting logic into reusable, testable layers.

---

## Architecture

The project follows a layered analytics engineering architecture:

```text
Raw
 │
 ▼
Staging
 │
 ▼
Intermediate
 │
 ▼
Mart (Core)
 │
 ▼
Mart (Reporting)
 │
 ▼
Analysis
```


### Staging

The staging layer prepares the raw UCI dataset for modelling through cleaning and standardising source fields, handling missing values, classifying cancellations, standardising data types adn removing duplicate transactions. 

### Intermediate

The intermediate layer applies business logic to transform the data, by introducing product taxonomy, date features, revenue calculations and other classifications. 

### Mart

This consists of the core layer and the reporting layer. The core layer has the fact and dimension tables. The reporting layer has analysis-ready marts that was used for analysis. 

---

## Key Business Insights

The final analysis identified:

| Metric | Result |
|---|---:|
| Completed orders | **20,134** |
| Revenue | **£10.71m** |
| Units sold | **5.66m** |
| Average order value | **£532.12** |
| Overall cancellation rate | **1.72%** |

### Customer Concentration

Revenue is highly concentrated among a relatively small group of customers.

The **top 20% of active customers generated 74.68% of completed revenue**, while the remaining 80% generated 25.32%.

This concentration highlights the importance of understanding customer value and retention when analysing the retailer's revenue base.

### Sales Trends

**November 2011** was the strongest month by revenue in the analysed period.

At a weekly-cycle level, **Thursday generated the highest revenue of any weekday**, indicating that revenue was not distributed evenly across the trading week.

---

## Data Treatment & Modelling Decisions

The pipeline explicitly handles several data-quality and modelling considerations within the source dataset.

- Missing product descriptions are retained and handled during transformation rather than silently removing the associated transactions. Where a product cannot be confidently classified, it is assigned to an **Unclassified/Miscellaneous** category.

- Invalid or non-positive prices are identified during the staging and transformation process so that they do not distort revenue calculations.

- Inventory-adjustment and other non-standard transaction records are identified separately from completed sales to ensure that sales metrics represent genuine completed transactions.

- Cancelled transactions are classified explicitly rather than being treated as ordinary sales. This allows the reporting layer to analyse both completed sales and cancellation behaviour without mixing the two.

- Duplicate transaction records are identified and handled during the staging process to prevent transaction values from being overstated.

- Product descriptions are mapped into broader analytical categories to support category-level reporting and comparison. Where a reliable classification cannot be established, the product remains in an **Unclassified/Miscellaneous** category rather than being assigned arbitrarily.

## Customer Dimension & SCD Strategy

The customer dimension uses a **Type 1 Slowly Changing Dimension (SCD)** approach.

Eight customers appear under multiple countries in the source data.

The project does not attempt to reconstruct historical customer-location changes. Instead, the **most recent country associated with each customer is retained**.

This decision was made because the primary objective is current customer and sales analysis rather than historical reconstruction of customer attributes.

Implementing SCD Type 2 would introduce additional historical complexity without materially improving the analytical questions addressed by this project.

---


## Technology Stack

| Technology | Purpose |
|---|---|
| **BigQuery** | Cloud data warehouse |
| **dbt** | Data transformation, modelling and testing |
| **SQL** | Data transformation and analytical logic |
| **Git / GitHub** | Version control and project management |
| **UCI Online Retail Dataset** | Source dataset |

---

