# API Service

| Category     | SLI                                                                 | SLO                                                                                                         |
|--------------|---------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| Availability | total # of successful requests / total # of requests over 5 minutes | 99%                                                                                                         |
| Latency      | 90th percentile latency over 5 minutes                              | 90% of requests below 100ms                                                                                 |
| Error Budget | total # of error requests / total # of requests in 7 days           | Error budget is defined at 20%. This means that 20% of the requests can fail and still be within the budget |
| Throughput   | total # of successful requests per second over 5 minutes            | 5 RPS indicates the application is functioning                                                              |
