# Jewelry Sales & Profitability Analysis
Sales and profitability analysis of a jewelry retailer using SQL and Power BI.

## Project Overview

This project analyzes transactional sales data from a jewelry retailer to evaluate revenue, profitability, customer behavior, discount impact, and product performance.

The goal was not only to calculate sales KPIs, but also to answer practical business questions related to assortment management, pricing, discounts, and customer segmentation.

The analysis was performed using SQL for data exploration and business analysis and Power BI for KPI calculation and dashboard visualization.

Analysis period: 01 Apr 2024 – 15 Apr 2024

> The dataset represents a short transactional snapshot, therefore the project focuses on sales structure and profitability rather than long-term trends or seasonality.

---

## Tools & Technologies

- SQL
- Power BI
- DAX
- Data Modeling
- Data Visualization
- Business Analysis

### SQL techniques used

- JOIN
- GROUP BY
- CASE
- CTE
- DENSE_RANK()
- PARTITION BY
- Window Functions
- Cumulative SUM()
- COALESCE()
- NULLIF()
- COUNT DISTINCT

---

## Executive Dashboard

The Power BI dashboard provides a high-level overview of revenue, profitability, customer segments, product categories, and product performance.

![Jewelry Sales Dashboard](images/dashboard.png)

### Main KPIs

| KPI | Result |
|---|---:|
| Total Revenue | 1.28B PLN |
| Gross Profit | 776.11M PLN |
| Gross Margin | 60.66% |
| Average Basket Value | 216.36K PLN |

---

## 1. Discount Impact on Revenue & Margin

### Business Question

Are low discounts associated with higher sales and larger basket values without significantly reducing gross margin?

Transactions were grouped into discount levels using a `CASE` expression.

```sql
CASE
    WHEN LacznyRabat = 0 THEN '01. No discount (0%)'
    WHEN LacznyRabat <= 10 THEN '02. Low discount (1-10%)'
    WHEN LacznyRabat <= 25 THEN '03. Medium discount (11-25%)'
    ELSE '04. High discount (>25%)'
END AS DiscountLevel
```

The analysis compares:

- transaction count
- average basket value
- total revenue
- gross profit
- gross margin

### Results

| Discount Level | Average Basket Value | Total Revenue | Gross Profit | Gross Margin |
|---|---:|---:|---:|---:|
| No discount (0%) | 54.91K PLN | 311.37M PLN | 193.09M PLN | 62.01% |
| Low discount (1–10%) | 187.66K PLN | 967.96M PLN | 583.02M PLN | 60.23% |

Only two discount groups were present in the analyzed dataset: transactions without a discount and transactions with a discount of up to 10%.

Low-discount transactions generated approximately **3.1 times more revenue** than transactions without a discount.

The average basket value was also approximately **3.4 times higher** in the low-discount group.

At the same time, gross margin decreased only from **62.01% to 60.23%**, a reduction of **1.78 percentage points**.

### Key Finding

The low-discount group generated substantially higher revenue, gross profit, and average basket value while maintaining a gross margin close to that of full-price transactions.

This suggests that limited discounts may be commercially effective without causing severe margin erosion.

However, the analysis shows an association rather than causation. Differences in product mix, customer behavior, or transaction size may also contribute to the observed results.

### SQL Techniques

- `CASE`
- `COUNT(DISTINCT ...)`
- aggregation
- `NULLIF()`
- calculated profitability metrics

[View full SQL query](sql/01_discount_margin_analysis.sql)

---

## 2. Top Products Within Each Category

### Business Question

Which products generate the highest gross profit within their respective product categories?

Products were ranked independently within each product category based on gross profit.

A Common Table Expression was used together with the `DENSE_RANK()` window function:

```sql
DENSE_RANK() OVER (
    PARTITION BY p.GrupaTowarowa
    ORDER BY SUM(f.LacznaKwota - f.KosztWlasny) DESC
) AS CategoryRank
```

`PARTITION BY` creates a separate ranking for every product category.

Within each category, the product with the highest gross profit receives rank 1.

Only the top three positions from each category were retained.

The final result was then sorted by gross profit in descending order, so the most profitable products among all category leaders appear first.

### Example Results

| Product | Product Category | Category Rank | Revenue | Gross Profit |
|---|---|---:|---:|---:|
| Obrączka | BK PIERŚCIONKI OBRĄCZKI | 1 | 88.79M PLN | 55.55M PLN |
| Kolczyki, cyrkonia | IF KOLCZYKI | 1 | 38.57M PLN | 23.46M PLN |
| Pierścionek, cyrkonia | IF PIERŚCIONKI | 1 | 27.32M PLN | 17.15M PLN |

### Key Finding

The analysis identifies the three highest-gross-profit products within every product category while also highlighting which of those category leaders generate the most gross profit overall.

This provides a more useful category-management view than a simple overall Top 3 and can support decisions related to merchandising, product availability, and promotion.

### SQL Techniques

- CTE
- `DENSE_RANK()`
- `PARTITION BY`
- window functions
- aggregation
- ranking

[View full SQL query](sql/02_top_products_by_category.sql)

---

## 3. ABC Product Analysis

### Business Question

Which products are responsible for the majority of total revenue?

Revenue was first aggregated for every product and products were sorted from highest to lowest revenue.

A cumulative revenue share was then calculated using a window function.

```sql
SUM(RevenuePLN) OVER (
    ORDER BY RevenuePLN DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
```

The cumulative value was divided by total revenue to calculate each product's cumulative revenue contribution.

Products were then classified into three ABC groups:

- **Class A** — products contributing to the first 80% of cumulative revenue
- **Class B** — products contributing to the next 15%
- **Class C** — products contributing to the final 5%

### Key Finding

The analysis shows how revenue is concentrated across the assortment and identifies the products that are financially most important to the business.

Class A products require particular attention in inventory and availability planning because they account for the majority of revenue.

Class C products should not automatically be removed from the assortment, but they can be reviewed further to determine whether their strategic value justifies their relatively small revenue contribution.

### Business Value

ABC classification can support:

- inventory prioritization
- assortment management
- stock availability decisions
- identification of low-contribution products

### SQL Techniques

- multiple CTEs
- window functions
- cumulative `SUM()`
- `CASE`
- aggregation
- classification

[View full SQL query](sql/03_abc_product_analysis.sql)

---

## 4. Profitability by Weight Category and Metal Type

### Business Question

How do product weight and metal type affect revenue, gross profit, revenue per gram, and gross margin?

Products were grouped by weight category and metal type.

The analysis compares:

- transaction count
- total product weight
- revenue per gram
- total revenue
- gross profit
- gross margin

Revenue per gram was calculated as:

```sql
SUM(f.LacznaKwota) /
NULLIF(SUM(f.Waga), 0)
```

Gross margin was calculated as:

```sql
SUM(f.LacznaKwota - f.KosztWlasny) /
NULLIF(SUM(f.LacznaKwota), 0) * 100
```

### Results

#### Silver Products

| Weight Category | Revenue per Gram | Revenue | Gross Profit | Gross Margin |
|---|---:|---:|---:|---:|
| Lightweight | 760.18 PLN | 24.94M PLN | 17.32M PLN | 69.45% |
| Medium | 600.54 PLN | 41.47M PLN | 27.10M PLN | 65.33% |
| Heavy | 383.69 PLN | 57.67M PLN | 36.78M PLN | 63.77% |

For silver jewelry, heavy products generated the highest absolute gross profit, while lightweight products achieved the highest gross margin and revenue per gram.

#### Gold Products

| Weight Category | Revenue per Gram | Revenue | Gross Profit | Gross Margin |
|---|---:|---:|---:|---:|
| Lightweight | 7,403.02 PLN | 386.97M PLN | 239.97M PLN | 62.01% |
| Medium | 7,085.74 PLN | 567.44M PLN | 347.72M PLN | 61.28% |
| Heavy | 4,765.10 PLN | 200.84M PLN | 107.23M PLN | 53.39% |

For gold jewelry, medium-weight products generated the highest revenue and gross profit.

Lightweight gold products achieved a slightly higher gross margin and the highest revenue per gram, while heavy gold products showed the weakest margin performance.

### Overall Result

Across both metal types:

| Weight Category | Total Gross Profit |
|---|---:|
| Medium | 374.81M PLN |
| Lightweight | 257.29M PLN |
| Heavy | 144.01M PLN |

### Key Finding

Medium-weight jewelry generated the highest absolute gross profit overall.

However, lightweight products achieved the strongest percentage margins in both silver and gold.

This demonstrates an important distinction between **absolute gross profit** and **percentage profitability**.

A product group can generate more total profit because of higher sales activity while still having a lower margin percentage.

Heavy gold products stand out as the weakest group in terms of gross margin, at **53.39%**.

### SQL Techniques

- `JOIN`
- `GROUP BY`
- aggregation
- `NULLIF()`
- calculated revenue per gram
- calculated gross margin
- multi-dimensional segmentation

[View full SQL query](sql/04_weight_metal_profitability.sql)

---

## 5. Customer Segmentation

### Business Question

How do customer segments differ in revenue contribution, gross profit, transaction activity, and average basket value?

Customer segments were compared using:

- unique receipt count
- transaction count
- average basket value
- total revenue
- gross profit
- gross margin

Average basket value was calculated using unique receipt numbers:

```sql
SUM(f.LacznaKwota) /
NULLIF(COUNT(DISTINCT f.NumerParagonu), 0)
```

`COALESCE()` was used to handle transactions without an assigned customer segment.

### Results

| Customer Segment | Unique Receipts | Transactions | Average Basket Value | Total Revenue | Gross Profit |
|---|---:|---:|---:|---:|---:|
| Standard | 5,909 | 136,901 | 212.75K PLN | 1.26B PLN | 762.62M PLN |
| VIP | 572 | 629 | 38.77K PLN | 22.18M PLN | 13.49M PLN |

Standard customers generated approximately **98.27% of total revenue**, while VIP customers accounted for only **1.73%**.

The Standard segment also had a substantially higher average basket value:

- Standard: **212.75K PLN**
- VIP: **38.77K PLN**

The average Standard receipt was therefore approximately **5.5 times larger** than the average VIP receipt in the analyzed dataset.

### Key Finding

The Standard segment is the dominant source of both revenue and gross profit.

The VIP segment has significantly fewer receipts and a much lower average basket value, resulting in a very small contribution to overall revenue.

However, the available data is not sufficient to conclude that the VIP program itself is ineffective.

Further analysis would require additional customer-level information such as:

- number of unique customers
- purchase frequency
- customer retention
- customer lifetime value
- VIP qualification criteria
- acquisition and retention costs

The current result therefore identifies the VIP segment as an area for further investigation rather than suggesting that it should be removed.

### SQL Techniques

- `COALESCE()`
- `COUNT(DISTINCT ...)`
- `NULLIF()`
- aggregation
- calculated KPIs
- customer segmentation

[View full SQL query](sql/05_customer_segmentation.sql)

---

## SQL Skills Demonstrated

Across the five analyses, the project demonstrates practical use of:

- `JOIN`
- `GROUP BY`
- `CASE`
- Common Table Expressions (CTEs)
- `DENSE_RANK()`
- `PARTITION BY`
- window functions
- cumulative sums
- `COUNT(DISTINCT ...)`
- `COALESCE()`
- `NULLIF()`
- ranking
- segmentation
- calculated business metrics
- profitability analysis

The SQL analysis was designed not only to retrieve data, but to answer business questions related to pricing, assortment management, product profitability, and customer behavior.
