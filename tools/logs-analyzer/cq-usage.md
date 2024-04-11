# CloudQuery Usage Analysis

## Overview

This document provides an analysis of the usage of CloudQuery during a single day. The data will assess how many "rows" are consumed for one day so that anticipated billing can be calculated.

## Data

As of 2024-04-04, the current usage of CloudQuery is as follows:

| PLUGIN | PRICE PER 1M ROWS | ROWS USAGE | SPEND |
| ------ | ----------------- | ---------- | ----- |
| AWS    | $10               | 41.9K/10M  | $0    |

Execution of the CloudQuery sync will be started at 14:30 EDT and the updated rows usage will be fetched once it has been updated.

Execution was lasting more than an hour compared to prod where it executes within 5 minutes. Stopped the execution and starting again with new configuration storing data as parquet files locally.

Current usage is now:
| PLUGIN | PRICE PER 1M ROWS | ROWS USAGE | SPEND |
| ------ | ----------------- | ---------- | ----- |
| AWS    | $10               | 478K/10M   | $0    |

After running the sync until completion, the final usage is:

| PLUGIN | PRICE PER 1M ROWS | ROWS USAGE | SPEND |
| ------ | ----------------- | ---------- | ----- |
| AWS    | $10               | 1.3M/10M   | $0    |

## Analysis

The usage of CloudQuery is currently at 1.3M rows, which is 13% of the total 10M rows. The spend is currently at $0. The usage is expected to increase as more data is synced.

The delta between the initial usage (second run) and the final usage is 1.3M - 478K = 822K rows. Since the total per month is 10M rows, we could technically do 10M / 822K = 12.2 runs per month before hitting the limit.

Billing thresholds are as follows:
| ROWS PER MONTH | PRICE PER 1M ROWS |
| -------------- | ----------------- |
| 0 - 1M         | Free              |
| 1M - 10M       | $ 15              |
| 10M - 100M     | $ 13              |
| 100M - 1000M   | $ 8               |

1 run averages 822K rows
30 runs per month
Estimated Total rows per month: 24.66M

- 1M rows free: $0
- 9M rows: $15 * 9 = $135
- 15M rows (14.66 rounded up): $13 * 15 = $195

Total cost: $135 + $195 = $330

Yearly cost would be $330 * 12 = $3960
