## Part I – Multiple Choice Questions
*(Mark 1 for true, 0 for false — unless otherwise stated)*

---

**9. A hierarchy in a dimensional model can be defined:**

- [A] Between attributes of different dimensions
- [B] Between different measures
- *[C] Between attributes from a single dimension with a self-join relation
- [D] Between dimension's attributes with a strict n:n relationship

---

**10. In a snowflake schema?**

- *[A] A fact table is not directly connected to at least one dimension table
- [B] Multiple fact tables are directly connected to each other forming
- [C] A fact table is directly connected to each dimension table
- [D] Multiple fact tables are connected through dimension tables to each other

---

**11. Snowflake schema is typically used when:**

- [A] Higher data redundancy in dimensional table is not an issue/problem
- [B] Fact table consists of multiple parallel hierarchies – to separate them
- *[C] Dimension table contains a certain group of attributes which values are often missing – to separate them
- *[D] Dimension table has multiple levels (with multiple attributes each) in a hierarchy – to separate them

---

**12. In a minimal schema to cover a simple request of analysing daily and hourly number of passing by sedan and SUV vehicles in different intersections we need *(do not count surrogate keys)*:**

- *[A] Fact table with 1 measure
- [B] Snowflake schema with 5 dimensions
- [C] Fact table with 2 measures
- *[D] Star schema with 3 dimension tables

---

**14. Degenerate dimension – mark correct answers:**

- [A] Is used for attributes with low cardinality
- *[B] Is directly stored in a fact table
- [C] Requires a new dimension table
- *[D] Is used for attributes with high cardinality

---

**15. Assume you are to design a data warehouse that uses data from two source systems: A and B. In system A length is represented in [cm], whilst in system B in [mm]. The user is interested in analysing information using both scales. How would you handle this situation:**

- [A] Keep original values – as there is only single version of truth
- [B] Keep representation of values from system B in [mm], and transform values from system A
- [C] Keep representation of values from system A in [cm], and transform values from system B
- *[D] Create two attributes: one in [cm] and one in [mm]

---

**16. Dimensional design – the dimensional model should follow:**

- [A] Solely the existing operational data model
- *[B] The corporate data model and only consider the operational data model
- [C] The existing operational model and only consider the corporate data
- [D] It's a new model – shouldn't follow operational nor corporate models

---

**17. ROLAP architecture:**

- *[A] Is preferred for wide and deep data cubes
- [B] Stores aggregated values using array-based storage structures
- *[C] Uses relational DBMSes to store and manage data
- [D] Not tailored towards sparse cubes

---

**18. Degenerate dimension:**

- [A] Is best suited for attributes with a predefined set of low-cardinality attributes (like flags)
- [B] Can be prepared outside of the ETL process
- [C] Should be avoided and attributes should be treated as a part of larger dimensions
- *[D] Should be stored inside of the fact table

---

**19. While analysing the sales process, we should definitively separate Customer and Salesperson dimensions in a case when:**

- *[A] Customer and Salesperson can only be studied in the context of a fact
- [B] Customer and Salesperson need to be browseable
- *[C] Order is handled by multiple sales representatives (one for invoicing, one for shipping, etc.)
- [D] Customer has a uniquely assigned sales representative

---

**20. Consider an example of a hotel room booking system – mark what could be a fact in this reality:**

- [A] Hotel location
- [B] Room price without tax
- *[C] Making a booking
- [D] Time of check-out

---

**21. In SCD Type 2:**

- [A] Changes are tracked using separate columns in dimension table and allow preserving limited history
- *[B] Surrogate keys are required to properly handle this SCD type
- [C] On change, overwrites old values with new values
- *[D] Tracks historical data by creating multiple versions of a record in the dimension table

---

**22. User requirement is to analyse sales data based on product's rating (evaluated yearly, not important how) in the past 3 years, to compare the performance of sales together using different ratings (last year, two years ago, and so on). We should use:**

- [A] SCD Type 0 for attributes representing rating
- [B] SCD Type 1 for attributes representing rating
- [C] SCD Type 2 for attributes representing rating
- *[D] SCD Type 3 for attributes representing rating

---

**23. Incremental load in a data warehouse requires:**

- [A] Ability to create data warehouse structures
- *[B] Ability to identify data elements which have changed
- [C] Ability to identify new dimensions and measures
- *[D] Ability to identify data elements which are new

---

**24. Partial cube materialization characterises in/requires:**

- [A] Physical storage of each cell in each cuboid
- *[B] Additional mechanisms for cuboid selection
- [C] Best ETL performance
- [D] The least amount of storage needed

---

**25. Two dimensions fall into the same dimension table:**

- *[A] If they are only related in one context
- *[B] If they share a natural affinity
- [C] If they are related in multiple contexts
- [D] When relationships between them is determined by facts

---

**26. Assuming that all attributes of a Location dimension are handled by a SCD 0:**

- [A] All old values are replaced by new ones
- *[B] It can be loaded outside of the ETL process
- [C] On refresh all changes in the dimension values need to be handled
- [D] Location dimension cannot be handled by SCD 0

---

**27. To cover a simple request of analysing monthly sales amount and quantity for apples, bananas, and pears in different branches of a certain shop franchise we need *(do not count id's as attributes)*:**

- [A] Star schema with 5 dimensions
- [B] Snowflake schema with 4 dimensions
- *[C] Star or snowflake schema with 3 dimensions
- [D] Fact table with a single measure and 3 foreign keys

---

**28. A simple multidimensional model to cope with a basic user need – "Report the monthly number and value of apples and oranges sold in different shops" – requires *(do not count id's as attributes)*:**

- [A] Fact table with 1 measure
- *[B] Fact table with 2 measures
- *[C] Fact table with 3 foreign keys
- [D] Fact table with 3 measures

---

> **See diagram below for questions 30–32.**
>
> **Schema diagram (simplified description):**
> - **Calendar:** DateID (int), Date (date), DayOfMonth (int), DayOfWeek (int)
> - **OrderStatus:** OrderStatusID (int), StatusName (string)
> - **Order (Fact):** OrderID (int), OrderTimeID (int), ShipTimeID (int), OrderStatusID (int), CustomerID (int), ProductID (int), BrandID (int), EmployeeID (int), TotalAmount (money)
> - **Customer:** CustomerID (int), Name (string), Address1 (string), Address2 (string), Address3 (string)
> - **Brand:** BrandID (int), BrandName (varchar 100), BrandType (varchar 10)
> - **Employee:** EmployeeID (int), EmployeeName (varchar 50), EmployeeType (varchar 10)
> - **Supplier:** SupplierID (int), SupplierName (varchar 200), SupplierType (varchar 100)
> - **Product:** ProductID (int), ProductName (varchar 200), ProductPrice (money), ProductSupplierID (int)
>
> Relationships: 1 Supplier → \* Products | 1 Product → \* Orders | 1 Employee → \* Orders

---

**30. Assume a simple schema (See diagram), what are the requirements for such a schema:**

- *[A] There is only a single context in which a Product relates to a Supplier
- *[B] There is a natural affinity between a Supplier and a Product
- [C] Only existence of a transaction defines a relation between a Supplier and a Product
- *[D] Supplier and Product are browseable

---

**31. Mark sentences which are true for Kimball's approach:**

- *[A] Focuses around the notion of conformed dimensions
- [B] Utilises normalized model for enterprise data warehouse
- *[C] Focuses on multidimensional model for the data warehouse
- [D] Focuses on top-down approach – from data warehouse to data marts

---

**32. Assume a simple schema (See diagram), where there are 1M orders, 10 different BrandNames and 2 different BrandTypes:**

- *[A] Bitmap index for BrandType has 10 bits.
- *[B] Bitmap join index for BrandType is 2 binary vectors with 1M bits each.
- [C] Bitmap join index for BrandType has 10 bits.
- [D] Bitmap index for BrandType is 10 binary vectors with 2 bits each.

---

## Part II – Open Questions

---

**Open Question 1 (2p.)**
What are the key distinctions between measures and dimensions attributes? – briefly justify your answer.

---

**Open Question 2 (2p.)**
Assuming a simple schema (See diagram), how would you modify this schema to include information about an employee being associated with a particular Supplier *(an employee can be associated with multiple suppliers)*? – briefly justify your answer.

---

**Open Question 3 (2p.)**
Assume a simple schema (See diagram above), how would you handle a situation (within an ETL process) in which an order is missing employee details (no employee information is available)? – briefly justify your answer.

---

**Open Question 4 (2p.)**
Name fact types for the given examples of facts *(example measures in brackets)*:

| Example | Fact Type |
|---------|-----------|
| Student's class attendance *(no measures)* | |
| Support ticket handling *(time to refund)* | |
| Monthly account balance *(balance amount)* | |
| Football match summary *(number of yellow cards in a game)* | |
| Hourly traffic at a junction *(number of cars passing by)* | |
