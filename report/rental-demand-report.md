# Rental Demand Analysis & Automated Genre Reporting

## Overview

This project analyzes movie rental demand by store location and genre using PostgreSQL. The workflow was designed to simulate a lightweight business intelligence reporting pipeline capable of supporting recurring operational reporting.

The project combines:
- relational database design
- SQL transformations
- automated summary reporting
- triggers and stored procedures
- operational business analysis

The goal of the analysis was to identify which genres generated the highest rental activity at each store location in order to support inventory and purchasing decisions.

---

## Business Question

Which movie genres generate the highest rental demand at each store location?

Understanding rental demand by location can help businesses:
- optimize inventory allocation
- anticipate demand for upcoming releases
- identify changing customer preferences over time
- improve purchasing strategy

---

## Data Sources

The analysis combines data from multiple relational tables:

| Table | Purpose |
|---|---|
| rental | Individual rental transactions |
| inventory | Inventory and store location information |
| film | Film titles and identifiers |
| film_category | Relationship between films and genres |
| category | Genre/category names |

---

## Data Transformation

Rental timestamps were transformed into separate month and year fields using custom PL/pgSQL functions.

These transformations improve:
- reporting readability
- grouping and filtering capabilities
- future time-series analysis

Functions created:
- `get_rental_month()`
- `get_rental_year()`

---

## Reporting Workflow

### Detail Reporting Table

A detailed reporting table was created containing:
- rental ID
- rental date
- rental month and year
- inventory ID
- store location
- film title
- genre information

This structure supports drill-down analysis and serves as the foundation for summary reporting.

---

### Summary Reporting Table

A summary reporting table was created to aggregate rental demand by:
- store location
- movie genre

This allows quick identification of high-performing genres by store.

Example business questions supported:
- Which genres perform best at each location?
- Which genres may require increased inventory allocation?
- How do customer preferences differ between stores?

---

## Automation & Database Engineering

To simulate a production-style reporting workflow, the project includes automation features using PL/pgSQL.

### Trigger-Based Refresh Logic

A database trigger automatically refreshes the summary reporting table whenever new records are inserted into the detail table.

This ensures reporting metrics remain synchronized with transactional data.

---

### Monthly Refresh Procedure

A stored procedure named `refresh_monthly_genre_report()` was created to:
- rebuild reporting tables
- refresh transformed data
- regenerate aggregated metrics

This process supports recurring monthly reporting workflows.

---

## SQL Concepts Demonstrated

This project demonstrates:
- relational database design
- SQL joins
- aggregation and grouping
- PL/pgSQL functions
- stored procedures
- database triggers
- automated reporting workflows
- operational reporting structures

---

## Example Query

```sql
SELECT
    store_id,
    genre,
    COUNT(*) AS rental_count
FROM rental_genre_detail
GROUP BY store_id, genre
ORDER BY store_id, rental_count DESC;
```

---

## Future Improvements

Potential future enhancements include:
- Tableau or Power BI dashboards
- trend analysis over time
- inventory forecasting
- seasonal demand analysis
- performance optimization with indexing
- scheduled automation using PGAgent

---

## Technical Stack

| Technology | Purpose |
|---|---|
| PostgreSQL | Relational database management |
| SQL | Querying and aggregation |
| PL/pgSQL | Functions, procedures, and triggers |
| PGAdmin | Database management |

---

## Repository Contents

```text
rental-demand-analysis/
├── rental_genre_reporting_pipeline.sql
├── README.md
└── report/
    └── rental-demand-report.md
```

---

## Key Takeaway

This project demonstrates how SQL can be used not only for querying data, but also for building reusable operational reporting workflows that support recurring business analysis and automation.
