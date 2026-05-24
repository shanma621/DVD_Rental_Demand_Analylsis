# Rental Demand Analysis & Automated Genre Reporting

PostgreSQL reporting workflow analyzing movie rental demand by store location and genre.

---

## Project Overview

This project was designed to analyze rental demand patterns across store locations using PostgreSQL. The workflow combines relational database design, SQL transformations, summary reporting, triggers, and stored procedures to simulate a lightweight business intelligence reporting pipeline.

The analysis identifies which movie genres generate the highest rental demand at each store location to support inventory planning and operational decision-making.

---

## Features

- Multi-table relational joins
- PL/pgSQL transformation functions
- Detail and summary reporting tables
- Trigger-based summary refresh automation
- Stored procedures for recurring report generation
- Aggregation and grouping logic
- Operational reporting workflow design

---

## Technologies Used

- PostgreSQL
- SQL
- PL/pgSQL
- PGAdmin

---

## Repository Structure

```text
DVD_Rental_Demand_Analysis/
├── rental_genre_reporting_pipeline.sql
├── README.md
└── report/
    └── rental-demand-report.md
```

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
- Power BI or Tableau dashboards
- trend analysis over time
- inventory forecasting
- scheduled automation with PGAgent
- performance optimization with indexing

---

## Author

Shanna Siebert

Data analytics student focused on SQL, reporting automation, business intelligence, and operational analytics.
