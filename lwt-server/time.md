# Multicore vs Systhreads Lwt_preemptive

**Server**: `fibp.ml`

Accepts requests from client and returns fibonnacci number of request.

**Client**: `client.ml`

Creates <arg1> clients and sends <arg2> requests of value 45 from each client to `fibp`.
Terminates after all requests have been sent a response by the server.

## Systhreads - 4.10.0

No of clients | Requests per client | Time
-- | -- | --
10 | 1 | 1m30.061s
1 | 10 | 1m30.056s
10 | 10 | 15m1.903s

## Multicore - 4.10.0+multicore+no-effect-syntax

### No. of domains = 1

| No of clients | Requests per client | Time       |
|---------------|---------------------|------------|
| 10            | 1                   | 1m26.934s  |
| 1             | 10                  | 1m26.927s  |
| 10            | 10                  | 14m29.713s |

### No. of domains = 2

| No of clients | Requests per client | Time      |
|---------------|---------------------|-----------|
| 10            | 1                   | 0m52.161s |
| 1             | 10                  | 1m26.929s |
| 10            | 10                  | 7m14.619s |

### No. of domains = 4

| No of clients | Requests per client | Time      |
|---------------|---------------------|-----------|
| 10            | 1                   | 0m43.470s |
| 1             | 10                  | 1m26.625s |
| 10            | 10                  | 3m54.749s |

### No. of domains = 8

| No of clients | Requests per client | Time      |
|---------------|---------------------|-----------|
| 10            | 1                   | 0m26.081s |
| 1             | 10                  | 1m26.724s |
| 10            | 10                  | 3m54.699s |
