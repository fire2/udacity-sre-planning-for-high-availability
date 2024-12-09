## Availability SLI
### The percentage of successful requests over the last 5m
### I multiplied * 100 to show the percentage
(sum(rate(flask_http_request_total{status=~"2.."}[5m]))/sum(rate(flask_http_request_total[5m]))) * 100

## Latency SLI
### 90% of requests finish in these times
histogram_quantile(0.90, sum(rate(flask_http_request_duration_seconds_bucket[5m])) by (le, verb))

## Throughput
### Successful requests per second
sum(rate(flask_http_request_total{status=~"2.."}[5m]))

## Error Budget - Remaining Error Budget
### The error budget is 20%
### I multiplied * 100 to show the percentage
(1 - ((1 - (sum(increase(flask_http_request_total{status=~"2.."}[7d])) by (verb))
/
sum(increase(flask_http_request_total[7d])) by (verb)) / (1 - .80))) * 100

