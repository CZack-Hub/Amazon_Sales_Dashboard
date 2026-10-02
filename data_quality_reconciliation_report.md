# Amazon India E-Commerce Sales: Data Quality & KPI Reconciliation Report

**Source Dataset:** Kaggle (`thedevastator/unlock-profits-with-e-commerce-sales-data`)  
**Data Grain:** Transactional line-item (1 row = 1 SKU in an order)

---

## 1. Executive Control Totals (Reconciliation Baseline)

These control numbers are verified and should match across **Python**, **SQL**, and **Power BI**:

| Metric | Calculation / DAX Formula | Verified Value | Business Context |
| :--- | :--- | :--- | :--- |
| **Total Line Items** | `COUNTROWS(FactOrderLine)` | **128,975** | Total product rows processed |
| **Distinct Orders** | `DISTINCTCOUNT(FactOrderLine[order_id])` | **120,378** | Unique customer transactions |
| **Average Line Items/Order** | `DIVIDE(Total Line Items, Distinct Orders)` | **1.07** | Multi-item basket indicator |
| **Total Units Sold** | `SUM(FactOrderLine[qty])` | **116,649** | Total garment pieces moved |
| **Gross Merchandise Value (GMV)** | `SUM(FactOrderLine[amount])` | **INR 78,681,022.35** | Total booked sales including cancelled |
| **Net Realized Revenue** | `CALCULATE(SUM(FactOrderLine[net_revenue]))` | **INR 70,374,984.05** | Actual fulfilled cashflow |
| **Fulfilled Orders** | `[Total Orders] (Non-cancelled, non-returned)` | **101,201** (84.1%) | Successful shipments |
| **Cancelled Orders** | `CALCULATE([Total Orders], is_cancelled=TRUE)` | **17,271** (14.35%) | Primary operational leakage |
| **Customer Returns** | `CALCULATE([Total Orders], is_returned=TRUE)` | **1,992** (1.65%) | Return-to-Seller (RTS) rate |
| **Average Order Value (AOV)** | `DIVIDE([Net Revenue], [Fulfilled Orders])` | **INR 695.40** | Realized spend per fulfilled order |
| **Units per Fulfilled Order** | `DIVIDE([Total Units], [Fulfilled Orders])` | **1.15** | Basket depth |
| **B2B Order Volume** | `CALCULATE([Total Orders], b2b=TRUE)` | **794** (0.66%) | Wholesale enterprise orders |
| **B2B Net Revenue** | `CALCULATE([Net Revenue], b2b=TRUE)` | **INR 553,411.00** (0.79%) | B2B revenue contribution |

---

## 2. Key Data Transformations Applied
1. **Column Renaming**: Stripped spaces and converted all 24 raw column names to standardized `snake_case`.
2. **Date Standardization**: Parsed string dates (`MM-DD-YY`) into clean datetime objects covering `2022-03-31` to `2022-06-29`.
3. **State Normalization**: Corrected 22 misspelling and abbreviation variants (e.g. `Rajshthan` -> `Rajasthan`, `Nl` -> `Nagaland`, `Pondicherry` -> `Puducherry`, `Pb` -> `Punjab`).
4. **Amount & Qty Cleaning**:
   - For cancelled orders with missing amounts (7,566 rows), explicit zero values (0.0) were assigned since no payment was collected.
   - For remaining rare missing amounts on shipped items (~220 rows), imputed using SKU median price.
5. **Business Logic & Grain Enrichment**:
   - `is_cancelled`: Boolean indicator capturing both explicit `Cancelled` status and cancelled courier status.
   - `is_returned`: Boolean indicator capturing Return-to-Seller (RTS) and rejected orders.
   - `net_revenue`: Zero for cancelled/returned orders, preserving authentic fulfilled sales.
   - `status_group`: Consolidated 13 granular status strings into 5 clean operational buckets (`Delivered/Shipped`, `Cancelled`, `Returned`, `Pending`, `Operational Loss`).
