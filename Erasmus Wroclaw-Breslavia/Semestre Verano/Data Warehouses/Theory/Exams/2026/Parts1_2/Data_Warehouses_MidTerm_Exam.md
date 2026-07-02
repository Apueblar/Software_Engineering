# Data Warehouses — MidTerm Final Exam
**Date:** 13/05/2025

---

> **Scoring rules:**
> - Multiple choice: fully correct answer = 1p., one incorrect = 0.5p., more than one incorrect = 0p. *(Total: 10p.)*
> - Open questions: max 1.5p. each; if replaced with substitute question, max 1p. *(Total: 3p.)*
> - Passing score: more than 7p. from each part.

---

## PART I — Multiple Choice

**Q1. OLTP relates to? *(Mark 1 for true, 0 for false)***

- [A] On-line transform process required to prepare a DW
- [B] On-line data storage system connected to the Internet
- [C] Transactional system that collects business data
- [D] Processing of a huge number of concurrent transactions

---

**Q2. Analytical operations focus mainly on: *(Mark 1 for true, 0 for false)***

- [A] CRUD
- [B] Read operations
- [C] Very fast update of data
- [D] Detailed and up-to-date data

---

**Q3. SQL grouping operators: *(Mark 1 for true, 0 for false)***

- [A] Using grouping operator introduces additional NULL entries in the result set
- [B] N attributes in a group by rollup translate to N+1 grouping sets
- [C] Group by cube grouping defines all combinations of groupings for a given set of attributes
- [D] Grouping operators are used to replace multiple union'ed group by queries

---

**Q4. Query `SELECT Customer, Year(OrderDate) AVG(TotalSales) OVER (PARTITION BY Customer ORDER BY YEAR(OrderDate)) FROM Sales;` results in number of rows equal to: *(Mark 1 for true, 0 for false)***

- [A] Number of rows in the sales table
- [B] Unique Years in Sales table
- [C] Unique combination of customers and years in Sales table
- [D] Unique Customers in Sales table

---

**Q5. What makes analysis of operational data difficult? *(Mark 1 for true, 0 for false)***

- [A] High denormalization of source data structures
- [B] Different modelling requirements for source data
- [C] Inconsistent definitions of data in data sources
- [D] High stress on source data systems

---

**Q6. The result of the following query `SELECT Time, Product, AVG(Amount) FROM Sales GROUP BY ROLL UP ((Time, Product))` is identical to: *(Mark 1 for true, 0 for false)***

- [A] Union of 1 group by queries
- [B] Union of 3 group by queries
- [C] Union of 2 group by queries
- [D] We cannot replace it with unions

---

**Q7. Data profiling involves collecting information about – mark correct answers: *(Mark 1 for true, 0 for false)***

- [A] Data business rules
- [B] Data descriptive statistics like min/max values
- [C] Dimensional keys
- [D] Fact table keys

---

**Q8. What are the advantages of Update Driven Approach? *(Mark 1 for true, 0 for false)***

- [A] High efficiency in processing highly aggregated data
- [B] Offloading data processing to the design/maintenance stage
- [C] Limited data redundancy
- [D] Access to most current, up to date, data

---

**Q9. Mark situations, in which a query-driven approach should be used:**

- [A] Data is periodically removed from the source systems
- [B] Fresh data is required
- [C] High query performance is required
- [D] There is no direct connection to source systems

---

**Q10. When you need to calculate total sales and order counts, providing subtotals for each Territory Group (e.g., North America, Europe), subtotals for each specific Sales Territory within those groups, and a Grand Total, you can use:**

- [A] Group by rollup
- [B] Group by cube
- [C] Group by grouping sets
- [D] Several unions of group by queries

---

## PART II — Multiple Choice

**Q11. A cell in a base cuboid is uniquely identified by ...: *(Mark 1 for true, 0 for false)***

- [A] A single measure and all attributes from a single hierarchy
- [B] All measures and set of 'All' members from all dimensions
- [C] Set of 'All' members from all dimensions
- [D] A key attribute from each dimension

---

**Q12. A hierarchy in a dimensional model can be defined ...: *(Mark 1 for true, 0 for false)***

- [A] Between attributes of different dimensions
- [B] Between different measures
- [C] Between attributes from a single dimension with a self-join relation
- [D] Between dimension's attributes with a strict n:n relationship

---

**Q13. While analysing the sales process, we should definitively separate Brand and Product dimensions in a case when:**

- [A] Brand and Product can only be studied in the context of a fact
- [B] Brand and Product need to be browsable
- [C] Different Brands produce the same Products
- [D] Each Product has a uniquely assigned Brand

---

**Q14. In a star schema? *(Mark 1 for true, 0 for false)***

- [A] A fact table is not directly connected to at least one dimension table
- [B] Multiple fact tables are directly connected to each other forming a star
- [C] A fact table is directly connected to each dimension table
- [D] Multiple fact tables are connected through dimension tables to each other forming a star

---

**Q15. In a minimal schema to cover a simple request of analysing daily and hourly number of passing by sedan and SUV vehicles in different intersections we need *(do not count surrogate keys)*: *(Mark 1 for true, 0 for false)***

- [A] Fact table with 1 measure
- [B] Snowflake schema with 5 dimensions
- [C] Fact table with 2 measures
- [D] Star schema with 3 dimension tables

---

**Q16. While analysing the sales process, we should definitively separate Brand and Product dimensions in a case when:**

- [A] Brand and Product can only be studied in the context of a fact
- [B] Brand and Product need to be browsable
- [C] Different Brands produce the same Products
- [D] Each Product has a uniquely assigned Brand

---

**Q17. Consider an example of an airline booking system — mark what could be a fact in this reality:**

- [A] Start airport
- [B] Ticket price without tax
- [C] Issue of a ticket
- [D] Time of take-off

---

**Q18. To cover a simple request of analysing monthly sales amount and quantity for apples, bananas, and pears in different branches of a certain (single) shop franchise we need *(do not count id's as attributes)*: *(Mark 1 for true, 0 for false)***

- [A] Star or snowflake schema with 3 dimensions
- [B] Star schema with 5 dimensions
- [C] At least one dimension with 3 attributes
- [D] Fact table with a single measure and 3 foreign keys

---

**Q19. A simple multidimensional model to cope with a basic user need — "Report the monthly number and value of apples and oranges sold in different shops" — requires *(do not count id's as attributes)*: *(Mark 1 for true, 0 for false)***

- [A] Fact tables with 1 measure
- [B] Fact table with 2 measures
- [C] Fact table with 3 foreign keys
- [D] Fact table with 3 measures

---

**Q20. Assume a simple schema (See diagram), what are the requirements for such a schema:**

- [A] There is only a single context, in which a Product relates to a Brand
- [B] There is a natural affinity between a Brand and a Product
- [C] Only existence of a transaction defines a relation between a Brand and a Product
- [D] Brand and Product are browseable

> *(Refer to the schema diagram: tables — Order, Calendar, Brand, Product, ProductCategory, Customer, Employee, OrderStatus)*

---

## Open Questions — Part I

### Part I – 1 *(1.5p.)*
**Specify what is the difference and what is needed to be able to use ROWS and RANGE in a window clause — briefly justify your answer.**

*(Answer space)*

---

### Part I – 2 *(1.5p.)*
**Justify why an OLAP layer is needed in a Business Intelligence system — briefly justify your answer.**

*(Answer space)*

---

> **NOTE — Part I substitute (max 1p.):** You may replace one of the above open questions with the following:
> *Briefly describe what are the key distinctions between measures and dimension attributes?*
> If replacing, cross out the original question.

---

## Open Questions — Part II

### Part II – 1 *(1.5p.)*
**Assuming a simple schema (See diagram), where would you introduce information representing customer's exact age at the time of transaction — briefly justify your answer.**

*(Answer space)*

---

### Part II – 2 *(1.5p.)*
**Name fact types for the given examples of facts (example measures in brackets):**

| Example | Measure | Fact Type |
|---|---|---|
| Sales order line | line total value | |
| Support ticket handling | time to refund | |
| Monthly account balance | balance amount | |
| Football match summary | number of yellow cards in a game | |
| Hourly traffic at a junction | number of cars passing by | |

---

> **NOTE — Part II substitute (max 1p.):** You may replace one of the above open questions with the following:
> *Briefly describe how would you modify the simple schema (See diagram) to include information about an employee being associated with a particular Supplier (an employee can be associated with multiple suppliers)?*
> If replacing, cross out the original question.
