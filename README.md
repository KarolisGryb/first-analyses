About
===
The aim of each analysis is to gather actionable insights using various tools and methods. Multiple real-world datasets are used. Data wrangling is performed using SQL. For privacy reasons display of some information will be omitted.

Projects are in reverse-chronological order.

Marketing Analysis
===
Data used is a single parsed events table which contains various frontend actions done on ecommerce site. Data in the table contains records from 2020-11-01 until 2021-01-31.

Schema
---
![](https://github.com/KarolisGryb/first-analyses/blob/main/marketing_files/schema.png)

SQL query to extract data
---
https://github.com/KarolisGryb/first-analyses/blob/7cb8acd386952011add0be2e7ae9ed8ba41fd668/marketing_files/query.sql#L1-L165

Single row of extracted data
---
Weekday duration:

|  channel |  weekday | avg_duration  |  sess_count |
| ------------ | ------------ | ------------ | ------------ |
| (direct)  | 3 | 164  | 5405  |

Purchases by session number:

| sess_no  |  user_type | conversions  |  avg_purchase | count  |
| ------------ | ------------ | ------------ | ------------ | ------------ |
| 1  |  (organic) | 938  | 66  | 85829  |

Daily metrics:

| day  | avg_duration  |  avg_clicks | conversions  | avg_purchase | bounce_count  |  user_count |
| ------------ | ------------ | ------------ | ------------ | ------------ | ------------ | ------------ |
|  2020-11-01 |  147 |  9 |  13 | 59  | 382  |  2365 |

Presentation of analysis
---
![](https://github.com/KarolisGryb/first-analyses/blob/main/marketing_files/present_file1.png)

![](https://github.com/KarolisGryb/first-analyses/blob/main/marketing_files/present_file2.png)


Product Analysis
===
Focus of this analysis will be users interaction by time.

Data used is a single parsed events table which contains various frontend actions done on ecommerce site. Data in the table contains records from 2020-11-01 until 2021-01-31.

Schema
---
![](https://github.com/KarolisGryb/first-analyses/blob/main/product_files/schema.png)

SQL queries to extract data
---
https://github.com/KarolisGryb/first-analyses/blob/330640219c1a70b2a2b91e857d48963493e3f347/product_files/duration_dynamic.sql#L1-L50

https://github.com/KarolisGryb/first-analyses/blob/330640219c1a70b2a2b91e857d48963493e3f347/product_files/event_time.sql#L1-L43

https://github.com/KarolisGryb/first-analyses/blob/330640219c1a70b2a2b91e857d48963493e3f347/product_files/purchase_timeline.sql#L1-L41

Single row of extracted data
---
Duration dynamic daily:

| date  |  category |  operating_system |  browser | country  |  language | duration_secs  |
| ------------ | ------------ | ------------ | ------------ | ------------ | ------------ | ------------ |
| 2020-11-01  | mobile  | Android  | Chrome  |  United States |  en-gb |  1039 |

Time spent on events:

|  event_name |  avg_time_spent |  avg_stdev |
| ------------ | ------------ | ------------ |
|  view_item_list | 51  | 192  |

Purchase timeline:

| duration_with_purchase  |
| ------------ |
| 1039  |

Exploratory analysis of duration to do a z-test
---
The Z-test will be used to determine if differences in duration are statistically significant between various categories. For example devices.

Checking if data is normally distributed to perform the test

![](https://github.com/KarolisGryb/first-analyses/blob/main/product_files/distribution_raw.png)

Q-Q plot for better visibility

![](https://github.com/KarolisGryb/first-analyses/blob/main/product_files/qq_plot_raw.png)

After data transformation

![](https://github.com/KarolisGryb/first-analyses/blob/main/product_files/qq_plot_transformed.png)

Presentation of analysis
---
![](https://github.com/KarolisGryb/first-analyses/blob/main/product_files/presentation1.png)

![](https://github.com/KarolisGryb/first-analyses/blob/main/product_files/presentation2.png)

![](https://github.com/KarolisGryb/first-analyses/blob/main/product_files/presentation3.png)






