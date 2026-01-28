  # 0.3.26
  ## What's Changed
  * [PIL-16258]: fix validation to support valid prometheus no-data scenarios. Improved validation error message
  * [PIL-16424]: add missing CUSTOM_LABEL_FILTER to volume metrics

  # 0.3.25
  ## What's Changed
  * [PIL-15990]: update boto3 so support eks pod-identity

  # 0.3.24
  ## What's Changed
  * [PIL-15827]: fail if Prometheus query returns no-data

  ### New Features

  - **`FAIL_ON_EMPTY_METRICS`** environment variable is now available. When enabled, the agent will exit with a failure status if no metrics are collected during a run. This helps detect collection issues early in monitoring pipelines.

  - **CloudWatch EMF Monitoring** - New enviroment value `MONITORING=cloudwatch-emf` enables CloudWatch Embedded Metric Format (EMF) output for agent monitoring metrics. The agent can now publish its own operational metrics (like collection success/failure) directly to UmbrellaCost CloudWatch Logs, which are 
  automatically extracted as CloudWatch metrics.
