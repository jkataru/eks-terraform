# COMMON VARS

variable "aws_region" {
  description = "This is the AWS region"
  type        = string
}
variable "aws_cloud_map_availability_zone" {
  description = "This is the AWS availability zone"
  type        = string
}
variable "cluster_name" {
  description = "This is the ECS cluster name"
  type        = string
}
variable "cpu" {
  description = "This is the ECS cpu count"
  type        = number
}
variable "memory" {
  description = "This is the ECS memory count"
  type        = number
}

variable "environment" {
  description = "The environment name (e.g., dev, qa, prod)"
  type        = string
  default     = "staging"
}

variable "ecs_task_execution_role" {
  description = "This is task execution role name"
  type        = string
}

variable "new_vpc_create" {
  type    = bool
  default = true
}
variable "existing_vpc_id" {
  type        = string
  default     = "" # Only needed if new_vpc_create is false
  description = "VPC ID to use if not creating a new VPC"
}
variable "private_subnet_enable" {
  description = "Enable or disable the private subnet"
  type        = bool
  default     = false
}
variable "public_subnet_cidrs" {
  description = "List of CIDRs for the private subnets"
  type        = map(string)
default = {
    "0" = "10.0.1.0/24"
    "1" = "10.0.2.0/24"
  }
}
variable "private_subnet_cidrs" {
  description = "List of CIDRs for the private subnets"
  type        = map(string)
default = {
    "0" = "10.0.3.0/24"
    "1" = "10.0.4.0/24"
  }
}
variable "public_subnet_enable" {
  description = "Enable or disable the private subnet"
  type        = bool
  default     = false
}
variable "target_group_arn" {
  type        = list(string)
  description = "List of target group ARNs for the ECS service"
  default = [ "" ]
}

# variable "sg_source" {
#    description = "The name of the source sg group"
#   type        = string
# }
# variable "lb_name" {
#   description = "The name of the Load Balancer"
#   type        = string
# }

############## SECURITY GROUP ###############
variable "lenny_cidr" {type=string}
variable "abc_cidr" {type=string}

############## TDM APPLICATION ###############
variable "tdm_app_name" {
  description = "This is app name"
  type        = string
}
variable "tdm_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "tdm_target_group_name" {
  description = "The name of the Target Group"
  type        = string
}

variable "tdm_cloudwatch_log_path" {
  description = "The name of the log Group"
  type        = string
}
variable "internal" {
  description = "Boolean to determine if the load balancer is internal or not"
  type        = bool
  default     = false
}
# variable "security_groups" {
#   description = "List of security groups for the ALB"
#   type        = list(string)
# }

# variable "subnets" {
#   description = "List of subnets for the ALB"
#   type        = list(string)
# }

variable "certificate_arn" {
  description = "ARN of the SSL certificate for the HTTPS listener"
  type        = string
}

variable "tdm_target_group_port" {
  description = "Name of the target group"
  type        = string
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

# VPC ID for the target group
variable "vpc_id" {
  description = "VPC ID where the target group is located"
  type        = string
}

# Health check path for the target group
variable "tdm_health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/"
}

# Tags for the ALB
variable "tags" {
  description = "Tags for the ALB"
  type        = map(string)
}

################### QUEUE HTTP PROXIE Application###################
variable "queue_http_proxy_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "queue_http_proxy_app_name" {
  description = "The name of the application"
  type        = string
}
variable "queue_http_proxy_target_group_name" {
  description = "The name of the Target Group"
  type        = string
}

variable "queue_http_proxy_target_group_port" {
  description = "The name of the Target Group port"
  type        = number
}

variable "queue_http_proxy_cloudwatch_log_path" {
  description = "The name of the log Group"
  type        = string
}
variable "queue_http_proxy_health_path" {
  description = "The name of the health path"
  type        = string
}

variable "queue_http_proxy_container_port" {
  description = "The name of the port"
  type        = number
}

################### ADMIN Application###################
variable "admin_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "admin_app_name" {
  description = "The name of the application"
  type        = string
}

variable "admin_target_group_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "admin_target_group_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "admin_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "admin_http_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "admin_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}


################### APP Application###################
variable "app_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "app_app_name" {
  description = "The name of the application"
  type        = string
}

variable "app_target_group_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "app_target_group_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "app_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "app_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "app_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}


################### APP-React Application###################
variable "app_react_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "app_react_app_name" {
  description = "The name of the application"
  type        = string
}

variable "app_react_target_group_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "app_react_target_group_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "app_react_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "app_react_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "app_react_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}


################### ARCHIVER Application###################
variable "archiver_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "archiver_app_name" {
  description = "The name of the application"
  type        = string
}

variable "archiver_target_group_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "archiver_target_group_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "archiver_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "archiver_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "archiver_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}


################### gtfs_rt Application###################
variable "gtfs_rt_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "gtfs_rt_app_name" {
  description = "The name of the application"
  type        = string
}

variable "gtfs_rt_target_group_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "gtfs_rt_target_group_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "gtfs_rt_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "gtfs_rt_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "gtfs_rt_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}

################### ops_api Application###################
variable "ops_api_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "ops_api_app_name" {
  description = "The name of the application"
  type        = string
}

variable "ops_api_target_group_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "ops_api_target_group_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "ops_api_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "ops_api_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "ops_api_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}

################### ie0 Application###################

variable "ie0_app_name" {
  description = "The name of the application"
  type        = string
}
variable "ie0_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "ie0_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "ie0_target_group_arn" {
  description = "The name of the Target Group"
  type        = list(string)
  default = [""]
}

################### ie1 Application###################

variable "ie1_app_name" {
  description = "The name of the application"
  type        = string
}

variable "ie1_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "ie1_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}

variable "ie1_target_group_arn" {
  description = "The name of the Target Group"
  type        = list(string)
}
################### ie2 Application###################

variable "ie2_app_name" {
  description = "The name of the application"
  type        = string
}
variable "ie2_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "ie2_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}

variable "ie2_target_group_arn" {
  description = "The name of the Target Group"
  type        = list(string)
}
################### monitoring_http Application###################

variable "monitoring_http_app_name" {
  description = "The name of the application"
  type        = string
}
variable "monitoring_http_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "monitoring_http_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "monitoring_http_target_group_arn" {
  description = "The name of the Target Group"
  type        = list(string)
  default = [""]
}

################### monitoring_queue Application###################

variable "monitoring_queue_app_name" {
  description = "The name of the application"
  type        = string
}
variable "monitoring_queue_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "monitoring_queue_cloudwatch_log_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "monitoring_queue_target_group_arn" {
  description = "The name of the Target Group"
  type        = list(string)
  default = [""]
}

################### queue_broker_inf Application###################
variable "queue_broker_inf_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "queue_broker_inf_app_name" {
  description = "The name of the application"
  type        = string
}

variable "queue_broker_inf_target_group_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_inf_target_group_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_inf_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_inf_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_inf_cloudwatch_log_path" {
  description = "The name of cloudwatch log path"
  type        = string
}

variable "queue_broker_inf_target_group_arn" {
  description = "The name of the Target Group ARN"
  type        = list(string)
  default = [""]
}

################### queue_broker_time Application###################
variable "queue_broker_time_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "queue_broker_time_app_name" {
  description = "The name of the application"
  type        = string
}

variable "queue_broker_time_target_group_first_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_time_target_group_first_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_time_target_group_second_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_time_target_group_second_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_time_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_time_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_time_cloudwatch_log_path" {
  description = "The name of cloudwatch log path"
  type        = string
}
# variable "queue_broker_time_target_group_arn" {
#   description = "The name of the Target Group ARN"
#   type        = string
# }


################### queue_broker_bhs Application###################
variable "queue_broker_bhs_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "queue_broker_bhs_app_name" {
  description = "The name of the application"
  type        = string
}

variable "queue_broker_bhs_target_group_first_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_target_group_first_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_target_group_second_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_target_group_second_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_cloudwatch_log_path" {
  description = "The name of cloudwatch log path"
  type        = string
}
variable "queue_broker_bhs_target_group_arn" {
  description = "The name of the Target Group ARN"
  type        = list(string)
  default = [""]
}



################### queue_broker_bhs_high_freq Application###################
variable "queue_broker_bhs_high_freq_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "queue_broker_bhs_high_freq_app_name" {
  description = "The name of the application"
  type        = string
}

variable "queue_broker_bhs_high_freq_target_group_first_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_high_freq_target_group_first_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_high_freq_target_group_second_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_high_freq_target_group_second_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_high_freq_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_high_freq_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_broker_bhs_high_freq_cloudwatch_log_path" {
  description = "The name of cloudwatch log path"
  type        = string
}
variable "queue_broker_bhs_high_freq_target_group_arn" {
  description = "The name of the Target Group ARN"
  type        = list(string)
  default = [""]
}

################### queue_forwarder_predictions Application###################
variable "queue_forwarder_predictions_alb_name" {
  description = "The name of the Load Balancer"
  type        = string
}
variable "queue_forwarder_predictions_app_name" {
  description = "The name of the application"
  type        = string
}

variable "queue_forwarder_predictions_target_group_first_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_forwarder_predictions_target_group_first_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_forwarder_predictions_target_group_second_name" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_forwarder_predictions_target_group_second_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_forwarder_predictions_health_path" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_forwarder_predictions_container_port" {
  description = "The name of the Target Group"
  type        = string
}
variable "queue_forwarder_predictions_cloudwatch_log_path" {
  description = "The name of cloudwatch log path"
  type        = string
}
# variable "queue_forwarder_predictions_target_group_arn" {
#   description = "The name of the Target Group ARN"
#   type        = string
# }

variable "ecs_services" {
  description = "List of ECS services"
  type        = list(string)
  default     = [
    "tdm",
    "queue-http-proxy",
    "admin",
    "app",
    "app-react",
    "archiver",
    "gtfs-rt",
"ops-api",
"monitoring-http",
"queue-broker-inf",
"queue-broker-time",
"queue-broker-bhs",
"queue-broker-bhs-high-freq",
"queue-forwarder-predictions"
  ]
}