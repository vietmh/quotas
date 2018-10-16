# quotas

## How we designed the Quotas microservice to prevent resource abuse

### TLD'R
- To solve problem: saving business logic services from dying and cascading failures by rejecting incoming requests in case of overload
- Inject into each business logic service and middleware and SDK to intercept incoming requests and check for process decision
- Using Kafka for contacting between rate limiting service and business logic services -> ability to scale
- Using Redis and implement a key hashing to evenly distribute among Redis instances -> ability to scale and low latency
---

Source: [How we designed the Quotas microservice to prevent resource abuse](https://engineering.grab.com/quotas-service)

- business has grown -> move from monolithic to microservices
- to work parallelly they defined and maintain **SLA** (Service level Agreements)
- facing problems that are simple or don't exist for monolithic service
  - service discovery
  - load balancing
  - monitoring
  - rate limiting

#### 1. What Quotas is?
- An API request rate limiting
- Mitigate the problems of service abuse and cascading service failures.
- Alternative: [Doorman](https://github.com/youtube/doorman/blob/master/doc/design.md), [Ambassador](https://www.getambassador.io/reference/services/rate-limit-service)
- Algorithm: leaky bucket, fixed window, sliding log, sliding window, ...
- Local Rate Limiting: per service instance. E.g: 
  - a rate limiting strategy can specify that **service instance** can serve up to 1000 requests per second for an API. Once the number of received request exceeds the threshold, it will reject new requests immediately until next time bucket with available quota.
- Global Rate Limiting: subject to the same global API quota. E.g:
  - In a cloud context, the number of instances for a service can automatically increase significantly during peak hours. If no Global Rate Limiting is enforced, there is no limit for number of service instances -> pressure on critical resources (DB, network, ...)
- Problem to solve:
  - Protect all of its clients (Business logic services or other kind of services) out of overhead by deciding which request should be blocked
  - Decision latency and scalability become major concerns since it could become a Bottleneck or Single Point of Failure
#### 2. Designing Quotas
- Guidelines:
  - thin, do not contains any business logic
  - auto scaling, asynchronous
  - allow horizontal scaling through config changes

- Use Kafka for following purposes:
  - listen rate limiting request from services
  - listen and response rate limiting result from Quotas services
  - additional analysis (Data archiving)
    ![Kafka](https://engineering.grab.com/img/quotas-service/image_0.jpg)
- How does Quotas work:
  1. Quotas middleware and Quotas client SDK:
    1.1. Quotas middleware:
      - intercept requests and call Quotas client SDK for rate limiting decision
        - if it throttles the request, return a response code indicate the request is throttled.
        - if it doen't, handle the request as usual
      - asynchronously sends to Kafka report for new request
    1.2. Quotas client SDK:
      - listen from Kafka new rate-limiting decision
      - provide API for Quotas middleware to listen to
    ![Quotas middleware & SDK](https://engineering.grab.com/img/quotas-service/image_1.jpg)
  2. Quotas service logic:
    - listen from Kafka for report for new request from services
    - perform aggregation on API usages for rate limiting decision
    - stores the stats in a Redis cluster periodically
    - send rate limiting decision to Kafka
    - send the stats to Datadog for monitoring and alerting
    - UI for admin to update thresholds
    ![Quotas](https://engineering.grab.com/img/quotas-service/image_2.jpg)

#### 3. Implementation decisions and optimizations
- Utilize internal streaming solution called Sprinkler (built on top of [sarama](https://github.com/Shopify/sarama)), providing asynchronous event sending/consuming, retry and circuit breaking
- based on sliding windows algorithm on 1-second and 5-second levels
- designed to be done asynchronously
- caching in memory and call Redis periodically (e.g. 50ms) to reduce bottleneck in Redis
- designed hash key to make sure requests are evenly distributed across Redis instances
- implement a dedicated cron job to garbage collect expired Redis keys and run it for every 15mins to keep Redis memory usage at low level