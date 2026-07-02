# Data Warehouses — Complete Study Guide
> Covers Lectures 0–8, 9, 10, 11, 12. Extendable: add new sections below each lecture heading.
> Exam format: multiple-choice (partial points, multiple answers possible) + short open-ended answers.
> **4 exam parts**: SQL for data analysis · OLTP/OLAP · DW architecture & data models · Data integration, reporting & visualisation.

---

## HOW TO USE THIS GUIDE
- **Definitions** → exact wording matters for open-ended questions.
- **Quiz traps** → marked with ⚠️.
- **Key comparisons** → tables.
- To extend: add `## Lecture N – <Title>` at the bottom, same structure.

---

# PART 1 — SQL FOR DATA ANALYSIS

## Lecture 2 & 3 — SQL for OLAP

### Relational Algebra (Reminder)
Five primitive operators (Codd): **selection, projection, Cartesian product, set union, set difference**.
Also: intersection, joins, renaming, aggregates.

---

### OLTP/OLAP Comparison

| Feature | OLTP | OLAP |
|---|---|---|
| User | Anyone | Knowledge worker |
| Function | Day-to-day operations | Decision support |
| DB design | Application-oriented | Subject-oriented |
| Data | Current, detailed, highly normalised | Historical, summarised, integrated |
| Access | Read/write, many concurrent users | Lots of scans, usually single user |
| Unit of work | Simple transaction | Complex query |
| DB size | MB–GB | GB–TB–PB |
| Metric | Transaction throughput | Query throughput / response time |
| Updates | Continuous | Sporadic, requires pre-processing |
| Data lifetime | Short | Long |
| Tuning | Frequent access to small data | Infrequent access to large data |
| Queries | Predefined application queries | Ad-hoc, complex, interactive |
| Retrieval | Detail row | Aggregation / GROUP BY |
| Critical for | Daily business operation | Management decisions affecting profitability |

> ⚠️ Quiz trap: OLTP data is *highly normalised*; OLAP data is *denormalised* or *multidimensional*.

---

### SQL Standard vs T-SQL
- **Standard SQL** — universal query language for relational DBs.
- **T-SQL (Transact-SQL)** — Microsoft extension of SQL used in SQL Server.
  - Procedural elements, proprietary functions (e.g., `ISNULL()`, `TOP` instead of `LIMIT`).

---

### PIVOT
Rotates rows into columns. Useful for cross-tab / matrix reporting.

```sql
SELECT [non-pivoted columns], [pivoted column values]
FROM ( <source query> ) AS SourceTable
PIVOT (
    aggregate_function(value_column)
    FOR pivot_column IN ([val1],[val2],[val3])
) AS PivotTable
```

**Process:** GROUP BY on input → for each output column, filter where `pivot_column = value`, apply aggregate.

**Example — sales by quarter:**
```sql
SELECT CustomerID, [1],[2],[3],[4]
FROM (
    SELECT CustomerID, TotalDue, DATEPART(quarter, OrderDate) AS QR
    FROM Sales.SalesOrderHeader
) AS SourceTable
PIVOT ( Sum(TotalDue) FOR QR IN ([1],[2],[3],[4]) ) AS PivotTable
ORDER BY CustomerID
```

**Weaknesses:** complex for large datasets, all pivot values must be known in advance (static), T-SQL specific.

---

### UNPIVOT
Rotates columns back into rows. ⚠️ NOT the exact reverse of PIVOT (aggregation merges rows; UNPIVOT cannot restore them). NULL values in PIVOT input disappear in UNPIVOT output.

```sql
SELECT Color, DTM, Value
FROM (SELECT Color, One, Two, Three, More FROM pvt) p
UNPIVOT (Value FOR DTM IN (One, Two, Three, More)) AS unpvt;
```

---

### CASE Expression
Two forms:

**Simple CASE** (compares expression to values):
```sql
CASE input_expression
    WHEN value1 THEN result1
    WHEN value2 THEN result2
    ELSE else_result
END
```

**Searched CASE** (evaluates boolean conditions):
```sql
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE else_result
END
```

Use in: SELECT, UPDATE, DELETE, SET, IN, WHERE, ORDER BY, HAVING.

**CASE for manual pivot (cross-tab):**
```sql
SELECT CustomerID,
    SUM(CASE WHEN DATEPART(quarter,OrderDate)=1 THEN TotalDue END) AS Q1,
    SUM(CASE WHEN DATEPART(quarter,OrderDate)=2 THEN TotalDue END) AS Q2,
    SUM(CASE WHEN DATEPART(quarter,OrderDate)=3 THEN TotalDue END) AS Q3,
    SUM(CASE WHEN DATEPART(quarter,OrderDate)=4 THEN TotalDue END) AS Q4
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
```

---

### Grouping Sets (SQL3 / SQL:2003)
SQL3 extends GROUP BY with three new operators to handle multiple aggregation levels without UNION ALL.

#### GROUPING SETS
Explicitly lists required groupings. Replaces a series of UNION ALL queries.

```sql
GROUP BY GROUPING SETS ((dim1), (dim2), (dim3), ())
-- () = grand total
```

**GROUPING() function:** distinguishes generated NULLs (subtotal rows) from real NULLs in data.
- `GROUPING(col) = 0` → NULL is from the actual data.
- `GROUPING(col) = 1` → NULL is generated (subtotal level).

#### ROLLUP
Hierarchical subtotals. Removes one column at a time from the right.

```sql
GROUP BY ROLLUP (a, b, c)
-- Equivalent to GROUPING SETS: (a,b,c), (a,b), (a), ()
-- N elements → N+1 grouping sets
-- ⚠️ ORDER IS SIGNIFICANT to ROLLUP
```

#### CUBE
All possible combinations.

```sql
GROUP BY CUBE (a, b, c)
-- Equivalent to GROUPING SETS: (a,b,c),(a,b),(a,c),(b,c),(a),(b),(c),()
-- N elements → 2^N grouping sets
```

**Comparison:**

| Operator | Grouping sets produced | Use when |
|---|---|---|
| GROUPING SETS | Only the ones you list | Custom set of aggregations |
| ROLLUP(a,b,c) | (a,b,c),(a,b),(a),() | Hierarchical drill-down |
| CUBE(a,b,c) | All 2^N combinations | Full cross-tab analysis |

---

### CTE (Common Table Expression) — WITH Clause
Temporary named result set valid only for the immediately following statement.

```sql
WITH cte_name (col1, col2, ...) AS (
    SELECT ...
)
SELECT * FROM cte_name;
```

**Uses:** readability, reusability (reference same CTE multiple times), recursion.

**Multiple CTEs:**
```sql
WITH CTE1 AS (...), CTE2 AS (... FROM CTE1 ...)
SELECT ... FROM CTE2;
```

**Best practices:** no nesting, define in logical order, name columns explicitly, document each CTE, test separately.

#### Recursive CTE
For hierarchical data (org charts, BOM, date ranges).

```sql
WITH CTE_Name (cols) AS (
    -- Anchor member (base case)
    SELECT ... FROM table WHERE parent IS NULL
    UNION ALL
    -- Recursive member (references CTE_Name)
    SELECT t.cols FROM table t
    INNER JOIN CTE_Name c ON c.id = t.parent_id
)
SELECT * FROM CTE_Name
OPTION (MAXRECURSION 100); -- default limit; 0 = infinite
```

**Structure requirements:**
1. Anchor member — starting point (e.g., root, CEO).
2. Recursive member — joins CTE back to base table for next level.
3. Termination — recursion stops when recursive member returns no rows.

⚠️ Cannot use GROUP BY, SUM(), DISTINCT inside recursive member. Must use UNION ALL (not UNION).

**Execution steps:** Execute anchor → produce T0 → execute recursive on T0 → T1 → ... → Tn (empty) → UNION ALL all results.

---

### Window Functions (OVER Clause)
Apply aggregate or analytic functions to a *window* (partition) of rows without collapsing them (unlike GROUP BY).

```sql
window_function(expression) OVER (
    [ PARTITION BY partition_cols ]
    [ ORDER BY order_cols ]
    [ ROWS | RANGE BETWEEN start AND end ]
)
```

**Notions:**
- **PARTITION** — divides result set into groups (like GROUP BY but keeps all rows).
- **ORDER** within partition — determines row sequence inside window.
- **FRAME** — subset of the partition relative to current row.

#### Default frame behaviour:
- With ORDER BY, no ROWS/RANGE: `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`.
- Without ORDER BY: entire partition.

#### ROWS vs RANGE
| | ROWS (physical) | RANGE (logical) |
|---|---|---|
| Boundary | Fixed number of rows | Value distance from current row |
| Duplicates | Not included | Included if same ORDER BY value |
| n PRECEDING/FOLLOWING | Row count | Value offset |

#### Frame keywords:
- `CURRENT ROW` — current row only.
- `UNBOUNDED PRECEDING` — start of partition.
- `UNBOUNDED FOLLOWING` — end of partition.
- `n PRECEDING` / `n FOLLOWING` — ROWS only.
- `BETWEEN X AND Y` — defines start and end boundary.

#### Aggregate Window Functions
`SUM(), AVG(), COUNT(), MIN(), MAX()` — used with OVER instead of GROUP BY.

```sql
-- Running total per territory
SUM(TotalDue) OVER (PARTITION BY TerritoryID ORDER BY OrderDate)

-- Percentage of customer total
100*OrderAmt / SUM(OrderAmt) OVER (PARTITION BY CustomerName)
```

---

### Ranking Functions
All require ORDER BY. Non-deterministic.

| Function | Behaviour | Ties |
|---|---|---|
| `ROW_NUMBER()` | Unique sequential number | No ties; arbitrary order among equals |
| `RANK()` | Rank with gaps | Same rank for ties; skips next numbers |
| `DENSE_RANK()` | Rank without gaps | Same rank for ties; no skipping |
| `NTILE(n)` | Divides into n buckets | Front-loaded if not evenly divisible |

```sql
ROW_NUMBER() OVER (PARTITION BY OrderDate ORDER BY CustomerName)
RANK() OVER (ORDER BY CustomerName)
DENSE_RANK() OVER (ORDER BY CustomerName)
NTILE(4) OVER (ORDER BY OrderDate)  -- quartile
```

---

### Analytic (Position & Percentile) Functions

#### Position Value Functions
| Function | What it does |
|---|---|
| `LAG(col, n, default)` | Value from n rows before current |
| `LEAD(col, n, default)` | Value from n rows after current |
| `FIRST_VALUE(col)` | First value in window frame |
| `LAST_VALUE(col)` | Last value in window frame |

LAG/LEAD do NOT support ROWS/RANGE. FIRST_VALUE/LAST_VALUE do.

#### Percentile Functions
| Function | Range | First group |
|---|---|---|
| `CUME_DIST()` | (0, 1] | % of rows with value ≤ current |
| `PERCENT_RANK()` | [0, 1] | Always 0 |

---

### Time-Intelligence OLAP Operations (key patterns)

**Running total:**
```sql
SUM(TotalDue) OVER (ORDER BY OrderDate) AS RunningTotal
```

**30-day moving average:**
```sql
AVG(SUM(TotalDue)) OVER (ORDER BY OrderDate ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
```

**Month-over-Month growth:**
```sql
LAG(Sales) OVER (ORDER BY Yr, Mo) AS PreviousMonthSales
(Sales - LAG(Sales) OVER (ORDER BY Yr, Mo)) / LAG(Sales) OVER (ORDER BY Yr, Mo) * 100 AS GrowthPct
```

**Year-over-Year (same month last year):**
```sql
LAG(Sales, 12) OVER (ORDER BY Yr, Mo) AS SalesLastYearSameMonth
```

**YTD (resets each year):**
```sql
SUM(TotalDue) OVER (PARTITION BY YEAR(OrderDate) ORDER BY OrderDate) AS SalesYTD
```

---

### SQL Execution Plans
**Definition:** sequence of steps the DB engine takes to execute a query. Reveals which tables/indexes accessed, join types, aggregation methods.

**Compilation phases:**
1. **Parsing** — syntax check → parse tree.
2. **Binding** — resolve object names against system catalog → query tree.
3. **Optimisation** — cost-based; produces execution plan stored in plan cache.

**Cost-based optimisation inputs:** query tree, statistics (index/column), constraints.

**Plan types:**
- **Estimated** — generated without execution (`CTRL+L` in SSMS).
- **Actual** — generated after execution (`CTRL+M` in SSMS), includes runtime statistics.

**Key operators:**
| Operator | Description |
|---|---|
| Clustered Index Scan | Reads all rows; expensive full scan |
| Clustered Index Seek | B-tree traversal; efficient targeted access |
| Key Lookup | Finds row from non-clustered index in clustered index |
| Nested Loops | Best for low cardinality outer, low inner cost |
| Merge Join | Best when both inputs sorted on join key |
| Hash Match | Best for large unsorted sets |
| Stream Aggregate | Requires sorted input; most efficient aggregate |
| Sort | Blocking operator; reorders data |
| Concatenation | UNION ALL — non-blocking |
| Compute Scalar | Computes new column values; non-blocking |

**Streaming vs blocking operators:**
- Streaming: passes rows as processed (non-blocking).
- Blocking: must process entire input before emitting any output (e.g., Sort).
- Semi-blocking: must complete part of work first (e.g., Hash Match).

**Reading plans:** right to left (data flow), or left to right (execution order). Arrow thickness = estimated (or actual) row count.

**OLTP plans:** Index Seek + Nested Loops (small result sets).
**OLAP/BI plans:** Index Scan + Merge Join / Hash Match (large data).

**Common pitfalls:**
- Ignoring indexes; SELECT *; functions on indexed columns in WHERE; wildcard `LIKE '%value'`; non-parameterised queries; unnecessary ORDER BY; overusing subqueries.

---

# PART 2 — OLTP / OLAP

## Lecture 1 & 2 — Business Intelligence, OLTP/OLAP Fundamentals

### Organisational Data Needs (Two Purposes)
1. **Data Capture** — transactional records, operational records, day-to-day activities.
2. **Data Analysis** — historical trends, strategic decisions, decision support.

### Short History of Data Models
- 1960s–70s: Hierarchical (IMS), Network (CODASYL).
- 1970s–80s: Relational, Entity-Relationship, Extended relational.
- Late 1980s–90s: Object-oriented, Object-relational.
- 2000s: Data Warehouses, MapReduce, NoSQL.
- 2010s: NewSQL, Cloud, Graph, Timeseries.
- 2020s: Blockchain DB, Vector DB.

### Business Intelligence (BI)
**Definition:** "The processes, technologies, and tools needed to turn data into information, information into knowledge, and knowledge into plans that drive profitable business action." (The Data Warehousing Institute)

Also: tools, technologies and applications supporting data integration, analysis, and reporting; turning raw data into actionable insights.

**BI system goals:** understand status, collaborate on shared data view, reduce time to decision; measure operations, develop integrated perspective, enhance competitive advantage.

**BI vs IS:** BI is a specific category of Information System purpose-built for analytical processing.

### BI, BA, DS, ML — Relationship
| | Focus | Question |
|---|---|---|
| BI | Descriptive & Diagnostic | "What happened?" / "Why?" |
| BA (Business Analytics) | Predictive | "What will happen?" |
| DS (Data Science) | Complex patterns, unstructured data | Discovering hidden patterns |
| ML | Prescriptive & automation | "What should we do?" / Automate |

**OLAP in ML:** not for model training directly; DW provides "Golden Records" (single source of truth). DS/ML algorithms use OLAP queries to extract wide, flattened datasets for model input.

---

# PART 3 — DW ARCHITECTURE & DATA MODELS

## Lecture 4 — ETL & Data Integration

### ETL vs ELT
| | ETL | ELT |
|---|---|---|
| Order | Extract → Transform → Load | Extract → Load → Transform |
| Transform location | Staging/dedicated tool | Inside target DB |
| Best for | Traditional DW, strict quality gates | Cloud/big data, powerful target engine |

### ETL Phases
1. **Extraction** — pull data from source systems.
2. **Transformation** — cleanse, harmonise, derive, aggregate.
3. **Loading** — write to DW (full reload or incremental/delta).

### Change Data Capture (CDC)
Detects row-level changes in source systems. Methods: timestamp columns, database triggers, log-based (most efficient/reliable).

### Data Profiling
Statistical analysis of source data to understand structure, content, and quality before designing ETL.

**Three screen types:**
1. **Structure screens** — test whether data matches expected format.
2. **Content screens** — inspect actual data values for anomalies.
3. **Business rule screens** — test whether data follows specific business rules (e.g., customer type prerequisites).

**Common column screens:**
- Known table row counts check.
- Column length restriction.
- Column numeric/date range.
- Column explicit valid/invalid values.
- Column distribution reasonability.

---

### Data Quality Frameworks — 5C's & 6D

**Kimball's 5C's** — business-oriented data quality goals:
| C | Question |
|---|---|
| **Clean** | Is the data error-free? Does it follow format rules and match reality? |
| **Consistent** | Is there one agreed version across all systems? No conflicting numbers? |
| **Conformed** | Can the business analyse it across common, shared dimensions? |
| **Current** | Is the data updated at the frequency the business needs? |
| **Comprehensive** | Is all the data needed for analytics available and collected? |

**6 Technical DAMA Dimensions** — engineering mapping of the 5C's:
| Dimension | Description | Maps to 5C |
|---|---|---|
| **Accuracy** | Data matches real world; correct values | Clean |
| **Validity** | Data follows format/business rules | Clean |
| **Consistency** | No discrepancies across systems/time | Consistent, Conformed |
| **Uniqueness** | No duplicates; single master ID per entity | Conformed |
| **Timeliness** | Data available within required time frame | Current |
| **Completeness** | No missing values; all required records present | Comprehensive |

⚠️ **Exam trap:** 5C's are Kimball's *business* language; 6D are the *technical* measurement dimensions. A "Conformed" business goal maps to both Uniqueness and Consistency technically.


### "Discovery-to-Enforcement" Workflow
1. **Phase 1 — Profiling (Analysis):** technical exploration → Data Quality Insights.
2. **Phase 2 — Rule Definition:** collaborate with stakeholders → Data Quality Requirements.
3. **Phase 3 — Quality Screens (Enforcement):** hard-code requirements into ETL/ELT pipeline → automated pass/fail gates.

---

### Data Observability
Continuous monitoring of data health and performance.
- **Static (Data Quality):** point-in-time, reactive (checks after data loaded).
- **Continuous (Data Observability):** proactive, ML-based anomaly detection, lineage-aware.

---

## Lecture 5 — Data Warehouses: Definitions & Architecture

### DIKW Hierarchy
**Data → Information → Knowledge → Wisdom**

| Level | Definition |
|---|---|
| **Data** | Raw, unorganised signals/symbols. No context. Collection of facts. |
| **Information** | Data organised, structured, processed. Data + meaning/context. |
| **Knowledge** | Understanding patterns in information. Know-how. Enables action. |
| *(Wisdom)* | Application of knowledge towards decisions. |

**Analogy:** Data = raw ingredients; Information = processed/cooked soup (ETL); Knowledge = eating soup to nourish decisions.

---

### Approaches to Integrating Heterogeneous Data

#### Query-Driven Approach (Lazy Integration)
- Build wrappers and mediators around heterogeneous sources.
- Query issued → metadata dictionary translates → inner queries to sources → results integrated.
- **Advantages:** access to current data, no data redundancy.
- **Disadvantages:** complex integration, very inefficient for frequent/aggregation queries, heavy OLTP load.

*On-demand variant:* queries run real-time (too heavy for OLTP).
*Eager variant:* queries collected, run during non-peak hours (fast retrieval but stale data).

#### Update-Driven Approach (Proactive)
- Data integrated from heterogeneous sources **in advance** and stored separately.
- Information available for direct querying.
- **Advantages:** high performance; data pre-copied, processed, integrated, annotated, summarised.
- **Disadvantages:** high data redundancy, update synchronisation challenges.

**Why separate storage?**
- Transactional layer tuned for OLTP (indexing, concurrency, recovery).
- Analytical layer tuned for OLAP (complex queries, multidimensional view, consolidation).

> **Data Warehouse = Update-Driven approach.**

---

### Data Warehouse — The Definition
**Inmon (1992):** *"A data warehouse is a subject-oriented, integrated, time-variant, and non-volatile collection of data in support of management's decision-making process."*

**Kimball:** *"A copy of transaction data specifically structured for query and analysis."* / *"A system that extracts data from source systems, transforms and loads to multidimensional structures, and further supports queries and reporting for decision support."*

**Gartner:** *"Storage architecture designed to hold data extracted from transaction systems, operational data stores, and external sources, combined in aggregated/summary form suitable for enterprise-wide analysis."*

#### What a DW Is NOT
- Not a process or tool (it is a data storage).
- Not just a view with UNION ALL.
- Not a dumping ground.
- Not any database with "DW" in the name.
- Not a normalised 3NF OLTP database.

---

### Inmon's 4 Characteristics

#### 1. Subject-Oriented
- Data organised around **business subjects** (products, customers, sales), not applications.
- Cuts across applications — no single application's flavour.
- Focused on analysis, not day-to-day operations.
- Provides concise view around specific subjects.

#### 2. Integrated
- Data from multiple heterogeneous sources: relational DBs, flat files, etc.
- Resolves inconsistencies: naming conventions (LastName vs FamilyName), encoding (long vs string), attribute scales (cm vs inch).
- Logical: semantic alignment, single version of truth.
- Physical: consistent formats, data types.

#### 3. Non-Volatile
- Physically separate store.
- Data loaded (governed write) and queried (read); operational updates do NOT occur.
- No transaction processing, recovery, concurrency control needed.
- Data is **frozen** — once in warehouse, not updated (except adding new data).
- ⚠️ Every query on same data → always same result.

#### 4. Time-Variant
- Contains historical data (5–10 years vs days/months in OLTP).
- Data stored as **snapshots** — each represents a point/period of time.
- Every data element has time element (explicit or implicit).
- Changes tracked and recorded (not overwritten).
- Incremental loads — changes add data, not replace.

**Snapshot components:**
1. Key — identifies the record.
2. Unit of time — when event occurred.
3. Primary data — directly related to key.
4. Secondary data — incidental data captured at snapshot moment.

> ⚠️ Non-volatile + time-variant: not contradictory. New snapshots are ADDED (non-volatile = old snapshots unchanged); time-variant = new snapshots track change over time.

---

### Data Granularity
- **Operational:** lowest level of detail (per-transaction).
- **DW:** multiple levels of granularity kept simultaneously.
  - Users start with summary data, drill down as needed.
  - Lower level = finer granularity.

---

### DW Components

#### Logical Components
```
[Data Staging Area] → [Data Organisation Area] → [Data Access Area]
     (ETL)               (DW / OLAP store)          (Reports, Tools)
```

**Data Staging Area:**
- Storage + process area (ETL).
- Off-limits to business users.
- No query/presentation services.
- Handles: extraction, cleaning, transformation, loading, refresh.

**Data Organisation Area:**
- The DW as business community sees it.
- Data organised for direct querying.
- Based on **multidimensional data model**.
- Separate from OLTP databases.
- Goals: integrated view, OLAP support, data mining, ad-hoc analysis.

**Data Access Area:**
- BI tools, pivot tables, data mining, ad-hoc query tools.
- All tools query the Data Organisation Area.

---

### Data Mart (DM)
- Simple form of DW focused on **single subject/functional area** (Sales, Finance, Marketing) or single LOB (Line of Business).
- Draws from few sources.
- ⚠️ DW = complex, general; Data Mart = focused, single-subject.

---

### Operational Data Store (ODS)
**Inmon & Imhoff (1996):** *"Subject-oriented, integrated, volatile, current-valued data store containing only corporate detailed data."*

| ODS | DW |
|---|---|
| Volatile (updated) | Non-volatile (frozen) |
| Current data only | Historical data |
| Operational reporting | Analytical/strategic reporting |
| Near real-time integration | Periodic batch loads |
| Lowest granularity | Multiple granularity levels |
| NOT optimised for trend analysis | Optimised for trends |

**ODS Types:**
- **Type I** — daily update, operational reporting tool.
- **Type II** — hourly update, complex information tracking.
- **Type III** — synchronous/near-sync, customer relationship management.
- **Type IV** — ODS as a staging area: acts as a temporary integration layer feeding the DW rather than serving end users directly.

---

## Lecture 6 — Multidimensional Data Model

### Facts, Measures & Dimensions

**Fact:** a business process event/measurement. Corresponds to physical observable events.
- Represents a snapshot of an event.
- Almost always numeric.
- Defined at a certain level of detail (grain).
- In ER: can be entity or n-ary relationship.

**Measure:** quantitative values describing the fact (e.g., sales amount, tax, quantity).
- Aggregated by BI system.
- General rule: **if an attribute is commonly aggregated → it's a fact**.

**Dimension:** context surrounding a fact — "who, what, where, when, why, how".
- Descriptive attributes used for filtering, ordering, grouping.
- General rule: **if an attribute drives aggregations → it's a dimension**.
- Called "soul of the DW" — provide entry points for business analysis.

**Grain:** level of detail at which facts are recorded.
- E.g., "a single product sold in a single transaction" vs "daily summary of product sales".

---

### Multidimensional Model — Core Concept
*"There are typically a number of different dimensions from which a given pool of data can be analysed."* — E.F. Codd, 1993

Every dimensional solution:
1. Describes a **business process**.
2. Captures **what is measured** (facts/measures).
3. Captures **context** in which measurements are evaluated (dimensions).

**Design is process-centric**, not report-centric. Facts correspond to events, not to reporting requirements.

---

### Data as a Cube
- Multi-dimensional data: each measure accessed using coordinate system composed of dimensions.
- `(Product=Laptop, Location=South, Year=2013) → 1016`
- ⚠️ A data cube/OLAP cube/hypercube is NOT necessarily a mathematical cube (sides not always equal).
- Multiple measures = add virtual dimensions.

**Logical representation in relational DB → Star Schema.**
**Physical representation in multidimensional DB → OLAP Cube.**

---

### DW Schemas

#### Star Schema
Most popular. Fact table in center connected to denormalised dimension tables.

**Structure:**
- **Fact table:** composite primary key (FKs to all dimensions) + measures. Many rows, few columns.
- **Dimension tables:** surrogate key + descriptive attributes. Not normalised.

**Characteristics:**
- Built for simplicity and speed.
- Dimension tables relatively static; fact table grows with appends.
- Easy to write queries; less joins.

**Advantages:** clearly depicts facts/dimensions, easy to comprehend, fast queries.
**Disadvantages:** redundant data in dimension tables, dimension tables must carry level indicators.

**Surrogate keys:** artificial numeric keys used in dimension tables instead of natural business keys. Provides independence from source system key changes.

#### Snowflake Schema
Normalised star schema. Dimension tables further normalised into multiple related tables.

**When to use:**
- BI tool requires it.
- Repeating groups of attributes in dimension (→ outrigger table).
- Significant missing values for a subtype (→ split table).
- Multiple hierarchies easier to represent explicitly.
- Multiple levels each in a separate table.

**Advantages:** smaller dimension tables, easier to handle changes, simpler ETL.
**Disadvantages:** fact tables = 90% storage (normalising dimensions gives insignificant storage benefit); more joins = slower performance; more complex.

> ⚠️ In practice: start with Star Schema, create snowflakes only where needed.

#### Fact Constellation Schema (Galaxy Schema)
Multiple fact tables sharing dimension tables. Used when analysing multiple business processes.

**Conformed Dimensions:** dimensions shared across fact tables. Must be identical or one must be a subset of the other.
- Same dimension — identical tables.
- Subset of rows — subset relevant to specific process.
- Subset of attributes — for roll-up across different grains.

**Drill-across technique:** querying across two fact tables linked via conformed dimensions. Performed in steps (query each fact separately, then combine on shared dimension key).

---

### Physical OLAP Storage

#### ROLAP (Relational OLAP)
- Data stored in relational DB (star/snowflake schema).
- OLAP operations via SQL.

#### MOLAP (Multidimensional OLAP)
- Data stored in multidimensional database (MDB).
- Cells contain measure values; coordinates = dimension intersections.
- Managed by **MDBMS** (Multidimensional DBMS) = OLAP Server/Engine.
- Standard interface: **XMLA** (XML for Analysis).

> ⚠️ MDB = a database. OLAP = activity/process of analysing. "OLAP cube" = MDB.

---

### 3NF in Data Warehousing
- Minimises redundancy, prevents anomalies.
- Good for integrated, consistent, redundancy-free storage.
- **Disadvantages for DW:** complex queries need many joins → slower; not optimised for direct user analysis; complex ETL; requires separate presentation layer for BI.

---

### Alternative Data Models

| Model | Description |
|---|---|
| **Normalised (3NF)** | Inmon-style corporate DW; flexible, consistent |
| **Dimensional (Star)** | Kimball-style; business-friendly, fast queries |
| **Data Vault** | Hub-Satellite-Link; flexible for changing sources |
| **OBT (One Big Table)** | Wide denormalised table; simple but inflexible |
| **Hybrid** | Combination of above |

**Dimensional models are resilient:** can add new fact columns, new foreign keys to fact tables, or new dimension attributes without changing existing queries.

---

### OLAP Operations Summary

| Operation | Description |
|---|---|
| **Roll-up** | Aggregate to coarser level (month → quarter → year) |
| **Drill-down** | Disaggregate to finer level (year → quarter → month) |
| **Slice** | Select one value from one dimension (filter) |
| **Dice** | Select range of values from multiple dimensions |
| **Pivot (Rotate)** | Reorient the cube (change row/column axes) |
| **Drill-across** | Query multiple fact tables via conformed dimensions |

---

## Lecture 7 — Dimensions, OLAP Operations & OLAP Architectures

### ER Model vs Dimensional Model

| | ER Model (OLTP) | Dimensional Model (OLAP) |
|---|---|---|
| Focus | Data consistency, non-redundancy, efficient storage | How managers view the business |
| Key technique | Entity-Relationship Modelling | Facts + Dimensions |
| Goal | Remove redundancy, ensure consistency, express microscopic relationships | Capture critical measures; provide intuitive views along dimensions |
| Audience | System/application developers | Business users |

---

### Facts and Dimensions (Lecture 7 Perspective)

**Fact:** something that has happened or been measured (e.g., sale of a product, total sales of an item in a month). Always numeric and usually associated with several dimensions.

**Dimension:** the main analytical object in a BI space. Can be a list of products, customers, time periods, geographic locations, or any entity used to analyse numeric data. Dimensions exist to add qualitative information to numerical facts. They are sometimes called the *"soul of the data warehouse"* — they contain the entry points and descriptive labels that enable the DW/BI system to be leveraged for business analysis.

---

### OLAP Operations — Detailed

#### Starnet Query Model
The Starnet model represents the dimensions of a cube as axes, showing all possible aggregation levels and paths (e.g., day → month → year → all; item → subcategory → category → all).

#### Drill Down (Roll-Down)
- Reverse of roll-up: moves from higher-level summary to lower-level detail, or introduces new dimensions.
- Example: Category → Product; Region → City; Quarter → Month.
- Simply means **adding a row header (dimension attribute) to an existing query**.
- In SQL: append a dimension attribute to the GROUP BY clause.
- ⚠️ Drilling down does **not** require predefined hierarchies or drill-down paths.

#### Roll Up (Drill Up)
- Summarises data by climbing up the hierarchy or by dimension reduction.
- Navigates from highly detailed to less detailed data.
- Example: Product → Category; City → Region; Month → Quarter.

#### Slice
- Selection (project + filter) on **one dimension** of the cube.
- Result is a subcube (one fewer dimension).

#### Dice
- Selection on **two or more dimensions** — forms a new subcube.

#### Pivot (Rotate)
- Rotates data axes to provide an alternative presentation of data.
- Visualisation operation: converts 3D view to a series of 2D planes.

#### Drill-Across
- Sets together multiple facts.
- Executes queries involving (i.e., across) more than one fact table.
- **Requires a conformed dimension** to coordinate the join.

---

### Dimension Hierarchies

**Definition:** a specification of levels that represents relationships between different attributes within a dimension. Attribute hierarchies describe relationships among dimension attributes (e.g., products fall within brands; brands within categories — these rules can be inferred without referring to actual data).

**Formal definition:** a partially ordered set of dimensional attributes `({D1, …, Dn, TopD}; →)` where `→` is a functional dependency. Attribute A determines B (A → B) if the value of B is uniquely determined by the value of A. `TopD` is the maximum element: `∀i: Di → TopD`. A partial ordering allows for **parallel hierarchies**. A fully-ordered set of classification levels is called a **Path**.

**Purpose:** hierarchies support roll-up and drill-down operations. Drilling down adds a dimension attribute from the next level down; drilling up removes a dimension attribute to a more general context.

#### Types of Hierarchies

| Type | Description |
|---|---|
| **Balanced** | Fixed number of clearly defined levels; all branches descend to same level. E.g., Time (Day → Month → Quarter → Year). Easy to implement. |
| **Unbalanced** | Branches descend to different levels; concept of levels does not apply uniformly. Recurrent/self-join. E.g., employee–supervisor chain. |
| **Ragged** | Logical parent of at least one member is not in the level immediately above — parent can come from any level above. Branches can have inconsistent depths (also called ragged-balanced because levels still exist). |
| **Parent-Child** | Self-referencing relationship within a single dimension table. Only one level assigned, but depth can be investigated. |

#### Attribute Hierarchies vs Instance Hierarchies

**Attribute hierarchy:** parent-child relationships among subsets of attributes. Example: Days → Months → Quarters → Years. The path from lowest to highest is defined by attribute structure.

**Instance hierarchy (recursive):** relationships defined between rows of the same dimension (e.g., employees report to employees; companies own other companies). Are recursive. Drilling requires tracing through recursive relationships between instances rather than adding/removing attributes.

#### Handling Unbalanced / Ragged Hierarchies

**Flattening:** creates new attributes that represent a fixed number of levels. The hierarchy looks like an attribute hierarchy but does not truly solve look-up/look-down problems.

**Hierarchy Bridge Table:** captures recursive instance relationships so the dimension table itself can remain normal-looking.
- Main tables: Fact (id FK, value); Dimension (id PK, name).
- Additional table: Hierarchy Table (HT) — `parent_id`, `sub_id`, `levels_removed`, optionally `node` (0/1), `leaf` (0/1), `level`.
- Each row in HT captures a relationship between a pair of rows in the dimension table.
- Two FK columns: one for higher-level entity, one for lower-level entity.
- Enables **looking down** (all orders under a company) and **looking up** (all transactions above a particular company).
- Involves a many-to-many relationship; if unsupported by tooling, requires decomposition into additional join configurations.

---

### Measures and Aggregates — Full Detail

#### Measure Components
A measure has two components:
1. **Numerical value** (e.g., sales price).
2. **Aggregation formula** (e.g., SUM) — used for aggregating/combining measure values into one.

Measure value is determined by a dimension value combination. Measure value should be meaningful for all aggregation levels.

#### Measure Additivity Types

| Type | Description | Examples |
|---|---|---|
| **Additive** | Can be added across **any** dimension | Total sales amount, quantity sold |
| **Semi-additive** | Can be added across **some** dimensions | Bank account balance (additive across accounts, NOT over time) |
| **Non-additive** | Cannot be added across **any** dimension | Product margin, averages, percentages, ratios, count of distinct |

> ⚠️ Semi-additive measures are common in **periodic snapshot fact tables** (e.g., inventory levels, account balances).

#### Measure Computation Categories

| Category | Definition | Examples |
|---|---|---|
| **Distributive** | F() is distributive if applying it to n aggregate values gives the same result as applying to all data without partitioning. | SUM, MIN, MAX, COUNT |
| **Algebraic** | Can be computed by an algebraic function with M arguments (bounded integer), each obtained from a distributive aggregate. Has G() for group aggregates and H() for consolidation. | AVG (= SUM/COUNT), standard deviation, min_N, max_N |
| **Holistic** | No constant bound on storage size needed to describe a subaggregate. No algebraic function with M arguments can characterise it. | MODE, MEDIAN, RANK |

> ⚠️ Holistic measures cannot be computed by pre-aggregating subcubes — they require all data together.

---

### Data Cube — Lattice of Cuboids

**Base cuboid:** the lowest level of summarisation; an N-D cuboid where N is the number of dimensions. E.g., base cuboid for Time, Item, Location, Supplier = 4-D cuboid.

**M-D cuboid:** M dimensions, with N-M summarised. E.g., 3-D cuboid for Time, Item, Location = summarised for all suppliers.

**Apex cuboid (0-D):** holds the highest level of summarisation — the grand total across all dimensions. Typically denoted `all`.

**Lattice:** the complete set of cuboids forms a lattice. Aggregations are computed from fine-grained data (base cuboid) upward. ⚠️ Aggregations are **irreversible** — having the sum, you cannot recover the parts.

---

### DW Schemas and Aggregates

#### Star Schema Aggregates
- Detail and summary data stored in a single fact table.
- A `Level` indicator in the dimension table identifies which aggregation level a row represents.
- Selecting aggregated rows requires filtering by `Level` in the dimension table.
- **Advantage:** easy to understand, easy to define hierarchies, reduces number of physical joins, low metadata maintenance.
- **Disadvantage:** summary data in fact table yields poorer performance for summary levels; the `Level` indicator is a potential source of error; huge dimension tables are problematic.

#### Snowflake Schema Aggregates
- No `Level` in dimension tables — eliminated by normalisation.
- Each dimension table has one key for each level of the hierarchy.
- The lowest level key joins to both the fact table and the lower-level attribute table.
- **Advantage:** best performance for queries involving aggregation.
- **Disadvantage:** complicated maintenance and metadata; explosion in number of tables.

#### Fact Constellation Aggregates
- Aggregate tables created separately from detail.
- **Advantage:** no need for a `Level` indicator since no aggregated data is mixed with lower-level detail.
- **Disadvantage:** dimension tables can still be very large; front-end must detect the existence of aggregate facts, requiring more extensive metadata.

---

### OLAP Architectures

#### MOLAP (Multidimensional OLAP)
Data stored in a **multidimensional database (MDDB)** — data is stored logically in arrays, where each cell is the intersection of all dimensions. Usually considered the OLAP standard.

**MDDB Implementations:** N-dim arrays, hash tables (SQL Server), quad trees, K-D trees.

**Optimisation techniques:**
- **Chunking** — cube divided into chunks to enable parallel processing and better memory management.
- **Two-level storage** — dense cubes stored as array structures; sparse cubes use compression (store only non-empty cells).
- **Materialised cubes** — all sub-aggregates pre-computed at load time.
- **Partitioning** — one logical cube spread across multiple physical cubes; allows parallel retrieval.

**Advantages:**
- Fastest query performance — multi-dimensional views directly mapped to array structures.
- Can easily store sub-aggregates; all calculations pre-generated at cube creation.

**Disadvantages:**
- High overhead of storage and pre-calculating (200MB input can expand to 5GB with calculations).
- **Not efficient for sparse data**.
- **Scalability problem** with larger numbers of dimensions (practical limit ~10 dimensions; dimension cardinality breakpoint ~64,000).
- Not adaptive for real-time OLAP — changing dimensions forces total rebuilding of MDDB.
- **No standard access method** (no SQL equivalent); vendors provide proprietary languages (e.g., MDX by Microsoft).
- Long pre-calculation time for large/distributed applications with more than ~5 dimensions.
- Cube technology is often proprietary.

> ⚠️ MOLAP has NO standard query language — ANSI SQL cannot be used. Microsoft's MDX is a proprietary example.

**When to use MOLAP:** analytic requirements need extended analytic/forecasting/planning functionality; lots of calculated and aggregated KPIs; need to define complex or proprietary calculations.

#### ROLAP (Relational OLAP)
Data stored in a **relational database** (e.g., using a star schema). The ROLAP server generates SQL queries from OLAP requests. The data cube is materialised as aggregation tables; multidimensional retrieval is implemented as table scans and relational joins.

**Why ROLAP?**
- **Scalability** — addresses the curse of dimensionality for MOLAP.
- Handles significantly larger dimension tables using secondary storage.
- **Aggregate awareness** — some front-end tools use pre-built summary tables.
- Star schema designs facilitate ROLAP querying.

**Optimisation techniques:** denormalisation, materialised views, partitioning, join optimisation, indexes, query processing.

**ROLAP Issues:**
- **Maintenance** — summary tables require maintenance similar to MOLAP; plan for ~2× the size of un-summarised data.
- **Non-standard hierarchies** — dimensions are not always simple hierarchies; cross-category groupings require additional summary tables.
- **Storage explosion** — brute-force approach to all summary table combinations overwhelms storage capacity.
- Smart tools address this: build summaries on-the-fly, enhance performance at coarser granularities, assist DBAs in selecting the best aggregations (speed vs space trade-off).

**Materialisation of Cuboids in ROLAP:** sorting, hashing, and grouping applied to dimension attributes; partial grouping steps speed computation of other sub-aggregates; aggregates may be computed from previously computed aggregates rather than from base fact table.

**Advantages:**
- Scalable with respect to number of dimensions and size of data.
- Sparsity is not a problem (fact tables contain only non-null facts).
- Mature and well-developed technology.

**Disadvantages:**
- Worse performance than MOLAP.
- Requires additional data structures and optimisation techniques.

**When to use ROLAP:** analytic requirements met by SQL capabilities; appropriate in-house SQL skills; relational engine provides satisfactory performance; detail data is very sparse.

#### HOLAP (Hybrid OLAP)
A tradeoff between MOLAP and ROLAP: combines the scalability of ROLAP with the fast computation of MOLAP.

**Storage:**
- Detailed data stored in RDBMS (like ROLAP).
- Aggregated data stored in multidimensional structure (like MOLAP).

**Partitioning:**
- **Vertical partitioning** — aggregations in MOLAP for fast query performance; detailed data in ROLAP to optimise cube processing/loading time.
- **Horizontal partitioning** — recent data (sliced by Time) in MOLAP for fast performance; older data in ROLAP.

**Summary:** HOLAP partitions are smaller than MOLAP (no source data copy), answer faster than ROLAP for summary queries, and fall back to relational for unaggregated detail (potentially cached in memory).

#### MOLAP vs ROLAP Comparison

| | MOLAP | ROLAP |
|---|---|---|
| Aggregation level | Requires high level; less useful without pre-aggregation | May be used at every level; depends on analysis requirements |
| Number of dimensions | Bounded (~10 practical max) | Fluid dimensionality |
| Atomic data size | Up to 10–20 GB | Even 100× bigger than 10–20 GB |
| Response time | Short | Longer; grows with complexity and data size |
| Typical application | Data marts | Data warehouses |

---

### SSAS Storage Modes (SQL Server Analysis Services)

| Mode | Facts copy? | Aggregations | Notes |
|---|---|---|---|
| **MOLAP** | Yes (~10–20% of source size) | Stored in multidimensional structure | Fastest queries; must reprocess when source updates |
| **ROLAP** | No | Stored as indexed views in relational source | Real-time data; slowest; saves storage for infrequently queried historical data |
| **HOLAP** | No | Stored in multidimensional structure; detail read from star schema | Best of both: fast summary queries, real-time detail access |

---

## Lecture 8 — Dimensional Model Details

### Grouping Dimension Attributes — Explicit vs Implicit Relationships

**Explicit relationships** between dimension attributes are expressed via joins that intersect in a fact table. The fact table provides important context for the relationship. Explicit relationships can be numerous and volatile (e.g., customer ↔ salesperson — linked only when transactions occur).

**Implicit relationships** occur when two attributes are located in the same dimension table, implying a natural affinity rather than a context-dependent relationship. They tend to be consistent and **browseable** (e.g., product ↔ brand).

**Key rule:**
- Attributes with a **natural affinity** (related in only one stable context, independent of transactions) → place in the **same dimension table**.
- Attributes whose **relationship depends on events/transactions** (can occur in multiple contexts) → place in **separate dimension tables**, linked only through the fact table.

**Examples:**
- Product & Brand — related prior to any transaction; product has a brand even without orders → **same dimension table**.
- Customer & Salesperson — brought together only when orders occur; multiple contexts possible → **separate dimensions** joined via fact table.

---

### Browsability Test
The browsability test evaluates whether two attributes should be in the same or separate dimensions by asking: *"Would someone want to browse the values of these attributes together?"*

- If placing them in **separate dimensions** would destroy the ability to study their relationship (e.g., you could only find a product's brand by finding an order for it) → they **belong together**.
- If the relationship only exists in the context of transactions (and is volatile) → they **belong in separate dimensions**.
- Special case: if a business assigns salespeople to specific customers (stable assignment), a factless fact table may be used to track the assignment, while keeping customer and salesperson as separate dimensions for other transactional contexts.

---

### Assigning Attributes to Dimensions — Summary Rule

| Relationship type | Design decision |
|---|---|
| Depends on context / event / transaction (e.g., student ↔ course) | Use fact table to capture the relationship |
| Natural affinity — independent of business activities (e.g., department code ↔ course number) | Place both attributes in the same dimension table |

---

### Breaking Up Large Dimensions
Dimension tables with 100+ attributes are common. Concerns arise from ETL complexity and database administration.

**Arbitrary separation** — split attributes into two tables with the same surrogate key (one-to-one). Drawbacks: more complex ETL, complex star joins, BI tools may not handle correctly, performance issues.

**Better alternatives:**

**Two distinct dimensions:** often a large dimension is actually two separate dimensions in disguise. Redesign as two tables, each with its own surrogate key.

**Outrigger (relocating free-form text to snowflake):** if excessive row length comes from free-form text fields (unstructured data used occasionally to filter), relocate them to a separate table and replace with a foreign key reference. This is the outrigger technique and results in a snowflake.

**Subtypes / Core + Custom:** when a dimension contains large groups of attributes that apply only to one subset of rows (subtyping), build a core dimension with shared attributes and separate custom dimensions for each subtype. E.g., Books, Magazines, and CDs share common attributes but each subtype has unique attributes.

**Mini-dimension:** when a large dimension contains rapidly changing attributes (e.g., demographic bands), extract those attributes into a separate smaller mini-dimension with its own surrogate key. The fact table then holds a foreign key to the mini-dimension.

---

### Dimension Table Best Practices

**Goal of dimension attribute design — all values should be:**
- **Verbose** — use full words; no cryptic abbreviations, true/false flags, or operational indicators without supplementary text.
- **Descriptive** — meaningful when independently viewed.
- **Complete** — no missing values; substitute with "Unknown" or "Not Applicable" instead of NULL.
- **Quality assured.**
- **Indexed** for the most heavily used attributes.
- **Documented** in metadata.

**Codes and Descriptions:** operational codes should be supplemented with corresponding description values in the dimension table. Descriptions are more useful than codes in queries and reports.

**Flags and Their Values:** Boolean flags (Y/N or 0/1) should be stored as descriptive text (e.g., "Yes"/"No" or "Active"/"Inactive") so they can be used unambiguously as query predicates.

**Multi-Part Columns:** if an operational attribute has multiple parts (e.g., region code `XX-YYY` where XX = country, YYY = territory), store the full code AND the decomposed parts as separate attributes. Also store descriptions for any sub-codes.

**Numeric Attributes as Dimensions:** not all numeric data is a measure. If a numeric attribute is used to filter, order, control aggregation, or drive master-detail relationships → it is a **dimension**. If it is commonly aggregated/summarised → it is a **fact**.
- Example: unit price of $10 — summing unit prices across orders is not useful; but grouping orders by unit price ("How many sold at $10 vs $12?") is useful → **unit price is a dimension**.

> ⚠️ Quiz trap: Numeric attributes are not automatically facts. The test is how they are used, not their data type.

**General goal:** surround facts with as much context (dimensions) as possible. Redundancy is acceptable in well-chosen places. Do NOT try to model all relationships in the data (unlike ER or OO modelling).

---

### Dimension Table — Surrogate Keys

**Why surrogate keys?** Natural keys from operational source systems are subject to business rules outside the DW's control. E.g., an employee number may change if the employee resigns and is rehired. The DW needs a single stable key.

**Durable supernatural key:** a persistent key that does not change. Best format: simple sequential integers starting with 1, independent of the original business process. While multiple surrogate keys may be associated with a dimension member over time (as its profile changes), the durable key never changes.

**Dimension table has two keys:**
1. **Natural key** — the original OLTP key (from data source).
2. **Surrogate key** — generated during ETL; anonymous integer; assigned in sequence.

The surrogate key enables including additional data sources later without risk of duplicate OLTP key values, and provides transparent, easy-to-report keys.

> ⚠️ Exception: the **Date dimension** is sometimes exempt from the surrogate key rule — it is highly predictable and stable, so a meaningful key (e.g., YYYYMMDD as integer) can be used as primary key.

---

### Fact Table Types

#### Transaction Fact Table
- Corresponds to a measurement of an event at a particular point in multidimensional space.
- Grain is typically the individual transaction (e.g., order line).
- Each row describes a specific event.
- ⚠️ Not always individual transactions — many real-world transaction fact tables summarise activities (e.g., aggregated orders by day, salesperson, customer, product) because detail is available elsewhere or transaction volume is too large.

#### Periodic Snapshot Fact Table
- Measures the effect of a series of transactions (**status measurements**).
- Samples the measurement at a predetermined interval — grain is the **period**, not the individual transaction.
- Examples: account balances, inventory levels.
- Dense: contains a row for each combination of period and relevant entity, even if no activity.
- Contains at least one **semi-additive** fact (cannot be summed over time).
- Status can sometimes be discerned by aggregating transactions, but sometimes cannot (e.g., account balance); the snapshot table directly records status.
- Grain declared in **dimensional terms** (e.g., "balance at end of each day").

#### Accumulating Snapshot Fact Table
- Describes business processes with a series of stages/steps/statuses that an entity passes through.
- Grain: one row per identifiable entity (e.g., one row per support ticket).
- Contains **multiple date foreign keys**, one for each critical milestone in the process.
- Updated as the entity moves through stages — the row is **revisited and updated**.
- Also stores **lags** — the number of days (or minutes) spent between milestones.
- Example: a support ticket is logged, assigned, diagnosed, and closed. The fact table has FK to date_logged, date_assigned, date_diagnosed, date_closed.

**Comparison of fact table types:**

| Type | Grain | Row created | Row updated? | Example |
|---|---|---|---|---|
| Transaction | Individual transaction or summary | Once per event | No | Order line |
| Periodic Snapshot | Period (day/week/month) | Periodically | No | Account balance at month end |
| Accumulating Snapshot | One per entity lifecycle | Once per entity | Yes, as milestones are reached | Support ticket progress |

> ⚠️ Accumulating snapshot rows are updated as the entity progresses — unlike the other two types which are append-only.

---

### Factless Fact Tables

A fact table with no numerical measures — captures the occurrence of an event or relationship.

**Event fact (factless fact per event):** a row for each event with foreign keys to relevant dimensions but no numeric measure. Example: a student attending a class on a given day — fact row with FKs for Day, Student, Teacher, Location, Class, but no numeric measure.

**Coverage fact (factless fact per relation):** records all *possible* combinations of events that might happen (coverage table), used alongside an activity table that records events that *did* happen. Enables analysis of **what didn't happen** (e.g., absence rate — students assigned to a class but who never attended).

---

### Conformed Facts
When the same measurement appears in separate fact tables, technical definitions must be identical for comparison. If definitions are consistent → **identically named**. If incompatible → **differently named** to alert users and BI applications.

---

### Consolidated Fact Tables
Combine facts from multiple processes into a single fact table when they can be expressed at the same grain. Example: sales actuals + sales forecasts consolidated for easy actuals-vs-forecasts analysis. Increases ETL burden but simplifies BI analysis. Best for cross-process metrics that are frequently analysed together.

---

### Nulls in Fact Tables
- NULL-valued measures behave gracefully — aggregate functions (SUM, COUNT, MIN, MAX, AVG) handle NULLs correctly.
- ⚠️ NULLs **must be avoided in foreign keys** (dimension references) in the fact table — they cause referential integrity violations. Instead, the associated dimension table must have a **default row** (and surrogate key) representing "Unknown" or "Not Applicable".

---

### Fact Table Keys

**Foreign keys:** every fact table row references surrogate keys from each dimension. These provide dimensional context.

**Primary key of fact table:**
- At logical level: composite of all foreign keys to dimensions.
- At physical level: some implementations add a single-column surrogate primary key to the fact table as well (for ETL processing, deduplication, and ETL logging). This is optional and transparent to BI tools.
- ⚠️ Do NOT use the primary/foreign keys from source databases in the fact table — use surrogate keys generated by the DW ETL.

---

### Aggregate Fact Tables
Numeric rollups of atomic fact table data, built solely to accelerate query performance. Should be available to the BI layer alongside atomic fact tables.

**Aggregate navigation:** the process by which BI tools automatically choose the appropriate aggregate level at query time. A properly designed set of aggregates behaves like database indexes — they accelerate performance but are not encountered directly by business users.

Aggregate fact tables contain foreign keys to **shrunken conformed dimensions** (higher-level versions of regular dimensions) and aggregated facts created by summing from more atomic fact tables.

---

### Types of Special Dimensions

#### Conformed Dimension
Used by multiple fact tables. Crucial for any DW architecture that includes a dimensional component.

**Three types of "conformed" dimensions:**

| Type | Description |
|---|---|
| **Identical (shared)** | Exactly the same dimension table shared across fact tables |
| **Conformed rollup (vertical sameness)** | One dimension is a subset of attributes from another (for roll-up at different grains). The smaller is the *conformed rollup*, the larger is the *base dimension*. Do not share a common surrogate key. |
| **Overlapping (horizontal sameness)** | Two tables share a set of common attributes but neither is a perfect subset of the other. Can improve performance. Risk of inconsistency if maintained by separate ETL processes. |

**Conformed dimension traps:**
- Same name, different meaning.
- Different time definitions (e.g., fiscal year vs calendar year).
- Same data, different organisation.
- Different keys.

**Conformance matrix:** a blueprint for implementation. Columns = core conforming dimensions; rows = processes or fact tables. Documents dimensional conformance across subject areas.

**Conformed dimensions and ETL:** a single ETL process should be responsible for updating a conformed dimension (update master first, then replicate to separate physical locations). This guarantees replicas are identical and accurate.

**Drill-across with conformed dimensions:**
1. Phase 1 — dimensions define a common level of aggregation for facts from each fact table.
2. Phase 2 — dimension values are used to merge results of the separate queries.

**Drill-across example:**
```
Sales fact: (Date, Customer, Product, Store)
CustomerSupport fact: (Date, Customer, Product, ServiceRep)
Question: How does support call frequency by California customers affect purchases of Product X?

Step 1: Query CustomerSupport → GROUP BY Customer SSN; Filter State=CA; COUNT
        → Result: (Customer SSN, SupportCallCount)
Step 2: Query Sales → Filter State=CA, Product=X; SUM(TotalSalesAmt)
        → Result: (Customer SSN, TotalSalesAmt)
Step 3: JOIN on Customer SSN → GROUP BY SupportCallCount → COUNT, AVG(TotalSalesAmt)
```

#### Junk Dimension (Abstract Dimension)
Used to handle miscellaneous low-cardinality flags and indicators from transactional business processes. Instead of creating separate dimensions for each flag/attribute, combine them into a **single junk dimension**.

- Surrogate keys required.
- Does NOT need to be the Cartesian product of all attribute values — only contains combinations that actually occur in source data.
- Can be prepared outside the ETL process.
- Best suited for attributes with a predefined set of static values.
- Too many attributes may require multiple junk dimensions (Kimball suggests fewer than 26 dimensions total).

**Traps:**
- Treating junk attributes as part of a larger, unrelated dimension.
- Treating the junk dimension as part of a fact table (inefficient).

#### Degenerate Dimension
A dimension stored **within the fact table itself** — no associated dimension table.
- High-cardinality (often nearly 1-to-1 with facts).
- Has no content except its primary key (no descriptive attributes worth putting in a separate table).
- Example: invoice number — after all line items inherit the invoice's dimension FKs, the invoice itself has no unique remaining content but its number remains a valid grouping/drilling key.
- Most common with transaction and accumulating snapshot fact tables.
- ⚠️ Degenerate dimensions should be included if they might serve as the basis for drilling across.

**How it differs from a junk dimension:** junk dimensions group multiple low-cardinality attributes from many sources; degenerate dimensions are high-cardinality keys that are logically dimensions but have no attributes.

#### Role-Playing Dimension
A single physical dimension referenced **multiple times** in a fact table, each reference linking to a logically distinct role.
- Each foreign key refers to a separate view of the same underlying dimension table.
- These separate dimension views are called **roles**.
- Example: a fact table can reference the Date dimension multiple times: `OrderDate`, `ShipDate`, `DueDate` — all FK to the same Date dimension but represent different roles.
- Implemented as separate **views** on the same underlying physical table.

#### Behavioral Dimension
Groups or filters facts based on the **past behaviour** of dimension members. Transforms facts into dimension attributes to enable analysis without complex queries.

- Example: customers generating over $1M in orders vs $500K or less → their past order behaviour becomes a dimension attribute.
- Technique: add columns to a dimension to track past behaviour (e.g., `CustomerValueTier`).
- Requires a two-step process: (1) identify past behaviour for each dimension member; (2) use as part of a query studying current behaviour.

---

### Core and Custom Star Schemas
Used for dimensions with subtypes (e.g., different product types with different attributes).

- **Core star:** includes all common attributes; supports analysis across all types.
- **Type-specific custom stars:** include all core attributes plus type-specific attributes.

Conformed dimensions enable drill-across between the core and custom stars.

---

### Dimensional Modelling — Additional Design Notes

**Resist normalisation urges.** Dimensional designers should denormalise many-to-one fixed-depth hierarchies into separate attributes on a flattened dimension row. Dimension denormalisation supports simplicity and speed.

**When to use Snowflake in dimension tables:**
- Attribute groups (e.g., registered vs unregistered users).
- Multiple hierarchies (e.g., customer → city → country; customer → gender → married).
- One table per level of a hierarchy.

**Fact table stability:** dimensional models accommodate adding new fact columns, new foreign keys, or new dimension attributes without changing existing queries.

---

## Lecture 9 — Slowly Changing Dimensions (SCD)

### Why SCDs Exist
Data warehouses derive power from historical data access. When dimension attributes change over time (customer moves, product gets renamed, employee changes department), the DW must handle the change **without destroying the ability to study history**. The collective techniques for doing this are called **Slowly Changing Dimensions (SCDs)**.

SCDs are dimensions that change not on a regular schedule but irregularly over time. Typical examples: customer, geography, employee.

---

### Retrospection Types (Conceptual)
Before choosing an SCD type, decide what "truth" the DW should record:

| Retrospection | Meaning |
|---|---|
| **Permanent** | Once set, always the same — value never changes |
| **Real** | New versions are separate records; history is preserved |
| **False** | New versions replace old; no access to previous values |

---

### SCD Type 0 — Passive (No Change)
- No action is taken when source data changes.
- Dimension value remains exactly as first inserted — **forever**.
- New rows can still be added, but existing attribute values never change.
- Appropriate for attributes labelled "original" (e.g., original credit score, most Date dimension attributes).

---

### SCD Type 1 — Overwrite
- Old value is **overwritten** with the new value. No history preserved.
- Always reflects the most recent assignment.
- Simple to implement; used for corrections (spelling errors, special character removal).
- ⚠️ Affected aggregate fact tables and OLAP cubes must be **recomputed** after a type 1 change.

```
Before:  ID=1, Name=Nowak, City=Wroclaw
After:   ID=1, Name=Nowak, City=Warsaw   ← overwritten
```

---

### SCD Type 2 — Add New Row (Full History)
- Tracks history by **inserting a new row** for each change; old row is retained.
- The natural key appears multiple times; **surrogate keys** distinguish versions.
- Fact table foreign keys point to specific surrogate keys, perfectly partitioning history.
- Unlimited history is preserved.
- ⚠️ Changing dimension data is **expensive** — requires inserting new rows and updating the prior row's end/current flags.
- ⚠️ The ETL process must also update the **surrogate key map table**.

```
Before:  ID=1, NID=1, Name=Nowak, City=Wroclaw
After:   ID=1, NID=1, Name=Nowak, City=Wroclaw  (old row)
         ID=2, NID=1, Name=Nowak, City=Warsaw    (new row)
```

#### Type 2 Variants

**Point-in-time status dimension:** each change produces a new version row; fact table and dimension have the same number of rows. Useful when every state change is itself a fact.

**Time-stamped dimension:** adds `start_date` and `end_date` (or `effective_date` + `expiration_date`) to each row. Current row typically gets `end_date = 9999-12-31`. A `current_indicator` (or `most_recent_version`) column simplifies filtering.

```
ID  NID  Name   City     Start     End
1   1    Nowak  Wroclaw  2014-10   2014-11
2   1    Nowak  Warsaw   2014-11   9999-12
```

---

### SCD Type 3 — Add New Column (Limited History)
- Tracks changes using **separate columns** in the same row — one for the current value, one for the prior (original) value.
- Only stores one or two versions; depth is limited to the number of columns added.
- Called an **alternate reality**: business users can analyse all facts using either the current or prior value.
- ⚠️ Does NOT preserve full history — each type 3 change **restates** history.
- Used infrequently; good when two views of reality must coexist (e.g., after a sales territory reorganisation).

```
Before:  ID=1, Name=Nowak, City=Wroclaw
After:   ID=1, Name=Nowak, originalCity=Wroclaw, Start=2014-11, currentCity=Warsaw
```

---

### SCD Type 4 — History Table (Mini-Dimension / Separate Table)
- Current data stays in the main dimension table (always current).
- All historical changes are stored in a **separate history table**.
- Useful when dimension attributes change **very rapidly** (too many rows for type 2 to be practical).
- A surrogate key is assigned to each unique profile in the added dimension; both the base key and the mini-dimension key appear as FK in the fact table.
- The added dimension is called a **mini-dimension** when it splits off a group of volatile attributes.

```
Main dim:    ID=1, Name=Nowak, City=Warsaw         (current)
History:     ID=1, Name=Nowak, City=Wroclaw, Start=2014-10
```

---

### SCD Type 5 — Mini-Dimension + Type 1 Outrigger (1 + 4)
- Builds on Type 4 by **embedding** a "current profile" mini-dimension key in the base dimension, overwritten as a **Type 1** attribute.
- Allows fact rows to be grouped by either the historic mini-dimension key (from the fact table FK) or the current profile (via the outrigger in the base dimension) without extra joins.
- ETL must overwrite the type 1 mini-dimension reference whenever the current profile changes.
- In the presentation layer, the base dimension and current outrigger are typically exposed as a single view.

---

### SCD Type 6 — Combined (1 + 2 + 3 = 6)
- Combines types 1, 2, and 3 in a single row.
- Creates new rows like type 2 (preserving history), but also adds a `current_value` column (type 1, overwritten on all historical rows) and a `historical_value` column (type 3, retains the value at that version's time).
- Allows filtering by both the **historic value** (what was true then) and the **current value** (what is true now), from any row.

```
ID  Name   Current_City  History_City  Start     End       Current
1   Nowak  Warsaw        Wroclaw       2014-10   2014-11   N
2   Nowak  Warsaw        Warsaw        2014-11   9999-12   Y
```

Additional columns used: `current_type`, `historical_type`, `start_date`, `end_date`, `current_flag`.

---

### SCD Type 7 — Dual Type 1 and Type 2 (Dual Keys)
- Adds the **natural key** as an additional FK in the fact table alongside the surrogate key.
- The surrogate key FK enables type 2 (historical) analysis; the natural key FK, when joined to only the "current" row in the dimension, enables type 1 (current) analysis.
- Delivers the same functionality as type 6 but via **dual keys** rather than physically overwriting current attributes.

```
Fact table:  DIMID (surrogate FK for SCD 2), DIMNID (natural key FK for SCD 1)
```

---

### SCD Comparison Table

| Type | Mechanism | History preserved | Complexity |
|---|---|---|---|
| 0 | No change | N/A (original stays) | Minimal |
| 1 | Overwrite | ❌ None | Low |
| 2 | New row | ✅ Unlimited | High |
| 3 | New column | ⚠️ One prior value | Medium |
| 4 | History table | ✅ Separate table | Medium-High |
| 5 | 1 + 4 (outrigger) | ✅ + current access | High |
| 6 | 1 + 2 + 3 | ✅ + current column | Very High |
| 7 | Dual keys | ✅ via surrogate + current via NK | High |

> ⚠️ Quiz trap: Type 6 = 1+2+3 (not 6 as a separate idea). Type 5 = 1+4. Type 7 achieves the same result as Type 6 but using dual keys instead of overwriting columns.

---

### Permanent Dimensions (Static / No SCD needed)
Some dimensions never change during DW usage — treated as **permanent**:
- Populated once (before ETL starts), outside the ETL process.
- No new data, no changes during operation.
- Examples: Date dimension (all dates from 1990–2100, mostly calculated), static lookup/dictionary tables (e.g., Country, Currency).

---

### Fast-Changing Dimensions
When attributes change extremely rapidly (e.g., lighting mode in a room changing multiple times per day), Type 2 generates too many rows. Solutions:
- **Mini-dimension (Type 4):** split the volatile attributes into a separate dimension with all possible value combinations; reference from the fact table.
- **New fact table:** if the changing attribute is numerical (e.g., monthly doctor ratings), create a separate fact table with conformed Date and entity dimensions.
- Both approaches can be combined.

---

## Lecture 10 — Dimensional Design

### DW Design Approaches

| Approach | Description | Pros | Cons |
|---|---|---|---|
| **Top-down (Inmon)** | Start with enterprise-wide normalised DW, then build data marts | Single integrated truth | Slow delivery, high upfront cost |
| **Bottom-up (Kimball)** | Build dimensional data marts first, integrate via conformed dimensions | Fast delivery, business-aligned | Risk of silos if conformance is neglected |
| **Hybrid** | Core normalised DW for critical areas + simultaneous dimensional marts; uses ODS and data vaults | Balances speed and integration | More architectural complexity, requires strict governance |

**Supply-driven vs Demand-driven:**
- **Supply-driven** — start from existing source systems, identify available facts/dimensions → easier ETL but may load unused data; users struggle with unfamiliar data models.
- **Demand-driven** — start from business requirements; model is built for user needs then mapped to sources → better fit but users often cannot fully specify requirements, risking omissions.
- **Goal-driven** — business requirements provide the guiding question (e.g., "dynamic business growth" — but what does it mean exactly?); hints are extracted before modelling begins.

> ⚠️ Quiz trap: the demand-driven approach does NOT mean you ignore source data — you must balance user requirements AND source data realities simultaneously.

---

### DW Design Key Elements
1. Understand the domain and business goals.
2. Identify relevant data sources.
3. Define the destination (target) schema.
4. Create the DW design schema.
5. Plan the ETL process.
6. Choose appropriate hardware, software, and tools.
7. Deploy and maintain the warehouse.
8. Manage data quality and performance over time.

**Complete requirements set:** Business requirements (goals, processes, rules/metrics) · BI functional requirements (use cases, workflows, analytical styles) · Data requirements (sources, conformance, quality, integration) · Regulatory/compliance requirements · Technical requirements (infrastructure, technology direction).

---

### Dimensional vs ER Modelling

| | ER Model | Dimensional Model |
|---|---|---|
| Target system | OLTP | DW/BI |
| Goal | Consistency, non-redundancy, storage efficiency | Intuitive for business users, analytical query performance |
| Technique | Removes redundancy, expresses microscopic relationships | Captures critical measures, views along dimensions |
| Structure | Normalised entities | Star/snowflake schemas |

**Modifying the corporate ER model for DW use:**
- Remove pure operational data.
- Add element of time to keys.
- Add derived data where appropriate.
- Create artefacts of relationships.

---

### Four Steps of Dimensional Modelling (Kimball)

**Step 1 — Choose the Business Process**
Select the operational activity to model (e.g., sales, insurance claims, student registration). Business processes are action verbs, generate measurable performance metrics, and are usually supported by an operational system. Prioritise: high impact + low risk (data quality, complexity, access).

**Step 2 — Choose the Grain**
The grain defines exactly what a single fact table row represents. It must be declared **before** choosing dimensions or facts — it is a binding contract on the design. Grain must be expressed in business terms, not just as a list of keys.
- Examples: "one row per bar-code scan at cash register," "one row per line item on a bill," "one row per bank account per month."
- Always aim for **atomic grain** (lowest level of captured detail) — it withstands unpredictable queries; rolled-up summary tables presuppose common questions.
- ⚠️ Different grains must NOT be mixed in the same fact table.

**Step 3 — Choose the Dimensions**
Dimensions answer "who, what, where, when, why, and how" about each measurement event. Tips: the word "by" in a question is almost always followed by a dimension; so is "for." Each chosen dimension should have a full set of descriptive text attributes that flesh it out.

**Step 4 — Define the Measures**
Measures are the numeric performance metrics the business wants to analyse at various levels of detail. Elements that are aggregated/summarised/subtotalled are measures. All measures must be true to the chosen grain.

> ⚠️ Not everything numeric is a measure. If a numeric element specifies context (e.g., order number, phone number, unit price) rather than being rolled up, it is a dimension attribute.

**How to distinguish facts from dimensions:**
- Can it be specified at varying levels of detail (rolled up/down)? → **Fact**
- Does it provide context (filter, grouping, sort)? → **Dimension**

---

### Conceptual Modelling Techniques

#### Dot Modelling (Corr & Stagnitto)
A lightweight conceptual method built on three components:
- **Dot** — represents facts (usually numeric, atomic or complex).
- **Dimension names** — arranged around the dot; hierarchical structure shown with arrows.
- **Connectors** — link facts to first-level dimensions and dimensions to groupings.

Worksheets produced: data model worksheet (diagram + fact attributes) · entities worksheet (dimension name, retrospection type, change frequency) · attributes worksheet (name, retrospection, frequency, dependency, metadata, source, transformations, data type) · fact usage worksheet (which dimensions connect to which facts, aggregation methods) · hierarchies/groupings worksheet (internal attribute relations within dimensions).

**Retrospection types** for entities/attributes:
- **Permanent** — once set, always the same (SCD Type 0).
- **Real** — new versions are kept as separate rows (SCD Type 2).
- **False** — new versions replace old ones, no access to previous values (SCD Type 1).

#### Dimensional Fact Model (DFM)
A conceptual modelling approach specifically for DW/BI. Visualised as tree-structured **fact schemas**: central fact connected to dimension hierarchies.

Special attribute types:
- **Descriptive attribute** — adds information but not used for aggregation (e.g., telephone number, weight); always a leaf in the hierarchy; shown with horizontal underscore.
- **Optional attribute** — defined only for a subset of entities (e.g., diet attribute for food products only); marked with dashed line.
- **Shared hierarchy** — part of a hierarchy replicated two or more times in the fact schema.
- **Cross-dimensional attribute** — value depends on a combination of two or more dimension attributes from different hierarchies (e.g., VAT rate determined by both Product Category and Country); shown with circular arcs.

Naming rules: all attributes and measures must have unique names (qualify with dimension name if needed, e.g., `storeCity` vs `brandCity`); avoid names that explicitly reference the fact; attributes with the same meaning across fact schemas must share the same name.

#### StarER
Combines the star schema structure with semantically rich ER constructs; adds special relationship types for hierarchies.

#### ME/R (Multidimensional E/R)
Specialisation of ER with two extra sets of relations and a specialised set of entities to represent multidimensional OLAP data; separates defining/descriptive and quantitative data.

---

### Requirements Gathering for Dimensional Design

Three approaches to gathering requirements:
- **Closed room** — modellers work alone with little business involvement (generally discouraged).
- **Interviews** — one-on-one with business representatives; excellent for in-depth individual input.
- **Facilitated sessions** — multiple business areas interact with each other; differences surface and are resolved collaboratively.

Sources to consult: company overview and goals · executive/management interviews (high-level) · worker interviews (financial, marketing, planning) · existing reports and queries.

Traps with existing reports: risk of repeating old mistakes, creating only a "better version" of existing solution, or simply moving operational reports into the DW.

Data element selection groups: definitely needed · definitely not needed · might be needed (requires decision).

---

## Lecture 12 — DW Architecture & Data Flows

### Data Flows in the DW
Five directional flows:
- **Inflow** — extraction, cleansing, and loading from source systems into the DW.
- **Upflow** — adding value by summarising, packaging, and distributing data.
- **Downflow** — archiving and backing up data in the warehouse.
- **Outflow** — making data available to end-users.
- **Meta-flow** — managing metadata throughout the system.

---

### Metadata
**Metadata = data about data.** It is the backbone of a well-managed DW: enables data discovery, governance, integration, BI, and operations.

**Taxonomy of metadata:**
| Type | Layer | Contents |
|---|---|---|
| Business | Semantic | Business glossary, KPI logic, ownership |
| Technical | Structural | Schemas, data lineage, transformation logic |
| Operational | Runtime | Job statistics, quality scores, usage patterns |

**Additional cut (Administrative / Business / Usage / Operational):** overlapping categorisation focused on technical characteristics, business context, access patterns, and runtime behaviour respectively.

**The "5 W's" of Metadata:**
- **Who** — data creators, owners (Data Stewards), users.
- **What** — entity definition, format, business meaning.
- **When** — creation date, update frequency (SLA), last access.
- **Where** — physical location (cloud bucket, DB cluster), origin (source system).
- **Why** — business justification and intended use (compliance, marketing, etc.).

**Metadata-Driven Pipelines:** instead of custom code per table, generic templates read metadata (table name, source URL, data types) and dynamically generate ingestion code.

**Data Lineage & Impact Analysis:**
- *Upstream lineage* — "Where did this number come from?" (debugging).
- *Downstream impact* — "If I change column X, which 50 reports will break?" (change management).

---

### SSoT and SVoT

**Single Source of Truth (SSoT):** every data element is mastered (stored and edited) in exactly one place. Any reference to it elsewhere is by reference only; updates propagate from the primary location. Prevents duplication and redundancy. Not a technology — a state of the architecture.

**Single Version of Truth (SVoT):** everyone in the organisation agrees on one view of data as the real, trusted number. Focuses on the *business/semantic* layer — how data is defined, calculated, and presented to decision-makers.

> ⚠️ **Classic trap:** VP Sales reports $10M revenue; VP Finance reports $8.5M — both from the same table. They have an SSoT but lack SVoT (different semantic definitions of "Revenue").

**Where each is realised:**
- **SSoT** → Staging Area, ODS, or raw/normalised EDW layer (3NF or Data Vault). Driven by ETL/ELT + MDM.
- **SVoT** → Semantic Layer, Data Marts, OLAP Cubes, Metrics Stores (e.g., dbt, Looker LookML). Driven by metadata management and standardised business rules.

---

### Master Data Management (MDM)
MDM is a comprehensive approach using technology, tools, and processes to create a **unified master data service** consolidating key enterprise data assets (customers, products, suppliers, locations).

**Three core data types:**
- **Master Data** — core nouns (Customers, Products, Suppliers, Employees, Locations). Persistent, non-transactional.
- **Transactional Data** — verbs (Invoices, Sales Orders, Log entries). Time-bound events.
- **Reference Data** — static/semi-static lookup values (Currency codes, Country codes, Order status).

**Foundational MDM assumptions:** data silos are inevitable (best-of-breed apps); same entity exists in multiple systems under different formats; data decays over time; governance is foundational (technology alone cannot fix quality).

**MDM architectural patterns:**

| Pattern | Description |
|---|---|
| Registry | Hub stores cross-reference keys only; master data stays in source systems |
| Consolidation | Data pulled to central hub; cleansed, deduplicated → Golden Record |
| Coexistence | Consolidation + feedback loop back to source systems |
| Centralised (Repository) | All master data created, updated, and stored only in the hub |

**Operational MDM** — supports day-to-day operations consistency.  
**Analytical MDM** — supports BI and analytics by standardising master data for reporting.

**MDM and the DW:** MDM feeds conformed dimensions, simplifies ETL/ELT (deduplication handled upstream), and enables clean SCD handling by tracking master data lineage.

> MDM creates the **SSoT** (one authoritative row per real-world entity). Data Governance then transforms that SSoT into **SVoT** by defining how master data is aggregated and reported.

---

### DW Architectures: Inmon vs Kimball

| Aspect | Inmon (Top-Down) | Kimball (Bottom-Up) |
|---|---|---|
| Starting point | Corporate data model (normalised 3NF EDW) | Business processes → dimensional data marts |
| Data model | Normalised (3NF); data marts denormalised later | Star schemas, not normalised |
| Approach | EDW → department data marts | Data marts → (virtual) enterprise DW |
| Single source of truth | Enforced in centralised EDW | Achieved via conformed dimensions |
| Setup time | Longer; more specialists needed | Faster; smaller team |
| Flexibility to change | High (one place per concept) | Lower (star schemas harder to change) |
| Key risk | Complexity, cost, long delivery | Data update anomalies; redundant data; loses true SSOT |

> ⚠️ These are **not opposing definitions** — Kimball's DW should satisfy all of Inmon's characteristics. Inmon's definition is a subset; Kimball's covers the process/architecture.

Famous exchange: Kimball (1997) — "the DW is nothing more than the union of all the data marts." Inmon (1998) — "You can catch all the minnows in the ocean and stack them together and they still do not make a whale."

---

### Data Vault

**Motivation:** Kimball star schemas break when new sources arrive (different definitions, attributes, relationships) — rebuilding dimensions is expensive. Data Vault solves this by ensuring adding a new source never breaks what already exists.

**Data Vault is a hybrid:** combines best features of 3NF and star schema → normalised, history-trackable, detail-oriented tables. Designed by Dan Linstedt (2000).

**Three building blocks (Lego model):**

| Component | Answers | Contains | Notes |
|---|---|---|---|
| **Hub** | WHO / WHAT? | Unique Business Key only (hash key, load date, record source) | Hard reference point; never changes |
| **Link** | RELATIONSHIP / EVENT? | Foreign hash keys to two or more Hubs + load date | Separates relationships from entities; new relationships → new Link rows only |
| **Satellite** | CONTEXT / DESCRIPTION? | Descriptive attributes + load date (SCD Type 2 on steroids) | Attached to Hub or Link; multiple satellites per Hub possible (one per source) |

**Data Vault 2.0** standardised the original spec: hash key generation rules, loading procedures, architectural patterns. Based on three pillars: modelling, architecture, methodology.

**Raw Vault vs Business Vault:**
- **Raw Vault** — 1:1 copy from source; no transformations, no business rules.
- **Business Vault** — cleansing, integration, business rules, standardisation, calculations.

**Modern layered use:**

| Layer | Name | Model |
|---|---|---|
| Raw (Bronze) | Raw Vault | 1:1 copy, no transformations |
| Integration (Silver/EDW) | Business Vault | Data Vault — cleanse, integrate, maintain history |
| Presentation (Gold/Marts) | Star Schema | Kimball — generated (virtually/physically) for BI tools |

**Best suited for:** dynamic environments, large volumes, heterogeneous sources, organisations needing to track changes over time and scale flexibly.

---

### DW Component Types

| Component | Description |
|---|---|
| **Enterprise DW (EDW)** | Single centralised DB; all subjects across the organisation; detailed + summarised data; 100 GB – TB+ |
| **Data Mart** | Single-subject or single-LOB subset; < 100 GB; weeks to implement |
| **Independent Data Mart** | Standalone, not enterprise-context; own ETL; no SSOT; BYOD silos |
| **Dependent Data Mart** | Sourced from EDW; maintains SSOT; BI queries from mart |
| **Virtual Warehouse** | Views over operational DBs; no historical data; no centralised metadata; impacts OLTP performance |
| **ODS** | Snapshot of latest data from multiple transactional systems; near real-time; low granularity; not historical |
| **Data Virtualization** | Abstraction layer over diverse sources; data stays in place; common interface |
| **Data Federation** | Unified view of multiple autonomous data stores (subset of virtualization) |

**Data Mart vs Data Warehouse:**

| | DW | Data Mart |
|---|---|---|
| Scope | Enterprise-wide | Single LOB / subject |
| Sources | Many internal & external | Few |
| Size | 100 GB – TB+ | < 100 GB |
| Life | Long, flexible | Short, project-oriented |
| Implementation | Months to years | Weeks to months |

**ODS vs MDM:** ODS = real-time integration of current operational data (no deep history, application-specific). MDM = authoritative master records with governance and data stewardship.

---

### Five Predominant DW Architectures

| Architecture | Description | Key trait |
|---|---|---|
| **Centralised (EDW)** | Single ETL, single presentation thread, one DW | Simplest architecture; very complex to build |
| **Independent Data Mart** | Mini-warehouses; separate ETL per mart; multiple silos | Fast, cheap, but no SSOT; inconsistent definitions |
| **Dependent Data Mart (Hub-and-Spoke)** | EDW feeds data marts; single ETL; SSOT maintained | Best practice; balances integration and usability |
| **Data Mart Bus (Kimball DBA)** | Conformed dimensions; virtual hub via ETL staging; no physical EDW | Logical integration without physical DW |
| **Federated** | Multiple regional DWs + global DW; upward (aggregated) and downward (consistency) federation | Distributed enterprises; preserves legacy systems |

> ⚠️ Hybrid architectures are possible. Hub-and-spoke became the predominant best practice because it provides a *physical* data hub rather than a difficult-to-achieve virtual one.

**Tier architectures:**

| Tier | Description |
|---|---|
| **Single-Tier** | BI connects directly to OLTP; no ETL; real-time but huge performance risk |
| **Two-Tier** | Physical DW separate from sources; better scalability; potential latency |
| **Three-Tier** | Bottom (sources + staging) · Middle (DW + data marts) · Top (BI/query tools); most common EDW type |

---

### Modernisation

**Key drivers:** Big Data (petabyte scale), cloud computing (elastic, pay-as-you-go), data science/ML (near real-time analytics).

**Modern Data Warehouse core layers:**
1. **Ingestion (ELT over ETL)** — raw data loaded first, transformed in-place.
2. **Storage** — cloud object storage + open table formats (decoupled from compute).
3. **Compute** — MPP engines (Redshift, BigQuery, Snowflake); scales independently of storage.
4. **Transformation/Modelling** — dbt and similar tools.
5. **Orchestration** — dependency-aware schedulers (Airflow, etc.).
6. **Governance/Observability/Metadata** — GDPR/CCPA compliance, data quality monitoring.
7. **Consumption** — BI tools, Semantic/Metrics Store, Reverse ETL, AI/LLM/RAG pipelines.

**Lambda Architecture:** two paths — *hot path* (real-time / latency-sensitive) and *cold path* (batch, higher latency). Processing logic duplicated across both.

**Kappa Architecture:** simplifies Lambda by eliminating the cold path — all data flows through a single stream-processing node; recomputation replays data through the same pipeline.

**MPP (Massively Parallel Processing):** distributes processing across nodes; shared-nothing architecture; columnar storage; in-memory processing; sophisticated query optimisation.

---

### Data Lake, Lakehouse & Medallion Architecture

**Data Lake** (Dixon, 2010): large store of raw data in its natural state (structured, semi-structured, unstructured). No schema at write time → **schema-on-read**. Can serve as source for DWs after cleaning.

**4-Zone Data Lake:**
- **Transition zone** — ephemeral/streaming copies.
- **Unprocessed (Raw) zone** — raw data; sensitive data encrypted/tokenised.
- **Trusted zone** — quality-verified data; becomes SSOT for downstream systems.
- **Enhanced zone** — manipulated/enriched output data.

**Medallion (Bronze / Silver / Gold):**
| Layer | Contents |
|---|---|
| **Bronze** | Raw as-is from sources; may contain errors, duplicates |
| **Silver** | Cleaned, matched, merged, conformed; 3NF models; enterprise view |
| **Gold** | Analytical-ready; denormalised, read-optimised; star schema or similar |

**Lakehouse:** adds DW-style reliability (ACID transactions, schema validation, indexing, metadata-at-scale) on top of a data lake. Uses Apache Spark for metadata management. Prevents data obsolescence; supports batch and streaming; reduces vendor lock-in via open formats.

**Data Mesh:** decentralised; data treated as a product; domain-oriented teams own their pipelines and governance. Four principles: domain-driven ownership, data-as-a-product, self-serve infrastructure, federated computational governance.

**Cloud-Based Three-Tier:** Data Layer (distributed storage + MPP DB) → Semantics Layer (OLAP/OLTP restructuring) → Analytics Layer (BI tools: Tableau, Power BI, Looker). Features: elastic scaling, pay-as-you-go, built-in sharing, automated maintenance.

---

## Lecture 13 — Physical Aspects of OLAP

### Physical Design Overview
**Physical design** = the phase after logical design that translates dimensional/logical models into concrete DB structures (tables, indexes, storage layouts). Goal: adequate **query response time** and operational efficiency.

Three primary techniques:
| Technique | What it does |
|---|---|
| **Materialized Views** | Pre-stores results of expensive joins/aggregations; trades storage for speed |
| **Indexing** | Bitmap & join indexes tailored for low-cardinality DW columns |
| **Partitioning / Fragmentation** | Splits tables into sub-files (vertical or horizontal) for faster scans |

---

### Materialized Views
A **materialized view** is a view physically stored in the DB — the pre-computed result of a query (joins, aggregations). "Materialized" means the result exists on disk and is read directly instead of being recomputed.

**Speedup:** can be 100×–1000× faster than querying base data. Multiple queries can share the same materialized view. Must be **transparent** to end users — the OLAP system decides when to use them.

**Four key problems:**
- **Selection** — which views to materialize? (NP-hard optimization problem)
- **Calculation** — efficient creation of the views
- **Update (View Maintenance)** — modifications to base tables must propagate into every view
- **Query Rewrite** — use materialized views even when they only partially answer a query

**Trade-off triangle:**
```
Query processing cost  ↔  View maintenance cost  ↔  Storage space
```
Goal: minimize total query response time + maintenance cost within storage/time constraints.

#### Materialization Options
| Option | Description |
|---|---|
| **Full materialization** | All cuboids pre-computed (full cube) — huge storage, best speed |
| **No materialization** | Only base cube stored — no overhead, slow queries |
| **Partial materialization** | Subset of cuboids selected (partial cube) — balanced hybrid |

⚠️ **Optimal selection is NP-hard** — reduced to the set-cover problem. Must use heuristics.

#### Partial Cube Selection Heuristics
- **Greedy Lattice-Based Selection (HRU Algorithm):** iteratively pick the cuboid with the highest benefit-to-cost ratio.
- **Iceberg Cube:** store only cells whose aggregate value exceeds a minimum support threshold (Apriori pruning: if a cell fails, all its descendants also fail → prune).
- **Shell Cube / Shell Fragment:** pre-compute only small subsets of dimensions (3–5); retain inverted indices mapping attribute values to tuple IDs.
- **Workload-Directed / Query-Directed:** use historical query patterns to guide selection.
- Genetic algorithms and MVPP (Multiple View Processing Plans) heuristics also used.

#### Materialization Optimization Techniques
1. **Sorting, hashing, grouping** — group cells sharing same dimension values; shared-sorts / shared-partitions across cuboids.
2. **Simultaneous aggregation + caching intermediates** — compute higher-level aggregates from cached lower-level ones; amortized scans compute multiple cuboids per disk read.
3. **Aggregate from smallest child** — when multiple child cuboids exist, derive the parent from the smallest one.
4. **Apriori pruning** — prune iceberg cube cells: if count(cell) < min_support, all descendants also fail.

**Cube computation algorithms:**
| Approach | Example Algorithm |
|---|---|
| Bottom-up | Multi-Way Array Aggregation (Zhao et al., SIGMOD'97) |
| Top-down | BUC (Beyer & Ramakrishnan, SIGMOD'99); H-Cubing (Han et al., SIGMOD'01) |
| Hybrid | Star-Cubing (Xin et al., VLDB'03) |
| High-dimensional | Minimal Cubing (Li et al., VLDB'04) |

**Cost model components:** Query processing cost + Maintenance cost + Storage cost. Storage effectiveness η = benefit ÷ storage consumed (higher = better candidate).

---

### Indexing in Data Warehouses
Because DW queries scan huge numbers of rows, standard B-tree indexes are insufficient.

| Index Type | Description |
|---|---|
| **Bitmap Index** | One bit per row per distinct value; ideal for **low-cardinality** columns (e.g., gender, region). Supports fast AND/OR bitwise operations across multiple columns. |
| **Bitslice Index** | Uses bitmaps to index value ranges (bit-slice of the value's binary representation). |
| **Join Index** | Pre-materializes a join between two tables as pairs of row IDs. In DW: links fact table rows to dimension rows. |
| **Star Index** | Join index between a fact table and each of its dimension tables. |
| **Bitmap Join Index** | Combines join index with bitmap encoding — pre-computed join results stored as bitmaps. |
| Other | Aggregate index, summary index, hybrid B-tree/bitmap. |

---

### Partitioning / Fragmentation
Divides a relation into multiple physical files for more efficient processing.

| Type | Description | DW use |
|---|---|---|
| **Vertical** | Splits columns into groups (frequently-used vs. rarely-used) | Basis of columnar storage |
| **Horizontal** | Splits rows by a criterion (e.g., time ranges) | Most common: **time-based partitioning** (one partition per year/month) |

---

### Columnar Storage
A **column-store database** stores all values of a column contiguously on disk (vertical partitioning).

- **Why it matters for DW:** OLAP queries scan many rows but touch only a few columns. Column storage avoids reading irrelevant columns entirely.
- **Compression:** columns hold homogeneous data → much better compression ratios than row stores.
- **I/O reduction:** each data block holds ~3× more column values than row-based storage → ~2/3 fewer I/O operations.
- Has become the backbone of modern data warehousing (e.g., Redshift, BigQuery, Snowflake).

⚠️ **Exam trap:** columnar storage = vertical partitioning applied systematically across all columns. It is NOT about partitioning rows.

---

# PART 4 — DATA INTEGRATION, REPORTING & VISUALISATION

## Lecture 9 — Logical Data Map & ETL Design

### Logical Data Map
A **logical data map** documents the relationship between original source fields and final destination fields in the DW target tables. It ties the very beginning of the ETL system to the very end — source systems to dimensional schema.

> "You must have a blueprint before you hit the first nail." Without a logical data map, the physical ETL implementation is likely to be a catastrophe.

The logical data map is usually presented as a **table or spreadsheet** with three sections:

| Section | Contains |
|---|---|
| **Target** | Table name, column name, data type, table type (Fact/Dim), SCD type |
| **Source** | Database name, table name, column name, data type |
| **Transformation** | Exact SQL or logic needed to convert source to target (e.g., surrogate key generation, joins, decodes, NULL handling) |

**How to build it:** start with the **dimensional schema** (the target) and trace each column back to its source. Common problems to note: source systems often have no table called SALES or TIME — equivalent data may be scattered across ORDER + ORDER_STATUS, or embedded as DATE attributes in other tables.

---

### ETL Design — Logical Before Physical

Always complete logical design before any physical implementation. The process:

1. **Have a preliminary plan** — identify the overall approach and scope.
2. **Identify data source candidates** — starting from business objectives, identify candidate sources that support required decisions. Identify specific central data elements for profiling.
3. **Analyse source systems with data-profiling tools** — scrutinise data quality and completeness. Possible decision point: stop here if quality issues are too severe.
4. **Receive walk-through of data lineage and business rules** — two subcategories emerge:
   - Required data-cleaning alterations.
   - Coercions to achieve standard conformance across sources.
5. **Receive walk-through of the DW data model** — understand how dimensions, facts, and special tables work together.
6. **Validate calculations and formulas** — verify with end users; "measure twice, cut once."

**High-level ETL map:** a visual diagram connecting Sources → Transformations (Xforms) → Targets. Produced for both dimensions and facts separately. Shows joins, business rules, surrogate key pipelines, SCD handling, and row auditing metadata.

**Dimensional data structures** (the ETL target) sit at the boundary between back room (ETL) and front room (BI). They include: Fact tables, Dimension tables, and Surrogate key mapping tables.

---

## Lecture 10 (continued) — ETL Staging, Data Quality & Architecture

### ETL Staging

Transformed data is typically not loaded directly into the target DW — it first enters a **staging database**, making it easier to roll back, generate audit/compliance reports, and diagnose/repair data problems.

The back-room staging area stores data on its way to the final presentation area. Stage data at the four major checkpoints:
```
Extract → Clean → Conform → Deliver
```

Trade-off: speed (source to target as fast as possible) vs recoverability (ability to restart from a checkpoint rather than from the beginning).

**Staging area volumetric worksheet** — estimates space allocations and parameter settings for staging databases, file systems, and directory structures; focuses on the final delivery tables at the end of the ETL flow. Heterogeneous source systems may require a heterogeneous staging area.

**Integrity checking:** place integrity checks in the ETL process rather than in the staging database; ETL must handle data anomalies automatically using business rules for different quality scenarios, not simply reject all data. Unacceptable data goes to a reject file (semi-automatic).

---

### ETL Historic vs Incremental Load

**Historic load order:**
1. Start with permanent and user-defined dimensions.
2. Then Type-1 dimensions; then remaining dimensions.
3. Transformations: handle NULLs, decode production codes, conform data, handle M:M relations, apply surrogate keys.
4. Then load fact tables: handle NULLs, calculate derived measures, pipeline surrogate key lookups.

**Steps for loading into a partitioned fact table:**
1. Disable FK (referential integrity) constraints.
2. Drop or disable indexes on the fact table.
3. Load using fast-loading techniques.
4. Re-create/enable fact table indexes.
5. Stitch partitions if necessary.
6. Confirm unique index on surrogate key in each dimension.
7. Re-enable FK constraints.

**Incremental load** — must be fully automated (scheduling, exception/error handling, logging and audit). Process: identify new/changed dimension rows → apply SCD mechanism → surrogate key pipelines for facts → handle late-arriving facts. Additional challenges: maintaining aggregates, real-time delivery.

ETL specification must describe both historic load strategy and incremental load strategy for each target table (often separate ETL processes; occasionally the same code handles both).

---

### Data Architecture: SOR, SOI, SOA

| Acronym | Full name | Role |
|---|---|---|
| **SOR** | System of Record | Authoritative operational source; data is captured and updated here |
| **SOI** | System of Integration | Gathers, integrates, transforms SOR data into consistent, conformed, clean information |
| **SOA** | System of Analytics | Provides integrated BI-ready information to analytical applications |

> ⚠️ In early DW days, teams extracted all available SOR data "just in case." Now: extract only what current requirements need, plus closely related data — source systems are too large to dump wholesale.

---

### Data Quality in DW Projects

Common data quality problem areas:
- Quality within a SOR may be "masked" by manual corrections in existing reports/spreadsheets — users may not know adjustments exist.
- **Data does not age well** — historical data may have different business rules, different field meanings, or inconsistencies over time.
- Quality may be fine within each SOR individually but **inconsistent across SORs** (e.g., customer master data in multiple systems).

**Data profiling / gap analysis process:**
1. Profile source systems to assess current data quality and consistency.
2. Perform gap analysis: current state vs data requirements.
3. Determine corrective actions and review with the business.
4. Business options: accept current quality, change requirements, or take corrective action (assign a value to determine if it is a must-have).
5. Revise project plan/budget; get sign-off before proceeding.

If gaps exist, corrective actions may include: identifying new sources · defining data cleansing processes · defining MDM processes · creating new data capture applications · dropping the requirement temporarily.

---

### Single Source of Truth (SSOT) & Master Data Management (MDM)

**SSOT** — the practice of structuring information models and data schemas such that every data element is mastered (edited) in exactly one place. Requires an integration strategy and an interface that hosts and surfaces the organisation's data; all departments must grant data access.

**SVOT (Single Version of the Truth)** — a subtly different concept: "a commonly agreed and accepted set of truths that operate as a foundation, on which we will each derive our own, contextually interpreted views." You need one version of truth but can have multiple contextual views derived from it.

**MDM (Master Data Management)** — the set of processes to create and maintain a consistent view (master list) of key enterprise reference data: customers, suppliers, employees, products, services, assets, accounts, and their groupings/hierarchies. Used as part of the information architecture to create consistent, conformed reference data.

Example problem (illustrating why SSOT matters): "What is the close date for a purchase?" — DocuSign submission date? Salesforce closed-won date? Stripe billing date? Bank receipt date? Accounting recognition date? Each system gives a different answer.

---

## Lecture 1 (Intro) & 5 — BI Ecosystem

### SQL Server BI Ecosystem
- **SQL Server Database Engine** — storage.
- **SSIS (SQL Server Integration Services)** — ETL/integration.
- **SSAS (SQL Server Analysis Services)** — OLAP cubes.
- **SSRS (SQL Server Reporting Services)** — reporting.
- **Power BI** — modern visualisation/dashboards.

### Data Management & System Security
| Concept | Definition |
|---|---|
| Data lineage | Traceability of data through the system (crucial for audits) |
| Data quality | Automatic data quality testing in pipelines |
| Metadata management | Data dictionary — what does each column mean? |
| Security | GDPR, sensitive data masking, row-level security |

### DW Logical Architecture (Full Picture)
```
[OLTP Sources] → [ETL/Data Staging Area] → [Data Staging DB]
                                           ↓
                              [Data Organisation Area]
                              (DW / Data Marts / OLAP Cubes)
                                           ↓
                              [Data Access Area]
                   (Reports / Dashboards / Mining / Ad-hoc queries)
```

### Modern DW Trends
- **Cloud DW:** AWS Redshift, Google BigQuery, Azure Synapse, Snowflake.
- **SQL on Hadoop:** Apache Hive, Spark, Impala, Presto, Drill.
- **Data Lakes / Lakehouses:** Dremio, Kylo, CDP.
- **Virtualisation:** Denodo, Querona.
- **Real-time streaming:** ClickHouse, Apache Druid, Materialise.
- **HTAP:** TiDB, AlloyDB.

---

## Lecture 11 — ETL (Extract, Transform, Load)

> ⚠️ ETL consumes ~70% of all DW project resources (time, money, staff, compute). ~80% of development time is spent on ETL. It makes or breaks the DW.

### ETL Purpose & Definition

**ETL (Extract–Transform–Load):** A properly designed ETL system extracts data from source systems, enforces data quality and consistency standards, conforms data so that separate sources can be used together, and delivers data in a presentation-ready format (Kimball, 2004).

**Why ETL is needed:**
- Source systems are diverse, poorly documented, and dirty.
- Data is never perfect; the goal is to get as clean data as constraints allow.
- Multiple input sources must be merged, defaults supplied, and the process repeated (daily/weekly/monthly).

**Data quality problems in the real world:**
- **Incomplete** — missing attribute values (e.g., `occupation=""`).
- **Noisy** — errors or outliers (e.g., `Salary="-10"`).
- **Inconsistent** — discrepancies in codes or names across time or sources (e.g., `Age="42"` but `Birthday="03/07/1997"`).

---

### ETL vs ELT

**ETL (traditional):** Extract → Transform (in staging area) → Load into DW. Schema-on-write. Designed for limited compute/storage.

**ELT (modern):** Extract → Load (raw into DW/lake) → Transform (inside target platform using its own compute). Schema-on-read. Enabled by cloud MPP warehouses (e.g., Amazon Redshift, 2012).

| Feature | ETL | ELT |
|---|---|---|
| Transform location | Separate staging/ETL engine | Inside target data store |
| Data loaded | Cleaned, structured | Raw, untransformed |
| Flexibility for new uses | Lower (pre-defined transforms) | Higher (raw data re-transformable) |
| Data types | Best for structured | Structured + semi/unstructured |
| Schema | Schema-on-write | Schema-on-read |
| Speed to load | Slower (upfront transforms) | Faster initial load |

> ⚠️ In ELT, Extract and Load are done in one move; transformations are applied later on the target platform.

**Why companies pay for ELT tools:** engineer salaries are more expensive than software. Automating E and L lets engineers focus on data governance and modelling — the parts that provide business value.

**Reverse ETL:** Treats the DW as an operational data store, pushing insights back into source operational systems.

---

### Medallion / Data Zoning Architecture

| Zone | Name | Description |
|---|---|---|
| Bronze | Raw | Permanent record of source data; no transformations |
| Silver | Cleaned | Deduplicated, type-cast, standardised; ready for data science |
| Gold | Business | Star schemas and aggregations ready for BI tools |

---

### Batch vs Stream Processing

**Batch processing:** Newly arriving data is collected into a group and processed at a future time. Can use "microbatch."

**Stream processing:** Each new piece of data is processed immediately on arrival; no waiting for a batch interval.

**Pull model (source polling):** Target/orchestration tool actively requests data from the source. Typical use: scheduled batch ETL, API pagination.

**Push model (event-driven):** Source initiates transfer the moment an event occurs. Typical use: real-time streaming, webhooks, Change Data Capture (CDC).

> ⚠️ Pull ≠ Batch and Push ≠ Stream. Modern architectures mix them (e.g., source pushes events into Kafka; downstream pulls micro-batches from Kafka).

---

### Ingestion Patterns

| Pattern | Description |
|---|---|
| **Full Refresh** | TRUNCATE + bulk INSERT; simplest but most expensive |
| **Append-Only** | Only new records added; includes `ingested_at` timestamp; assumes no updates/deletes |
| **Upsert (Merge)** | SQL MERGE: update if key exists, insert if not |
| **SCD** | Type 1 (overwrite) or Type 2 (keep history with timestamps) |
| **Partitioned Ingestion** | Data stored in partitions (usually by date); overwrite/append to one partition only |

---

### ETL System Design: Two Threads

ETL system design runs two simultaneous threads: **Planning & Design** and **Data Flow**.

#### Planning & Design Thread

**Step 1 — Requirements & Realities:**
- Business needs (information content required for decisions).
- Data profiling (systematic examination of quality, scope, context of source data).
- Compliance requirements (archived copies, transaction flow proof, documented algorithms, security).
- Security requirements.
- Data integration (conforming dimensions, conforming facts/KPIs across sources).
- Data latency (how quickly data must reach end users; drives batch vs streaming choice).
- Archiving and lineage (stage data at each major transformation point; all staged data should be archived unless consciously decided otherwise).

> ⚠️ If data profiling reveals the source data is deeply flawed and cannot support business objectives — the DW effort should be cancelled.

**Step 2 — Architecture Decisions:**
- Hand-coded vs ETL vendor tool (tools reduce long-run cost and maintenance).
- Batch vs streaming data flow (switching changes everything).
- Horizontal vs vertical task dependency.
- Scheduler automation (from manual to fully automated master scheduler).
- Exception handling (uniform system-wide mechanism; every job writes to a central exception DB).
- Quality handling (common responses: fill missing text with `?`; least-biased estimators for corrupted numeric values; audit records attached to final data).
- Recovery and restart (ETL jobs must be idempotent — immune to incorrect double-execution).
- Metadata (~25% from DBMS tables, ~25% from cleaning step; biggest challenge is storing process-flow metadata).
- Security.

**Step 3 — System Implementation:** Hardware, software, coding practices, documentation.

**Step 4 — Test and Release:** Dev/test/production systems, handoff procedures, update propagation, snapshoting/rollback, performance tuning.

#### ETL System — Four Major Components

1. **Extracting** — gathering raw data from source systems into the ETL staging area.
2. **Cleaning and conforming** — improving data quality and merging sources to enforce conformed dimensions/metrics.
3. **Delivering** — physically structuring and loading data into presentation-layer dimensional models.
4. **Managing** — operating the ETL environment coherently (reliability, availability, manageability).

---

### Data Flow Thread: Extract → Clean → Conform → Deliver

#### Extract

**Goal:** Interface with source systems, discover data, detect anomalies, capture changes.

**Extraction approaches:**
- **Full extraction** — all data each cycle.
- **Incremental extraction** — only new/changed data since last cycle. Common technique: **High-Water Mark** (query records where `updated_at > max(updated_at)` in target). Cannot detect deletes.
- **Source-driven extraction** — source notifies ETL when data changes (CDC, webhooks).

**Change capture techniques:**
| Technique | Description |
|---|---|
| DB triggers | INSERT/UPDATE/DELETE triggers write to change tables |
| Change Data Capture (CDC) | Tails the WAL/Binlog (e.g., Debezium); records all changes |
| Partitioning | Extract only current partition (e.g., current week) |
| Before/After image | Compare before and after snapshots |
| Timestamp / Audit columns | Extract rows where `modified_at > last_load` |
| Delta file | Scan a pre-generated file of changes |
| Log file scraping | Scan transaction/audit logs |

**Online vs Offline extraction:**
- **Online (Direct):** Source writes to target or target reads from source. Security concerns; high coupling.
- **Offline (Files):** Transfer via scp/RFTS/ESB; better decoupling; bulk compressed transfer.

**Extraction intervals:** Periodic (daily/weekly during low-usage windows) or Continuous/Real-time. Can also be event-triggered (e.g., number of changes exceeds threshold).

**Data Discovery Phase (in ETL; in ELT this is part of T):**
- Collect and document source systems; determine system-of-record.
- Discover: unique identifiers/natural keys, declared vs actual data types, table relationships, cardinality.

**Anomaly Detection Phase:**
- Data anomaly = data that does not fit the domain of surrounding data.
- Categories: Column property enforcement · Structure enforcement · Data and value rule enforcement.
- Undetected anomalies before ETL is built are the leading cause of ETL deployment delays.

**Correcting data:**
- Automatically during ETL (e.g., address correction against reference table).
- Manually after ETL (ETL stores bad data in error log tables; flags invalid records).
- In source systems (best approach but slow and often infeasible).

---

#### Clean

**Goal:** Improve data quality — screen, fix, and document issues.

**Quality Screens** — diagnostic filters, each implementing one test:
- **Pass:** no side effects.
- **Fail:** record an error event in the **Error Event Schema** and either halt, send to suspense file, or tag and pass through.

**Three categories of screens:**
- **Column screens** — test individual column values (NULLs, out-of-range, wrong type, invalid values, string length, pattern mismatch).
- **Structure screens** — test relationships between columns (PK/FK referential integrity, hierarchical parent–child, postal address validity).
- **Business rule screens** — complex multi-table rules (e.g., if customer is preferred, overdraft limit ≥ $1000).

**Error Event Schema** — centralised dimensional schema recording every error event thrown by any quality screen:
- Error Event Fact table (time, severity score).
- Date, Batch Job, Screen dimension tables.
- Error Event Detail fact table (which table/record/field, error condition).

If fatal errors are found → orderly ETL shutdown. If none → processing continues.

**Audit dimension:** A special dimension assembled per fact table load, containing ETL metadata context for each fact row (useful when a perfect run is not feasible).

**Deduplication:** Dimension data often comes from multiple sources. Matching may require fuzzy criteria. **Survivorship** = combining matched records into one unified row by applying priority rules to select the best column value from each source.

**Handling missing data:** ignore tuple · manual fill · global constant · attribute mean · class mean · most probable value (Bayesian/decision tree).

**Handling noisy data:** binning (smooth by mean/median/boundaries) · clustering (remove outliers) · regression.

**Binning methods:**
- **Equal-width:** uniform interval size `W = (B–A)/N`; outliers distort.
- **Equal-depth:** equal number of samples per bin; handles skewed data better.

**Automatic data cleansing techniques:** statistical (mean/stddev/range) · pattern-based · clustering (Euclidean distance) · association rules · reference data (permissible value lists).

**Data quality definitions:**
- **Correct** — values truthfully describe their objects.
- **Unambiguous** — only one possible meaning.
- **Consistent** — constant notational convention.
- **Complete (Individual)** — all required values defined.
- **Complete (Aggregate)** — no records lost in the flow.

---

#### Conform

**Goal:** Integrate data from multiple sources into a unified, consistent form.

**Conform step includes:** Conforming business labels (dimensions) · Conforming business metrics (facts) · Standardisation · Deduplication · Internationalisation · Staging.

**Conforming dimensions:** aligning column content and naming across separate parts of the DW. Two dimensions are conformed only if they share at least one attribute with the same name and same contents.

**Typical techniques:**
- Date format standardisation (`dd/mm/yyyy`), name convention standardisation.
- Parsing text fields (split `"mgr Jan Kowalski"` → title, first name, last name).
- Dictionary-based lookup (postal codes, geographic names).
- Rationalization (decode `PHX323RFD110A4` → `Print paper, format A4`).
- Rule-based cleansing (replace gender → sex).
- Data mining-based cleansing.

**Conflicts and dirty data sources:**
- Different data types (account no. as string vs numeric).
- Different domains (gender: M/F, male/female, 1/0).
- Different date formats, field lengths, naming conventions.
- Semantic conflicts (same object, different logical level).
- Structural conflicts (same concept, different structure).

**Data reduction techniques:** Discretisation (divide continuous ranges into intervals) · Concept hierarchies (age → young/middle-aged/senior) · Normalisation.

---

#### Load (Deliver)

**Goal:** Write cleaned and conformed data into the final dimensional structures.

**Load steps also include:** integrity constraint checking, sorting, summarising, creating indexes.

**SCD:** The ETL architecture must implement SCD logic for dimension tables (as covered in Lecture 9/10).

**Surrogate key pipeline:**
- Surrogate key generator creates meaningless integer keys independently of the DB.
- The ETL tool (not DB triggers) should generate and maintain surrogate keys for performance and control.
- Never concatenate operational key + date/time stamp as a surrogate key.

**Handling special dimensions at load time:**
| Dimension | Approach |
|---|---|
| Date/Time | Permanent; generated once during initial ETL |
| Junk | Pre-build all valid combinations, or create new combinations on-the-fly |
| Role-playing | Use views/aliases; one physical table |
| Mini-dimension | Similar to junk dimension handling |
| Shrunken subset | Build from base dimension to assure conformance |
| Small static | Created entirely by ETL with no outside source |

**Load data issues:**
- Huge volumes; sequential loads take too long within overnight windows.
- Index and aggregate tables must be built at the right time.
- Must allow monitor/cancel/resume/restart.
- **Checkpoints** ensure restarts from last checkpoint without data integrity loss, not from the beginning.

**Data loading strategies trade-offs:**
- Data freshness ↑ ↔ update efficiency ↓.
- Always trade-offs in light of business goals (SLAs).

---

### Managing the ETL Environment

Three criteria the ETL system must continuously fulfil:
- **Reliability** — processes run consistently, to completion, on time.
- **Availability** — DW meets its Service Level Agreements (SLAs).
- **Manageability** — ETL processes evolve gracefully as the DW grows and changes.

**Key management components:**
- **Robust ETL scheduler** — aware of job dependencies; captures execution metadata; supports full automation and escalation alerts.
- **Backup, recovery, restart** — backs up intermediate staging data; enables restart after failure.
- Performance monitoring, security, compliance, metadata management.

---

## Lecture 14 — Data Visualisation

### What is Business Data Visualisation?
**Data visualisation** = creating a mental imagery representation of abstract data to communicate meaning. Business data is abstract, multidimensional, and structured — visualisation makes it directly comprehensible. Purpose: communication, analysis, and decision support.

**Why visualise?** 75% of learning/memory comes from ocular stimulation. Visualisation:
- Communicates (even hidden) meaning
- Enhances problem-solving
- Eases cognitive load
- Aids recall

**4 Ways to Show Results:**
| Format | Use |
|---|---|
| **Reports** | Detailed tabular / textual output |
| **Dashboards** | Visual overview of multiple KPIs simultaneously |
| **Infographics** | Graphical, story-oriented fast depiction |
| **Gauges** | Single KPI status indicators |

---

### Design Process: Message → Comparison → Chart

**Step 1 — Identify the message.** Be explicit about what point you want to make before choosing any visual.

**Step 2 — Identify the comparison type:**
| Comparison | Key Words | Example message |
|---|---|---|
| **Component** | share, %, accounted for | "Product A = 70% of May sales" |
| **Item** | rank, larger/smaller than | "Region C ranks last in productivity" |
| **Time Series** | change, grow, decline, fluctuate | "Sales have risen steadily since Jan" |
| **Frequency Distribution** | range, concentration, distribution | "Most sales were in the 1000–2000 range" |
| **Correlation** | related to, varies with | "Discount size does not correlate with units sold" |

**Step 3 — Select the chart form** (5 basic forms):
| Chart | Best for |
|---|---|
| **Pie chart** | Component comparison (≤6 slices; most important segment at 12 o'clock) |
| **Bar chart** | Item comparison (horizontal bars; arrange by rank for clarity) |
| **Column chart** | Time series with few values (≤7–8); gaps suggest fresh start |
| **Line chart** | Time series with many values; suggests flow/trend |
| **Dot / Scatter chart** | Correlation between two variables |

**Simplified methodology (90% of dashboards):**
- **Ranking** → column/bar chart
- **Dynamics (change over time)** → line or column chart
- **Structure (% of whole)** → pie / donut chart

**Visualisation Compass:** determine data type (ranking/dynamics/structure), then number of categories → compass points to optimal chart. ⚠️ If >50 categories, no chart will help.

---

### Visual Properties — SSCOPe
Modifying a selected graphic element via: **Shape, Size, Color, Orientation, Position, tExture**.

**Visual element types:**
- **Embedded visuals:** Conditional formatting (formatting on numbers/text by value/context), Sparklines (tiny embedded charts), Visual cues (icons)
- **Standalone visuals:** Charts, Illustrational diagrams, Infographics

---

### Chart Formatting — 5-Step Guide
1. **Which chart is best?** (bar > pie for comparisons; line > bar for trends)
2. **Use color to emphasize** — highlight only the key data point; grey out the rest
3. **Delete what you don't need** — remove grid lines, tick marks, clutter
4. **Directly label** — replace legends with labels on lines/bars
5. **Annotate** — add narrative context to explain patterns

**General tips:**
- Always include descriptive title + axis titles + labels
- Bar charts: always start y-axis at zero
- Line charts: zero baseline optional but no axis breaks
- Show ALL data including missing values
- Avoid 3D in 2D visualisations
- Make colors accessible (color-blind friendly)
- Maximize data-to-ink ratio; minimize chart junk

**Bar chart variations:** Deviation, Sliding, Range, Paired, Grouped, Subdivided
**Column chart variations:** Deviation, Range, Grouped, Subdivided, Step-column, Waterfall
**Line chart variations:** Grouped (multi-series), Surface, Subdivided surface
**Dot/Scatter variations:** Grouped dot, Bubble chart (3rd dimension = bubble size)

⚠️ **Bar vs. Histogram:** Bar chart = discrete/categorical (X-axis is discrete); Histogram = distribution of continuous data (X-axis is a continuous range, though discretised).

---

### Dashboard Design
**Dashboard** = comprehensive visual view of corporate performance from multiple business areas — measures, trends, exceptions — allowing executives to grasp the situation in seconds.

**Layout principles:**
- Most important data: top-left / top of screen
- Trends: middle section
- Granular details: bottom
- **Five-second rule:** all relevant data reachable within 5 seconds of load
- **Z-pattern reading:** eyes move top-left → top-right → diagonal → bottom-right
- **Magic number 7 (±2):** keep 7–9 widgets max per dashboard (short-term memory limit)

**Positioning rules:**
- Related data goes together (proximity principle)
- Same data type = same color across charts
- No scrolling (keep everything on one screen)
- Visual hierarchy: overview first, details below

**ACES framework for optimal dashboards:**
| Criterion | Meaning |
|---|---|
| **Accurate** | Viewers must trust the data; quality + comprehension + design |
| **Clear** | Fonts, colors, context (titles/axes/labels), layout patterns |
| **Empowering** | Drives regular use and actual decisions |
| **Succinct** | Minimal, focused — all information fits simultaneously on screen |

**3-30-300 rule:** 3 seconds for first impression, 30 seconds for overview, 300 seconds for details.

**KPIs:** select only KPIs that answer the primary question — not too many (dilutes insight), not too few (incomplete picture).

**Common dashboard mistakes:**
- No clear goal
- Too many KPIs
- Low-quality data
- Wrong chart type for data
- Too much information / clutter
- Inconsistent or inaccessible colors

⚠️ **Exam trap:** Dashboard effectiveness depends on accurate underlying data first — a beautiful dashboard with bad data is worse than no dashboard.

---

# EXTENSION GUIDE
*Add future lectures below using this template:*

```markdown
## Lecture N — <Title>

### Topic 1
...

### Topic 2
...
```

Lectures 9–14 have been added. Lecture 15 (MDX — marked "Not in exam") omitted.
Add the lectures to the associated part, do not append them at the end. If a lecture is in several parts, divide it into each part.