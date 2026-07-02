# Plan for Mini-Project 4 (P4) - Data Visualization and Consumption

## 1. Context and Current State (P3 Completion)
We have successfully completed Stage 3 (Implementation). The Data Warehouse (BTC_DW) is populated and the SSAS OLAP Cube (`BTC_Analytics_Cube`) has been built. We now have a solid foundation for data analysis and visualization.

### 1.1 Target User and Business Process
* **Primary User**: Blockchain Analyst / Researcher
* **Business Process**: Bitcoin Transaction Settlement (Grain: One confirmed on-chain transaction per row)

### 1.2 Data Model Available for Plotting
We have a star schema with one central fact table and four conformed dimensions:

**Fact Table**: `FACT_TRANSACTION`
Key pre-computed measures available for plotting:
- `fee_satoshis` & `fee_usd` & `fee_btc`
- `fee_rate_sat_vbyte` (Avg Fee Rate)
- `output_value_sat` & `output_value_usd` & `output_value_btc` (Settlement volume)
- `tx_vsize_bytes` (Canonical fee-analysis unit)
- `fee_burden_pct` (Fee in USD as a % of total output value in USD)
- `io_value_ratio` (Input value / Output value - helps detect fee burn and complex transactions)

### 1.3 SSAS Cube Architecture (`BTC_Analytics_Cube`)

**Dimensions & Hierarchies**:
1. **Date Dimension (`DIM_DATE`)**:
   - **Calendar**: Year -> Quarter -> Month -> Date
   - **Era**: Halving Era -> Year -> Date
   - **Weekday**: Is Weekend -> Day of Week
2. **Block Dimension (`DIM_BLOCK`)**:
   - **Difficulty**: Difficulty Tier -> Block Height
3. **Transaction Type Dimension (`DIM_TX_TYPE`)**:
   - **Script Evolution**: Script Type -> SegWit Flag
   - **Transaction Class**: Coinbase Flag -> Script Type
4. **Market Dimension (`DIM_MARKET`)**:
   - **Sentiment**: Fear & Greed Label -> Snapshot Date

**Base Measures (Aggregation: SUM, AVG, or COUNT)**:
- **Transaction Count**: `tx_key` (COUNT)
- **Total Fee**: `fee_satoshis`, `fee_btc`, `fee_usd` (SUM)
- **Avg Fee Rate**: `fee_rate_sat_vbyte` (AVG)
- **Total Output Value**: `output_value_btc`, `output_value_usd` (SUM)
- **Total Input Value**: `input_value_btc` (SUM)
- **Avg Fee Burden (%)**: `fee_burden_pct` (AVG)
- **Avg Transaction vSize**: `tx_vsize_bytes` (AVG)
- **Avg IO Value Ratio**: `io_value_ratio` (AVG)
- **Avg BTC Price USD**: `btc_price_usd_avg` (AVG)
- **Avg Fear & Greed Score**: `fear_greed_score` (AVG)

**Calculated Measures (MDX)**:
- **Net Value Transferred (BTC)**: `[Total Output Value (BTC)] - [Total Fee (BTC)]`
- **Fee Efficiency Ratio**: `[Total Fee (USD)] / NULLIF([Total Output Value (USD)], 0)`
- **SegWit Transaction Share (%)**: `([Transaction Count] WHERE [segwit_flag]=1) / [Transaction Count] * 100`
- **Coinbase Transaction Share (%)**: `([Transaction Count] WHERE [coinbase_flag]=1) / [Transaction Count] * 100`
- **Avg Block Transaction Count**: `[Transaction Count] / DISTINCTCOUNT([block_key])`

**Cube Perspectives (Views)**:
- **`On-Chain Analyst`**: A specialized view that hides internal surrogate keys and raw satoshi-level data, presenting only the clean, aggregated metrics (Transaction Count, Avg Fee Rate, Total Fee USD, Avg Fee Burden %, SegWit Share %, etc.) alongside Date, Market, and TX Type dimensions (hiding the overly granular Block dimension).

## 2. P4 Goals (Based on P4 Requirements)
The goal of P4 is to create a dedicated dashboard for the **Blockchain Analyst / Researcher** focusing on a selected aspect of analysis. We must use a visualization tool (e.g., Tableau, Power BI Desktop, or Metabase) connecting to our SSAS Cube / SQL Server.

### Task 1: Model Testing
We need to test the model by addressing 10 analytical queries. From our P3 design, we have 8 core analytical questions (Q1-Q8) ready. We will add 2 more to meet the 10-query requirement.
*   **Q1**: SegWit adoption rate over time (by quarter).
*   **Q2**: Fee-rate spikes under network congestion.
*   **Q3**: Distribution of transaction fee burden across transaction size tiers.
*   **Q4**: Correlation of transaction volume/value (USD) with the daily Fear & Greed Index.
*   **Q5**: Proportion of multi-input vs. single-input structure (using `io_value_ratio`).
*   **Q6**: Transaction evolution across halving eras.
*   **Q7**: Coinbase vs. standard transaction composition over time.
*   **Q8**: NVT Ratio under different sentiment regimes.

### Task 2: Data Visualization (Dashboard Plan)
**Goal:** Create a 7-pane dashboard (respecting the 7-/+2 rule) telling a cohesive story.
**Focus of Analysis:** The evolution of Bitcoin from a low-fee experiment to a high-value settlement layer driven by market sentiment and protocol upgrades.

#### Proposed Dashboard Layout & Visualizations:
1.  **KPI Headline**: Network Fee Sustainability (Total Fee BTC / Total Block Reward BTC).
2.  **Line Chart**: Total Settlement Volume (USD) vs. Average Fee Rate (sat/vB) over time (overlaying Halving Eras).
3.  **100% Stacked Bar Chart**: SegWit vs Legacy adoption by Quarter (Script Type Evolution).
4.  **Scatter Plot**: Fear & Greed Score vs. Daily Transaction Volume (Does greed drive on-chain volume?).
5.  **Bar Chart**: Fee Burden % distributed by Difficulty Tier or Transaction Size.
6.  **Pie/Donut Chart**: Coinbase vs. Standard Output Value (Miner behavior).
7.  **Heatmap/Matrix**: Average Fee Rate by Day of Week vs. Halving Era (When is the network cheapest to use?).

## 3. Next Steps for AI Agents
1. Evaluate if Q9 and Q10 need to be explicitly formulated from existing cube measures.
2. Provide the DAX / MDX or SQL queries to generate the pivot tables required for **Task 1**.
3. Output the structured datasets needed by the visualization tool (Tableau/Power BI) for **Task 2**.
4. Draft the final P4 Word/PDF report content analyzing the results and dashboard effectiveness.
