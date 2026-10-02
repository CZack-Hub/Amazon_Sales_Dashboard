<div align="center">

# 📊 Amazon India E-Commerce Sales & Operations Intelligence Dashboard
### An End-to-End Enterprise Data Analytics & Business Intelligence Case Study

[![Power BI](https://img.shields.io/badge/Power_BI-Desktop-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![Python](https://img.shields.io/badge/Python-3.14-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![SQL](https://img.shields.io/badge/SQL-ANSI%20Standard-CC292B?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Excel](https://img.shields.io/badge/Microsoft_Excel-QA%20Validation-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white)](https://www.microsoft.com/excel)
[![Kaggle Dataset](https://img.shields.io/badge/Dataset-Kaggle-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white)](https://www.kaggle.com/datasets/thedevastator/unlock-profits-with-e-commerce-sales-data)

<p align="center">
  <b>Analyzed 128,975 marketplace transactions (~₹78.7M GMV) across Q2 2022 to uncover revenue momentum, product catalog concentration, fulfillment channel leakage, and B2B wholesale dynamics.</b>
</p>

[Key Metrics](#-executive-kpi-scorecard) • [Data Architecture](#-data-architecture--star-schema) • [Power BI Dashboard](#-power-bi-dashboard-architecture-6-pages) • [SQL Suite](#-sql-analysis-suite-30-interview-queries) • [Business Insights](#-business-insights--strategic-recommendations) • [How to Run](#-how-to-reproduce-locally)

---

</div>

## 📌 Executive Summary

This project delivers an end-to-end data analytics solution simulating an enterprise business intelligence engagement for an Amazon India apparel retailer. Rather than building static vanity charts, the project investigates operational health, catalog economics, and logistics efficiency.

### Core Business Problems Addressed:
1. **Revenue Realization vs. Leakage:** Out of **₹78.68M in gross booked GMV**, what proportion translates into realized cashflow, and where does revenue leak?
2. **Catalog Concentration (Pareto Principle):** How many SKUs generate the core 80% of revenue, and what does the apparel size demand curve look like?
3. **Logistics Channel Efficiency:** Does Amazon FBA (Fulfilment by Amazon) deliver lower cancellation and return-to-seller (RTS) rates than Merchant self-ship?
4. **Geographic Demand Distribution:** Which urban centers and states represent the primary revenue engines?
5. **Channel Dynamics:** How do wholesale B2B purchasing behaviors compare against retail B2C consumers in ticket size and basket depth?

---

## 📈 Executive KPI Scorecard

All metrics below have been reconciled and verified across **Python (Pandas)**, **SQL**, and **Power BI (DAX)** with **0 variance**:

| Key Performance Indicator | Verified Value | Calculation / Formula | Business Context |
| :--- | :--- | :--- | :--- |
| **Gross Merchandise Value (GMV)** | **₹78,681,022.35** | `SUM(FactOrderLine[amount])` | Total booked revenue before operational leakage |
| **Net Realized Revenue** | **₹70,374,984.05** | `SUM(FactOrderLine[net_revenue])` | Fulfilled cashflow collected (**89.44% realization**) |
| **Distinct Transactions** | **120,378 orders** | `DISTINCTCOUNT(FactOrderLine[order_id])` | Unique customer orders (prevents double-counting) |
| **Transaction Line Items** | **128,975 items** | `COUNTROWS(FactOrderLine)` | Row-level items purchased (**1.071 items/order**) |
| **Successfully Fulfilled** | **101,201 orders** | Non-cancelled, non-returned | **84.07%** operational fulfillment success rate |
| **Order Cancellation Rate** | **14.35%** (17,277 orders) | `Cancelled Orders / Total Orders` | Primary leak: **~₹8.3M trapped gross GMV** |
| **Return to Seller (RTS) Rate** | **1.65%** (1,985 orders) | `Returned Orders / Total Orders` | Courier return-to-origin shipments |
| **Average Order Value (AOV)** | **₹695.40** | `Net Revenue / Fulfilled Orders` | Realized spend per fulfilled order |
| **Average Selling Price (ASP)** | **₹667.49** | `Net Revenue / Total Units Sold` | Realized price per garment piece |
| **Pareto Catalog Concentration** | **18.5% SKUs $\rightarrow$ 80% Rev** | Top **1,332 SKUs** out of 7,195 | Class A products driving 80% of sales |
| **Top 3 States Revenue Share** | **44.1% of Net Rev** | Maharashtra, Karnataka, Telangana | Primary regional demand cluster |
| **B2B Revenue Contribution** | **₹558,924.38** (0.79% Rev) | Wholesale enterprise sales | **₹724.93 AOV** (wholesale ticket premium) |

---

## 🏗️ Data Architecture & Star Schema

To avoid the common analytical trap of double-counting revenue on multi-item orders, the raw transactional dump was restructured into an enterprise **Star Schema data model**:

```
                       ┌─────────────────────────┐
                       │         DimDate         │
                       │  - date (PK)            │
                       │  - year, month, quarter │
                       │  - day_of_week, DayNum  │
                       └────────────┬────────────┘
                                    │ 1
                                    │
                                    │ *
┌─────────────────────────┐  ┌──────┴──────────────────────────┐  ┌─────────────────────────┐
│       DimProduct        │  │          FactOrderLine           │  │      DimGeography       │
│  - sku (PK)             ├──┤  - order_line_id (PK)            ├──┤  - geo_key (PK)         │
│  - category, size       │1 │* - order_id (Business Key)       │* │1 - ship_state, city     │
│  - style, asin          │  │  - date, sku, geo_key, status_key│  │  - postal_code, country │
└─────────────────────────┘  │  - qty, amount, net_revenue      │  └─────────────────────────┘
                             │  - b2b, is_cancelled, is_returned│
                             └──────┬───────────────────────────┘
                                    │ *
                                    │
                                    │ 1
                       ┌────────────┴────────────┐
                       │        DimStatus        │
                       │  - status_key (PK)      │
                       │  - status, status_group │
                       │  - courier_status       │
                       └─────────────────────────┘
```

### The Data Grain Rule
* **Grain:** 1 row represents a single **order line item** (a product SKU inside an order).
* An individual `order_id` can repeat across multiple rows when a buyer purchases multiple garments.
* **Double-Counting Prevention:** Distinct orders must always be evaluated using `DISTINCTCOUNT(order_id)` or `COUNT(DISTINCT order_id)`.

---

## 📱 Power BI Dashboard Architecture (6 Pages)

The production dashboard (`powerbi/Amazon_Sales_Dashboard.pbix`) is styled using an Amazon brand palette (`#146EB4`, `#FF9900`, `#0F172A`), clean `#FFFFFF` floating cards with 8px rounded borders, subtle drop shadows, and a strict 15px alignment grid across 6 dedicated pages:

### Page Breakdown:
```
┌───────────────────────────────────────┬───────────────────────────────────────┐
│ Page 1: Executive Overview            │ Page 2: Sales Performance & Run-Rate  │
│ • 5 KPI Cards with MoM Callout Deltas │ • Daily Run-Rate & 7-Day MA Combo     │
│ • Monthly Net Revenue & AOV Combo     │ • Monthly Revenue & MoM Growth % Bars │
│ • Category Mix Donut Chart            │ • Day-of-Week Revenue Seasonality     │
│ • Top 10 States & Top 10 SKUs Table   │ • Category Volume vs. Revenue Scatter │
├───────────────────────────────────────┼───────────────────────────────────────┤
│ Page 3: Product & Merchandising       │ Page 4: Geographic Intelligence       │
│ • Pareto (80/20) SKU Curve & 80% Line │ • Full-Height India State Filled Map  │
│ • Product Performance & Return Matrix │ • Top 15 Metro Cities Bar Chart       │
│ • Category × Size Revenue Heatmap     │ • Category Mix Across Top 5 States    │
│ • AI Net Revenue Decomposition Tree   │ • Regional Concentration Index        │
├───────────────────────────────────────┼───────────────────────────────────────┤
│ Page 5: Operations & Fulfillment      │ Page 6: B2B vs B2C & Sales Channels   │
│ • Amazon FBA vs Merchant Volume Bars  │ • B2B vs B2C Revenue Mix Donut        │
│ • Cancellation Rate by Channel Chart  │ • Total vs B2B Channel Revenue Bars   │
│ • Operational Status Funnel Donut     │ • B2B Product Category Demand Treemap │
│ • Standard vs Expedited Service Bars  │ • Top 10 States for B2B Purchasing   │
└───────────────────────────────────────┴───────────────────────────────────────┘
```

---

## 🗄️ SQL Analysis Suite (30 Interview Queries)

Located in the **[`sql/`](sql/)** folder, this suite covers 30 technical queries written in ANSI SQL, designed to answer core business questions and demonstrate advanced SQL concepts:

| File | Focus Area | Advanced SQL Techniques Used |
| :--- | :--- | :--- |
| **[`01_quality.sql`](sql/01_quality.sql)** | Data Quality & Grain Verification | `COUNT(DISTINCT)` vs `COUNT(*)`, Grain ratio, Missingness cross-tabulation, Duplication auditing. |
| **[`02_sales.sql`](sql/02_sales.sql)** | Sales & Time Intelligence | Rolling 7-day Moving Averages (`AVG(...) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)`), MoM growth using `LAG()`, Peak day ranking (`DENSE_RANK()`). |
| **[`03_product.sql`](sql/03_product.sql)** | Merchandising & Pareto (80/20) | Running total cumulative sums (`SUM() OVER (ORDER BY rev DESC)`), ABC classification, Cross-tab size pivot using `CASE WHEN`, Rank disparity checks. |
| **[`04_geography.sql`](sql/04_geography.sql)** | Regional Demand & Concentration | Multi-state cumulative concentration indices, State AOV variance vs national benchmark (`CROSS JOIN`), High-density postal code clustering. |
| **[`05_operations.sql`](sql/05_operations.sql)** | Logistics, RTS & B2B Channels | Channel conversion leak rates, Shipping service level cross-tab, Return-to-Seller (RTS) rates, At-Risk product flags ($>25\%$ cancellation rate). |

---

## 🐍 Python Exploratory Data Analysis & Statistics

The pre-executed Jupyter Notebook (**[`notebooks/amazon_ecommerce_analysis_and_visualization.ipynb`](notebooks/amazon_ecommerce_analysis_and_visualization.ipynb)**) provides statistical validation across 28 modular cells:

* **Visual Analytics:** Built with `matplotlib` and `seaborn` (dual-axis run-rates, Category vs Size heatmaps, Lorenz Pareto concentration curves).
* **Statistical Hypothesis Testing:**
  * **Chi-Square Test of Independence:** Tested whether order cancellations are statistically independent of fulfillment channels (`Amazon FBA` vs `Merchant Easy Ship`).
  * **Result:** $\chi^2 = 142.84, p < 0.001$ $\rightarrow$ Statistically significant relationship. Merchant self-ship orders experience higher cancellation rates due to fulfillment latency.
* **Correlation Analysis:** Evaluated feature correlations across pricing, unit quantities, and operational exceptions.

---

## 📑 Excel QA & Reconciliation Workbook

Located in **[`excel/amazon_validation.xlsx`](excel/amazon_validation.xlsx)**, this workbook provides audit-proof reconciliation:
* **`Control_Totals_QA`:** Compares 12 core metrics across Python, SQL, and Power BI with automated green `PASS` flags.
* **`Monthly_Performance`:** Summarizes gross vs net revenue, orders, and realization rates.
* **`Category_Performance`:** Pivot summaries of units, gross GMV, net revenue, and ASP.
* **`State_Performance`:** State leaderboard with percentage contributions.
* **`Fulfillment_Operations`:** Fulfillment channel volume and cancellation rates.
* **`KPI_Dictionary`:** Comprehensive data dictionary and grain definitions.

---

## 💡 Business Insights & Strategic Recommendations

### 1. Plug the 14.35% Order Cancellation Leak (~₹8.3M Trapped GMV)
* **Insight:** 17,277 orders were cancelled, trapping **₹8.30M in unrealized GMV**. Cancellations are significantly higher on Merchant self-ship orders than Amazon FBA.
* **Strategic Action:** Transition high-velocity Merchant SKUs to **Amazon FBA** to leverage Prime delivery speeds, and deploy automated WhatsApp/SMS address confirmation workflows for Cash-on-Delivery (COD) orders.

### 2. Safeguard Inventory on the "Hero Duo" (Set & Kurta)
* **Insight:** *Set* (₹39.2M / 40.5%) and *Kurta* (₹21.3M / 28.5%) drive **nearly 70% of total company revenue**.
* **Strategic Action:** Implement automated safety-stock threshold triggers on the top 18.5% Pareto SKUs within these categories to avoid stock-outs during peak seasonal demand.

### 3. Rebalance Garment Manufacturing Ratios to the Size Curve
* **Insight:** Sizes **M, L, and XL** generate over 65% of fulfilled volume, whereas **XS, 5XL, and 6XL** represent long-tail demand.
* **Strategic Action:** Rebalance factory production batches to a 3:3:2 (M:L:XL) ratio and cut initial minimum order quantities (MOQs) on outlier sizes by 40% to reduce warehouse aging and clearance markdowns.

### 4. Optimize Logistics for Western & Southern India Hubs
* **Insight:** **Maharashtra (21.4%), Karnataka (13.7%), and Telangana (9.0%)** account for over 44% of total sales.
* **Strategic Action:** Stage regional safety stock in Western (Mumbai/Bhiwandi) and Southern (Bengaluru/Hyderabad) fulfillment centers to cut transit times and minimize transit cancellations.

---

## 📁 Repository Structure

```text
amazon-ecommerce-data-analyst/
├── .gitignore                                            # Ignores large raw CSVs (>50MB) and temp files
├── README.md                                             # Comprehensive project portfolio documentation
├── requirements.txt                                      # Python dependencies
├── clean_and_analyze.py                                  # Automated ETL pipeline script
├── data_quality_reconciliation_report.md                 # Verified control numbers documentation
├── data/
│   ├── raw/
│   │   └── .gitkeep                                      # Raw CSV archive location (Amazon Sale Report.csv)
│   └── processed/
│       ├── DimProduct.csv                                # Dimension: 7,195 SKUs
│       ├── DimGeography.csv                              # Dimension: 14,437 Cities/States
│       ├── DimStatus.csv                                 # Dimension: 20 Status Buckets
│       └── DimDate.csv                                   # Dimension: Continuous Calendar (91 Days)
├── notebooks/
│   └── amazon_ecommerce_analysis_and_visualization.ipynb # Pre-executed 28-cell EDA Notebook (864 KB)
├── powerbi/
│   ├── Amazon_Sales_Dashboard.pbix                       # Production Power BI Workbook (5.12 MB, 6 Pages)
│   ├── dax_measures.dax                                  # Reference library of 18 DAX measures
│   └── dashboard_construction_guide.md                   # Visual blueprint and layout documentation
├── sql/
│   ├── 01_quality.sql                                    # Q1–Q6: Data grain & reconciliation
│   ├── 02_sales.sql                                      # Q7–Q12: Run rates, moving averages & MoM
│   ├── 03_product.sql                                    # Q13–Q18: Pareto 80/20 & size cross-tab
│   ├── 04_geography.sql                                  # Q19–Q24: State rankings & metro demand
│   └── 05_operations.sql                                 # Q25–Q30: FBA vs Merchant & cancellations
└── excel/
    └── amazon_validation.xlsx                            # Multi-sheet QA & Control Reconciliation
```

---

## 🚀 How to Reproduce Locally

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/amazon-ecommerce-sales-analytics.git
cd amazon-ecommerce-sales-analytics
```

### 2. Set Up Python Environment & Install Dependencies
```bash
python -m venv venv
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

pip install -r requirements.txt
```

### 3. Run the Data Pipeline & Star Schema Generator
```bash
python clean_and_analyze.py
```
*This downloads/verifies the raw dataset, executes all cleaning rules, creates the Star Schema CSVs in `data/processed/`, and prints verified control totals.*

### 4. Explore the Visualizations & Reports
* **Power BI:** Open `powerbi/Amazon_Sales_Dashboard.pbix` in **Power BI Desktop** to explore the 6 interactive pages.
* **Jupyter Notebook:** Launch `jupyter notebook notebooks/amazon_ecommerce_analysis_and_visualization.ipynb`.
* **SQL Queries:** Open and run any script in `sql/` against your preferred SQL database.

---

## 💼 Resume Project Description

**Amazon India E-Commerce Sales & Operations Analytics** | *Python, SQL, Power BI, DAX, Excel*
* Engineered an end-to-end analytics solution on **128,975 marketplace transactions** (~₹78.7M GMV) analyzing sales trends, product Pareto concentration, logistics, and B2B wholesale channels.
* Designed and deployed a **Star Schema data model** (`FactOrderLine`, `DimProduct`, `DimGeography`, `DimStatus`, `DimDate`) preventing multi-line grain distortion across 120,378 distinct orders.
* Authored **30 interview-grade SQL queries** using CTEs, window functions (`LAG`, `DENSE_RANK`, `SUM() OVER ()`), and cross-tab pivots for MoM growth, Pareto 80/20 classification, and operational funnels.
* Developed an interactive **6-page Power BI dashboard** with 18 DAX measures for Net Revenue, AOV, Cancellation Rates, moving averages, and merchandising decomposition trees.
* Identified that **18.5% of SKUs generate 80% of revenue** and surfaced a **14.35% cancellation rate** (~₹8.3M leakage), providing 4 evidence-backed management recommendations.

---

<div align="center">
  <b>Project Developed by a Dedicated Data Analyst</b><br>
  Feel free to connect on <a href="https://linkedin.com">LinkedIn</a> or star ⭐ this repository if you found it useful!
</div>
