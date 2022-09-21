## About
The aim of each analysis is to gather actionable insights using various tools and methods. Multiple real-world datasets are used. Data wrangling is performed using SQL. For privacy reasons display of some information is omitted.

Projects are in reverse-chronological order.

## Marketing Analysis

Data used is a single parsed events table which contains various frontend actions done on ecommerce site. Data in the table contains records from 2020-11-01 until 2021-01-31.

- #### Schema

![](https://github.com/KarolisGryb/first-analyses/blob/main/marketing_files/schema.png)

- #### Single row of extracted data with SQL

Weekday duration

|  channel |  weekday | avg_duration  |  sess_count |
| ------------ | ------------ | ------------ | ------------ |
| (direct)  | 3 | 164  | 5405  |

Purchases by session number

| sess_no  |  user_type | conversions  |  avg_purchase | count  |
| ------------ | ------------ | ------------ | ------------ | ------------ |
| 1  |  (organic) | 938  | 66  | 85829  |

Daily metrics

| day  | avg_duration  |  avg_clicks | conversions  | avg_purchase | bounce_count  |  user_count |
| ------------ | ------------ | ------------ | ------------ | ------------ | ------------ | ------------ |
|  2020-11-01 |  147 |  9 |  13 | 59  | 382  |  2365 |

- #### Analysis presentation

![](https://github.com/KarolisGryb/first-analyses/blob/main/marketing_files/present_file1.png)

![](https://github.com/KarolisGryb/first-analyses/blob/main/marketing_files/present_file2.png)




