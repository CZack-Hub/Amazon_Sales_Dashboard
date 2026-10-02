🛒 Amazon India E-Commerce Sales & Operations Analytics
End-to-End Data Analytics Case Study using Python, SQL, Power BI & Excel

An end-to-end e-commerce analytics project analyzing 128,975 transaction line items and 120,378 distinct orders from an Amazon India marketplace dataset.
The project covers the complete analytics workflow:
Data Audit → Cleaning & ETL → Exploratory Data Analysis → Statistical Analysis → Star Schema Modeling → SQL Analytics → Power BI Dashboard → Business Insights & Recommendations
📊 Project Overview
This project analyzes Amazon India e-commerce operations across:
- Sales and revenue performance
- Product and SKU performance
- Customer segments
- B2B vs B2C sales
- Geographic distribution
- Fulfillment performance
- Cancellation and return behavior
- Shipping service levels
- Revenue concentration and Pareto analysis
The final deliverable is an interactive 6-page Power BI dashboard supported by Python EDA, SQL analysis, Excel validation, and a dimensional data model.
🎯 Business Objectives
The project aims to answer key business questions such as:
- How much revenue is being generated?
- What is the overall order and fulfillment performance?
- Which products and categories drive revenue?
- How concentrated is revenue across SKUs?
- Which states and cities contribute the most sales?
- How do Amazon and Merchant fulfillment compare?
- Where is cancellation leakage occurring?
- How does shipping service level affect cancellations?
- What is the contribution of B2B customers?
- Which products and regions are important for B2B sales?
📌 Key Business Results
Business Indicator	Verified Value
💰 Gross Merchandise Value (GMV)	₹78,681,022.35
💵 Net Realized Revenue	₹70,374,984.05
🛍️ Distinct Orders	120,378
📦 Transaction Line Items	128,975
🚚 Fulfilled Orders	101,201
❌ Cancellation Rate	14.35%
🔄 Return / RTS Rate	1.65%
🧾 Average Order Value	₹695.40
🏢 B2B Revenue	₹558,924.38
📈 B2B Revenue Share	0.79%
📊 Revenue Concentration	18.5% of SKUs → 80% of Revenue
🌍 Geographic Concentration	Top 3 States → 44.1% of Revenue


🧱 Data Architecture
A Star Schema was designed to avoid incorrect aggregation caused by the dataset's transaction-line grain.
Data Grain
1 row = 1 order line item

Multiple rows can belong to the same order because a customer can purchase multiple products in a single order.
Therefore, order-level metrics use:
DISTINCTCOUNT(order_id)
Star Schema
                         ┌──────────────┐
                         │   DimDate    │
                         └──────┬───────┘
                                │
                                │
┌──────────────┐         ┌─────▼─────────────┐
│ DimProduct   │────────►│   FactOrderLine   │
└──────────────┘         │    128,975 Rows   │
                         └─────▲─────────────┘
                                │
┌──────────────┐                │
│ DimGeography │────────────────┤
└──────────────┘                │
                                │
┌──────────────┐                │
│ DimStatus    │────────────────┘
└──────────────┘
Model Components
Table	Purpose
FactOrderLine	Transaction-level fact table
DimDate	Continuous calendar
DimProduct	Product and SKU attributes
DimGeography	City and state information
DimStatus	Standardized order-status groups


📊 Power BI Dashboard
The project contains a 6-page interactive Power BI dashboard.
Page 1 — Executive Overview
Focus: Overall business performance
- KPI scorecards
- Monthly Revenue & AOV
- Revenue Mix by Category
- Top States by Revenue
- Top SKUs by Revenue
- Interactive filters
Page 2 — Sales Performance & Run-Rate
Focus: Sales trends and revenue momentum
- Daily Sales Run-Rate
- 7-Day Moving Average
- Day-of-Week Revenue Seasonality
- Month-over-Month Revenue Growth
- Category Volume vs Revenue
Page 3 — Product Merchandising
Focus: Product and SKU intelligence
- Pareto 80/20 Revenue Analysis
- Product Performance Matrix
- Category × Size Analysis
- Revenue Decomposition
- SKU-level performance
Page 4 — Geographic Intelligence
Focus: Geographic sales distribution
- India State Revenue Map
- Top Metro Cities
- Category Preference by State
- Regional Concentration Analysis
Page 5 — Operations & Logistics
Focus: Fulfillment and operational performance
- Amazon vs Merchant Fulfillment
- Cancellation Rate by Fulfillment
- Order Status Distribution
- Shipping Service-Level Cancellation Analysis
Page 6 — B2B vs B2C & Channel Intelligence
Focus: Customer segments and B2B performance
- B2B vs B2C Revenue
- Revenue by Sales Channel
- B2B Revenue by Sales Channel
- B2B Product Category Demand
- Top States for B2B Purchasing
🧮 DAX & Power BI Analysis
The Power BI model contains measures for important business KPIs, including:
- Total Orders
- Total Units Sold
- Total Net Revenue
- Average Order Value
- Cancellation Rate
- Return Rate
- B2B Revenue
- B2B Revenue Share
- Monthly Revenue
- Month-over-Month Growth
- Product/SKU analysis
- Operational performance
Example: Order-Level Cancellation Rate
Cancellation Rate =
DIVIDE(
    [Cancelled Orders],
    [Total Orders],
    0
)
Order-level metrics use distinct orders rather than transaction rows.
🐍 Python Analysis
Python was used for:
- Data loading
- Data cleaning
- Missing-value analysis
- Data-type validation
- Duplicate detection
- Exploratory Data Analysis
- Revenue analysis
- Product analysis
- Geographic analysis
- Statistical analysis
- Visualization
🗄️ SQL Analysis
The project includes 30 SQL analytical queries organized into five modules.
01 — Data Quality
- Data grain auditing
- Multi-line order analysis
- Duplicate detection
- Control-total reconciliation
02 — Sales
- Daily sales
- Rolling averages
- Month-over-Month growth
- LAG()
- Window functions
03 — Product
- Category contribution
- Pareto / ABC classification
- Cumulative revenue
- Size-demand analysis
04 — Geography
- State rankings
- Geographic concentration
- Metro demand
- AOV variance
05 — Operations
- Amazon vs Merchant performance
- Shipping service levels
- Cancellation analysis
- Return-to-seller rates
- At-risk products
📗 Excel Validation
Excel was used as an independent QA layer for:
- Control totals
- Pivot-table validation
- Revenue reconciliation
- Order-count validation
- KPI verification
💡 Key Business Insights
1. Cancellation Leakage
The overall cancellation rate is 14.35%, representing a significant gap between booked GMV and realized revenue.
2. Revenue Concentration
18.5% of SKUs generate approximately 80% of revenue, highlighting the importance of high-value products.
3. Geographic Concentration
The top three states contribute approximately 44.1% of total revenue:
- Maharashtra
- Karnataka
- Telangana
4. B2B Contribution
B2B sales contribute approximately ₹558,924.38, representing 0.79% of total revenue.
📈 Business Recommendations
Fulfillment Optimization
Investigate higher cancellation levels associated with Merchant fulfillment and evaluate whether selected high-volume listings could benefit from FBA.
Inventory Prioritization
Prioritize monitoring and inventory planning for high-revenue Pareto SKUs and major revenue-generating categories.
Geographic Planning
Use regional demand concentration to support inventory positioning and fulfillment planning.
B2B Growth
Identify high-performing B2B categories and states to evaluate opportunities for expanding institutional sales.
🛠️ Technology Stack
Data Analysis
- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Jupyter Notebook
Business Intelligence
- Microsoft Power BI
- DAX
- Power Query
Database / Querying
- SQL
- CTEs
- Window Functions
- Aggregations
- Ranking Functions
Validation
- Microsoft Excel
- PivotTables
- Control Totals
📁 Repository Structure
amazon-ecommerce-data-analyst/
│
├── data/
│   ├── raw/
│   │   └── Amazon Sale Report.csv
│   │
│   └── processed/
│       ├── FactOrderLine.csv
│       ├── DimProduct.csv
│       ├── DimGeography.csv
│       ├── DimStatus.csv
│       ├── DimDate.csv
│       └── cleaned_amazon_sales.csv
│
├── notebooks/
│   └── amazon_ecommerce_analysis_and_visualization.ipynb
│
├── powerbi/
│   ├── Amazon_Sales_Dashboard.pbix
│   ├── dax_measures.dax
│   └── dashboard_construction_guide.md
│
├── sql/
│   ├── 01_quality.sql
│   ├── 02_sales.sql
│   ├── 03_product.sql
│   ├── 04_geography.sql
│   └── 05_operations.sql
│
├── excel/
│   └── amazon_validation.xlsx
│
├── clean_and_analyze.py
├── data_quality_reconciliation_report.md
├── requirements.txt
└── README.md
🚀 How to Run the Project
1. Clone the Repository
git clone https://github.com/your-username/amazon-ecommerce-sales-analytics.git
cd amazon-ecommerce-sales-analytics
2. Install Dependencies
pip install -r requirements.txt
3. Run the ETL Pipeline
python clean_and_analyze.py
4. Run the EDA Notebook
jupyter notebook notebooks/amazon_ecommerce_analysis_and_visualization.ipynb
5. Open the Power BI Dashboard
Open:
powerbi/Amazon_Sales_Dashboard.pbix
using Power BI Desktop.
📸 Dashboard Preview
Add your six final Power BI screenshots to a docs/ folder:
docs/
├── page1-executive-overview.png
├── page2-sales-performance.png
├── page3-product-analysis.png
├── page4-geographic-analysis.png
├── page5-operations.png
└── page6-b2b-channel-analysis.png
Then add them to this README:
## Dashboard Preview

### Executive Overview
![Executive Overview](docs/page1-executive-overview.png)

### Sales Performance
![Sales Performance](docs/page2-sales-performance.png)

### Product Analysis
![Product Analysis](docs/page3-product-analysis.png)

### Geographic Intelligence
![Geographic Intelligence](docs/page4-geographic-analysis.png)

### Operations & Logistics
![Operations](docs/page5-operations.png)

### B2B & Channel Intelligence
![B2B Analysis](docs/page6-b2b-channel-analysis.png)
💼 Resume Project
Amazon India E-Commerce Sales & Operations Analytics
Python | SQL | Power BI | DAX | Excel
- Built an end-to-end analytics solution on 128,975 transaction line items and 120,378 distinct orders, analyzing sales, products, geography, fulfillment, and B2B performance.
- Designed a Star Schema data model using FactOrderLine, DimProduct, DimGeography, DimStatus, and DimDate to prevent multi-line order aggregation errors.
- Developed 30 SQL analytical queries using CTEs, window functions, ranking, rolling averages, MoM growth, and Pareto analysis.
- Built a 6-page interactive Power BI dashboard with DAX measures for revenue, AOV, cancellation rate, B2B contribution, product concentration, and operational performance.
- Identified 14.35% cancellation rate and 18.5% SKU-to-80%-revenue concentration, translating analytical findings into business recommendations.
🎯 Skills Demonstrated
- Data Cleaning & Transformation
- Exploratory Data Analysis
- Data Quality Auditing
- Dimensional Data Modeling
- Star Schema Design
- SQL Analytics
- Advanced SQL Window Functions
- DAX
- Power BI Dashboard Development
- Business Intelligence
- KPI Development
- Statistical Analysis
- Data Visualization
- Business Insights
- Data Validation
- Analytical Storytelling
📌 Dataset
Dataset:
Amazon India E-Commerce Sales Dataset — Kaggle
Dataset identifier:
thedevastator/unlock-profits-with-e-commerce-sales-data
👨‍💻 Author
Chitresh Mathur
B.Tech — Computer Science & Engineering
Interests: Data Analytics | Business Intelligence | SQL | Python | Power BI | Data Visualization
⭐ If you found this project useful
Feel free to explore the repository, review the SQL queries, inspect the Power BI dashboard, and experiment with the analytical workflow.
