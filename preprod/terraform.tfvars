########################### COMMON ###########################
aws_region                      = "us-east-1"
aws_cloud_map_availability_zone = "us-east-1b"
internal                        = false
certificate_arn                 = "arn:aws:acm:us-east-1:949567456174:certificate/3ae8fb55-0e1d-45a6-9b14-400c6c37f758"
cpu                             = 2048
memory                          = 9216
cluster_name                    = "preprod"
# ecs_task_execution_role         = "arn:aws:iam::949567456174:role/ecsSSMTaskExecutionRole"
ecs_task_execution_role         = "arn:aws:iam::949567456174:role/ecsSSMTaskExecutionRole"

########################### SECURITY GROUP ###########################
lenny_cidr = "96.237.138.28/32"
abc_cidr = "96.237.138.28/32"

########################### TDM APPLICATION ###########################

tdm_app_name          = "tdm"
tdm_alb_name          = "preprod-tdm-elb-terraform"
tdm_target_group_name = "preprod-tdm"
# security_groups       = ["sg-0ef18cba1d58be344"]
tdm_target_group_port = 80
target_group_protocol = "HTTP"
vpc_id                = "vpc-00c8485d747ce142a"
tdm_health_check_path = "/api/release"
tags = {
  Name = "qa-tdm-elb"
}
tdm_cloudwatch_log_path = "ecs/preprod/tdm"


#################### Queue HTTP PROXY Application ####################

queue_http_proxy_app_name          = "queue-http-proxy"
queue_http_proxy_alb_name          = "preprod-queue-http-proxy-alb"
queue_http_proxy_target_group_name = "preprod-queue-http-proxy"
queue_http_proxy_target_group_port = 80
queue_http_proxy_health_path       = "/health"
queue_http_proxy_container_port    = 80
queue_http_proxy_cloudwatch_log_path = "ecs/preprod/queue-http-proxy"
########################### ADMIN Application ###########################

admin_alb_name            = "preprod-admin-elb"
admin_app_name            = "admin"
admin_target_group_name   = "preprod-admin"
admin_target_group_port   = 80
admin_health_path         = "/api/release"
admin_http_container_port = 80
admin_cloudwatch_log_path = "/ecs/preprod/admin"

##################### APP Application ###################

app_alb_name            = "preprod-app-elb"
app_app_name            = "app"
app_target_group_name   = "preprod-app"
app_target_group_port   = 80
app_health_path         = "/api/ping"
app_container_port      = 80
app_cloudwatch_log_path = "/ecs/preprod/app"


##################### AppReact Application ###################

app_react_alb_name            = "preprod-app-react-elb"
app_react_app_name            = "app-react"
app_react_target_group_name   = "preprod-app-react"
app_react_target_group_port   = 80
app_react_health_path         = "/"
app_react_container_port      = 8080
app_react_cloudwatch_log_path = "/ecs/preprod/app-react"


##################### ARCHIVER Application ###################

archiver_alb_name            = "preprod-archiver-elb"
archiver_app_name            = "archiver"
archiver_target_group_name   = "preprod-archiver"
archiver_target_group_port   = 8080
archiver_health_path         = "/api/release"
archiver_container_port      = 8080
archiver_cloudwatch_log_path = "/ecs/preprod/archiver"

##################### GTFS Application ###################

gtfs_rt_alb_name            = "preprod-gtfs-rt-elb"
gtfs_rt_app_name            = "gtfs-rt"
gtfs_rt_target_group_name   = "preprod-gtfs-rt"
gtfs_rt_target_group_port   = 8080
gtfs_rt_health_path         = "/"
gtfs_rt_container_port      = 80
gtfs_rt_cloudwatch_log_path = "/ecs/preprod/gtfs-rt"

##################### OPS API Application ###################

ops_api_alb_name            = "preprod-ops-api-elb"
ops_api_app_name            = "ops-api"
ops_api_target_group_name   = "preprod-ops-api"
ops_api_target_group_port   = 80
ops_api_health_path         = "/api/ping"
ops_api_container_port      = 8080
ops_api_cloudwatch_log_path = "/ecs/preprod/ops-api"

##################### ie0 API Application ###################

ie0_app_name            = "ie0"
ie0_container_port      = 8080
ie0_cloudwatch_log_path = "/ecs/preprod/ie0-api"
ie0_target_group_arn = [""]
##################### ie1 API Application ###################

ie1_app_name            = "ie1"
ie1_container_port      = 8080
ie1_cloudwatch_log_path = "/ecs/preprod/ie1-api"
ie1_target_group_arn = [""]
##################### ie2 API Application ###################

ie2_app_name            = "ie2"
ie2_container_port      = 8080
ie2_cloudwatch_log_path = "/ecs/preprod/ie2-api"
ie2_target_group_arn = [""]
##################### Monitoring HTTP Application ###################

monitoring_http_app_name            = "monitoring-http"
monitoring_http_container_port      = 8080
monitoring_http_cloudwatch_log_path = "/ecs/preprod/monitoring_http"
monitoring_http_target_group_arn = [""]
##################### Monitoring QUEUE Application ###################

monitoring_queue_app_name            = "monitoring-http"
monitoring_queue_container_port      = 8080
monitoring_queue_cloudwatch_log_path = "/ecs/preprod/monitoring_queue"
monitoring_queue_target_group_arn = [""]

##################### QUEUE BROKER INF Application ###################

queue_broker_inf_alb_name            = "preprod-queue-broker-inf-elb"
queue_broker_inf_app_name            = "queue-broker-inf"
queue_broker_inf_target_group_name   = "preprod-queue-broker-inf"
queue_broker_inf_target_group_port   = 80
queue_broker_inf_health_path         = "/api/ping"
queue_broker_inf_container_port      = 8080
queue_broker_inf_cloudwatch_log_path = "/ecs/preprod/queue-broker-inf"
queue_broker_inf_target_group_arn = [""]
##################### QUEUE BROKER TIME Application ###################

queue_broker_time_alb_name                 = "preprod-queue-broker-time-elb"
queue_broker_time_app_name                 = "queue-broker-time"
queue_broker_time_target_group_first_name  = "preprod-queue-broker-time"
queue_broker_time_target_group_first_port  = 5536
queue_broker_time_target_group_second_name = "preprod-queue-broker-time"
queue_broker_time_target_group_second_port = 5536
queue_broker_time_health_path = "/api/ping"
queue_broker_time_container_port      = 8080
queue_broker_time_cloudwatch_log_path = "/ecs/preprod/queue-broker-time"

##################### QUEUE BROKER BHS Application ###################

queue_broker_bhs_alb_name                 = "preprod-queue-bhs-elb"
queue_broker_bhs_app_name                 = "queue-broker-bhs"
queue_broker_bhs_target_group_first_name  = "preprod-queue-bhs-1"
queue_broker_bhs_target_group_first_port  = 5563
queue_broker_bhs_target_group_second_name = "preprod-queue-bhs-2"
queue_broker_bhs_target_group_second_port = 5564
queue_broker_bhs_health_path = "/api/ping"
queue_broker_bhs_container_port      = 8080
queue_broker_bhs_cloudwatch_log_path = "/ecs/preprod/queue-broker-bhs"
queue_broker_bhs_target_group_arn = [""]
##################### QUEUE BROKER BHS Application ###################

queue_broker_bhs_high_freq_alb_name                 = "preprod-Q-high-freq-nlb"
queue_broker_bhs_high_freq_app_name                 = "queue-broker-bhs-high-freq"
queue_broker_bhs_high_freq_target_group_first_name  = "preprod-Q-high-freq-1"
queue_broker_bhs_high_freq_target_group_first_port  = 5577
queue_broker_bhs_high_freq_target_group_second_name = "preprod-Q-high-freq-2"
queue_broker_bhs_high_freq_target_group_second_port = 5578
queue_broker_bhs_high_freq_health_path = "/api/ping"
queue_broker_bhs_high_freq_container_port      = 5568
queue_broker_bhs_high_freq_cloudwatch_log_path = "/ecs/preprod/queue-broker-bhs-high-freq"
queue_broker_bhs_high_freq_target_group_arn = [""]

##################### QUEUE FORWARDER PREDECTION Application ###################

queue_forwarder_predictions_alb_name                 = "preprod-queue-forwarder-predictions-elb"
queue_forwarder_predictions_app_name                 = "queue-forwarder-predictions"
queue_forwarder_predictions_target_group_first_name  = "preprod-queue-forwarder-predictions"
queue_forwarder_predictions_target_group_first_port  = 5568
queue_forwarder_predictions_target_group_second_name = "preprod-queue-forwarder-predictions"
queue_forwarder_predictions_target_group_second_port = 5569
queue_forwarder_predictions_container_port      = 5568
queue_forwarder_predictions_cloudwatch_log_path = "/ecs/preprod/queue-forwarder-predictions"
queue_forwarder_predictions_health_path = "/ping"
