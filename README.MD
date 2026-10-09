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


## Key Business Insights

1.	The dataset contains 20,134 completed orders, generating approximately £10.71 million in revenue across 5.66 million units. The average order value is £532.12, while the average basket contains approximately 281 units.

2.	Revenue is heavily concentrated geographically, with the United Kingdom accounting for approximately £7.34 million of completed-sales revenue. November 2011 was the strongest month, generating approximately £1.51 million, while Thursday generated the highest weekday revenue.

3.	Customer value is highly concentrated. The top 20% of customers account for 74.68% of revenue, with a 98.5% repeat-customer rate, highlighting the importance of customer retention. 

4.	The overall cancellation rate is relatively low at 1.72%, although it differs by product category. 


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

This decision was made because the primary objective is current customer and sales analysis rather than historical differences in customer attributes.

---


## Technology Stack

| Technology | Purpose |
|---|---|
| **BigQuery** | Cloud data warehouse |
| **dbt** | Data transformation, modelling and testing |
| **SQL** | Data transformation and analytical logic |
| **Git / GitHub** | Version control and project management |
| **UCI Online Retail Dataset** | [Source dataset](https://archive.ics.uci.edu/dataset/352/online+retail) | 
---

