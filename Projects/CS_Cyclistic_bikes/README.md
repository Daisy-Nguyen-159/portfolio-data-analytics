# Cyclistic Business Case Study
### Behavior Analysis to Support Membership Conversion Strategy

![Dashboard Preview]([images/dashboard_preview.png](https://public.tableau.com/app/profile/duyen.nguyen.thi.xuan/viz/HowCasualRidersandMembersdifference/Dashboard2))

## Project Overview

This project was completed as part of the Google Data Analytics Professional Certificate Capstone.

The objective is to analyze Cyclistic's historical bike-share trip data to understand how **casual riders** and **annual members** use the service differently, then translate those insights into actionable business recommendations that support membership conversion.

Rather than focusing only on descriptive statistics, this project follows a complete analytics workflow—from business understanding and data preparation to visualization, dashboard development, and strategic recommendations.

---

# Business Task

**Business Question**

> **How do casual riders and annual members use Cyclistic differently, and how can these insights support membership conversion?**

---

# Project Workflow

This analysis follows the Google Data Analytics process.

```
Ask
   ↓
Prepare
   ↓
Process
   ↓
Analyze
   ↓
Share
   ↓
Act
```

### Ask

- Understand the business problem
- Identify stakeholders
- Define business objectives

### Prepare

- Collect Cyclistic historical trip data
- Verify data completeness
- Review data structure

### Process

- Clean missing values
- Remove invalid trips
- Create analysis-ready features
- Validate data quality

### Analyze

- Compare rider behaviors
- Generate summary tables
- Visualize behavioral differences

### Share

- Build an interactive Tableau dashboard
- Present findings through a business presentation

### Act

- Develop data-driven marketing recommendations
- Suggest future analytical directions

---

# Dataset

**Source**

Cyclistic Historical Trip Data

**Size**

- 5.68 million trips
- 12 months of historical ride data

Main tables created for analysis:

- Overall summary
- Ride count by weekday
- Ride count by hour
- Ride count by month
- Bike preference
- Top start stations

---

# Tools & Technologies

| Tool | Purpose |
|-------|----------|
| SQL | Data cleaning & aggregation |
| Python (Pandas) | Data manipulation |
| Matplotlib | Data visualization |
| Tableau Public | Interactive dashboard |
| Google Slides | Business presentation |
| GitHub | Portfolio |

---

# Feature Engineering

Three new variables were created before analysis.

### Ride Length

Trip duration calculated from:

```
ended_at − started_at
```

Used to compare travel behavior.

---

### Day of Week

Extracted from the ride start timestamp to identify weekday and weekend usage patterns.

---

### Distance (km)

Calculated using the Haversine formula.

This represents straight-line distance rather than actual cycling route distance.

---

# Dashboard

Interactive Tableau Dashboard

👉 **Tableau Public**

(Insert Tableau link)

The dashboard highlights:

- Ride frequency
- Ride duration
- Ride distance
- Riding patterns
- Seasonal demand
- Bike preference
- Geographic usage

---

# Key Findings

## 1. Members ride much more frequently

Annual members completed

**3.67 million rides**

compared with

**2.01 million**

by casual riders.

---

## 2. Casual riders spend more time per trip

Average ride duration

- Casual: **19.6 minutes**
- Member: **12.3 minutes**

Casual trips are approximately **59% longer**.

---

## 3. Ride distance is nearly identical

Average distance

- Member: **2.28 km**
- Casual: **2.23 km**

Despite longer ride durations, casual riders do not travel significantly farther.

---

## 4. Different riding purposes

Members show clear commuting patterns.

- Morning peak
- Evening peak
- Stable weekday usage

Casual riders exhibit recreational behavior.

- Weekend peaks
- Afternoon activity
- Tourist-oriented locations

---

## 5. Strong seasonality

Both groups ride more during spring and summer.

Casual ridership increases more dramatically, suggesting a strong opportunity for seasonal marketing campaigns.

---

# Business Recommendations

## 1. Launch seasonal membership campaigns

Launch promotional campaigns between **April and June** using limited-time discounts or free membership trials to convert casual riders before peak riding season.

---

## 2. Position membership for leisure riders

Highlight the convenience and long-term value of annual membership for riders who frequently take longer recreational trips.

---

## 3. Target recreational locations

Promote memberships at popular casual rider locations such as:

- Navy Pier
- Millennium Park
- DuSable Lake Shore Drive

using QR-code sign-ups and seasonal promotions.

---

## 4. Strengthen commuter positioning

Emphasize annual membership as the most cost-effective option for frequent commuting through unlimited rides and everyday convenience.

---

# Business Impact

This analysis demonstrates how behavioral analytics can support business decision-making.

Instead of treating all casual riders equally, Cyclistic can focus marketing efforts on riders who are:

- highly engaged
- more likely to convert
- active during peak leisure periods

This targeted strategy can improve marketing efficiency while increasing annual membership adoption.

---

# Future Work

Potential extensions include:

- Rider demographics
- Weather conditions
- Membership conversion history
- Marketing campaign exposure
- Customer retention analysis

These additional datasets would enable more advanced predictive and segmentation analyses.

---

# Repository Structure

```
Cyclistic-Business-Case-Study/

│
├── README.md
│
├── SQL/
│     analysis.sql
│
├── Python/
│     analysis.ipynb
│
├── Tableau/
│     dashboard.twbx
│
├── Presentation/
│     Cyclistic_Business_Case_Study.pdf
│
├── images/
│     dashboard_preview.png
│
└── data_summary/
      Overall_summary.csv
      summary_by_hour.csv
      summary_by_weekday.csv
      summary_by_month.csv
      biketype.csv
      summary_top_stations.csv
```

---

# Project Deliverables

- SQL analysis
- Python notebook
- Tableau dashboard
- Business presentation
- Executive summary
- Business recommendations

---

# Author

**Duyen Nguyen** (Daisy Nguyen)

Data Analyst Portfolio

LinkedIn: https://www.linkedin.com/in/duyen-nguyen-479731239/

GitHub: https://github.com/Daisy-Nguyen-159/portfolio-data-analytics/

Kaggle: https://www.kaggle.com/duyennguyenthixuan

Tableau Public: https://public.tableau.com/app/profile/duyen.nguyen.thi.xuan/viz/

