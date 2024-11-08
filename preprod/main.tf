locals {
  tags = {
    Name       = var.cluster_name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

# VPC section calls VPC module from "./modules/networking" 
## These are varible which are used to enable or disable the named resources public_subnet_enable , public_subnet_enable, new_vpc_create
module "vpc" {
  source                = "./modules/networking/vpc"
  cluster_name          = var.cluster_name
  private_subnet_cidrs  = var.private_subnet_cidrs
  public_subnet_enable  = var.public_subnet_enable
  private_subnet_enable = var.private_subnet_enable
  public_subnet_cidrs   = var.public_subnet_cidrs
  count                 = var.new_vpc_create ? 1 : 0 # if false old vpc will be used. To use old vpc plese specify old vpc id in "existing_vpc_id"
}
module "ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  version      = "~> 5.11.1"
  cluster_name = var.cluster_name
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
  tags = local.tags
}
resource "aws_service_discovery_private_dns_namespace" "main_cloud_map" {
  name        = var.cluster_name
  description = "This is ${var.cluster_name} cloud map Namespace"
  vpc         = module.vpc[0].main_vpc_id

  tags = {
    Environment = var.environment
    Project     = var.cluster_name
  }
}
###################### START Security Group  ######################

module "admin_sg" {
  source        ="./modules/networking/security_group"
  vpc_id = module.vpc[0].main_vpc_id
  name          = "${var.cluster_name}-${var.admin_app_name}-sg"
  inbound_rules = [
    { from_port = 8080, to_port = 8080, protocol = "tcp", source_sg_ids = [module.admin_lb_sg.sg_id] }
  ]
  depends_on = [ module.admin_lb_sg ]
}

module "app_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.app_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id

  inbound_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.app_lb_sg.sg_id] },
    { from_port = 8080, to_port = 8080, protocol = "tcp", source_sg_ids = [module.app_lb_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [var.lenny_cidr] }
  ]
}

module "app_react_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.app_react_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id

  inbound_rules = [{ from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]  # ALL
}

module "archiver_sg" {
  source        = "./modules/networking/security_group"
  vpc_id = module.vpc[0].main_vpc_id
  name          ="${var.cluster_name}-${var.archiver_app_name}-sg"
  inbound_rules = [{ from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]  # ALL
}

module "ie_sg" {
  source        ="./modules/networking/security_group"
  vpc_id = module.vpc[0].main_vpc_id
  name          = "${var.cluster_name}-ie-sg"
  inbound_rules = [
    { from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }  # All traffic
  ]
}

module "camsys_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-camsys-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [var.lenny_cidr] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [var.lenny_cidr] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [var.lenny_cidr] }
  ]
}

module "monitoring_sg" {
  source        ="./modules/networking/security_group"
  vpc_id = module.vpc[0].main_vpc_id
  name          = "${var.cluster_name}-${var.monitoring_http_app_name}-sg"
  inbound_rules = [{ from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]  # ALL
}

module "ops_api_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.ops_api_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.ops_lb_sg.sg_id] },
    { from_port = 8080, to_port = 8080, protocol = "tcp", source_sg_ids = [module.ops_lb_sg.sg_id] }
  ]
}

module "queue_bhs_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.queue_broker_bhs_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 5563, to_port = 5564, protocol = "tcp", source_sg_ids = [module.queue_lb_sg.sg_id] },
    { from_port = 5564, to_port = 5564, protocol = "tcp", cidr_blocks = ["96.237.138.28/32"] }
  ]
}

module "queue_inf_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.queue_broker_inf_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 5563, to_port = 5564, protocol = "tcp", source_sg_ids = [module.queue_lb_sg.sg_id] }
  ]
}

module "queue_broker_time_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.queue_broker_time_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 5563, to_port = 5564, protocol = "tcp", source_sg_ids = [module.queue_lb_sg.sg_id] }
  ]
}

module "queue_forwarder_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.queue_broker_time_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }  # All traffic
  ]
}

module "queue_http_proxy_sg" {
  source        ="./modules/networking/security_group"
  vpc_id = module.vpc[0].main_vpc_id
  name          = "${var.cluster_name}-${var.queue_http_proxy_app_name}-sg"
  inbound_rules = [{ from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]  # ALL
}

module "gtfsrt_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.gtfs_rt_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.gtfsrt_lb_sg.sg_id] },
    { from_port = 8080, to_port = 8080, protocol = "tcp", source_sg_ids = [module.gtfsrt_lb_sg.sg_id] }
  ]
}

module "prediction_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.queue_forwarder_predictions_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }  # All traffic
  ]
}

module "tdm_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.tdm_app_name}-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.archiver_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.prediction_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.ie_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.gtfsrt_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.app_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.tdm_lb_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.admin_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.ops_api_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] }
  ]
}

module "queue_lb_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-queue-lb-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 5564, to_port = 5564, protocol = "tcp", source_sg_ids = [module.archiver_sg.sg_id] },
    { from_port = 5567, to_port = 5567, protocol = "tcp", source_sg_ids = [module.archiver_sg.sg_id] },
    { from_port = 5567, to_port = 5567, protocol = "tcp", source_sg_ids = [module.prediction_sg.sg_id] },
    { from_port = 5567, to_port = 5567, protocol = "tcp", source_sg_ids = [module.app_sg.sg_id] },
    { from_port = 5563, to_port = 5563, protocol = "tcp", source_sg_ids = [module.queue_http_proxy_sg.sg_id] },
    { from_port = 5564, to_port = 5564, protocol = "tcp", source_sg_ids = [module.ie_sg.sg_id] },
    { from_port = 5566, to_port = 5566, protocol = "tcp", source_sg_ids = [module.ie_sg.sg_id] },
    { from_port = 5569, to_port = 5569, protocol = "tcp", source_sg_ids = [module.gtfsrt_sg.sg_id] },
    { from_port = 5567, to_port = 5567, protocol = "tcp", source_sg_ids = [module.ops_api_sg.sg_id] },
    { from_port = 5567, to_port = 5567, protocol = "tcp", source_sg_ids = [module.gtfsrt_sg.sg_id] },
    { from_port = 5563, to_port = 5563, protocol = "tcp", source_sg_ids = [module.queue_forwarder_sg.sg_id] },
    { from_port = 5564, to_port = 5564, protocol = "tcp", source_sg_ids = [module.ops_api_sg.sg_id] },
    { from_port = 5578, to_port = 5578, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] },
    { from_port = 5569, to_port = 5569, protocol = "tcp", source_sg_ids = [module.app_sg.sg_id] }
  ]
}

module "app_lb_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.app_app_name}-lb-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "http_access_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-http-access-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [var.lenny_cidr] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [var.lenny_cidr] }
  ]
}

module "ie_lb_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-ie-lb-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.ie_sg.sg_id] }
  ]
}

module "tdm_lb_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.tdm_app_name}-lb-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }  # All traffic
  ]
}

module "ops_lb_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.ops_api_app_name}-lb-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }  # All traffic
  ]
}

module "gtfsrt_lb_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.gtfs_rt_app_name}-lb-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] },
    { from_port = 443, to_port = 443, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] },
    { from_port = 8080, to_port = 8080, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] }
  ]
}

module "admin_lb_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.admin_app_name}-lb-sg"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] },
    { from_port = 443, to_port = 443, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] },
    { from_port = 8080, to_port = 8080, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] }
  ]
}

module "archiver_lb_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.archiver_app_name}-lb-sb"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 8080, to_port = 8080, protocol = "tcp", source_sg_ids = [module.archiver_sg.sg_id] },
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] },
    { from_port = 443, to_port = 443, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] },
    { from_port = 8080, to_port = 8080, protocol = "tcp", source_sg_ids = [module.monitoring_sg.sg_id] }
  ]
}

module "queue_http_proxy_lb_sg" {
  source        ="./modules/networking/security_group"
  name          = "${var.cluster_name}-${var.queue_http_proxy_app_name}-lb-sb"
  vpc_id = module.vpc[0].main_vpc_id
  inbound_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", source_sg_ids = [module.queue_forwarder_sg.sg_id] }
  ]
}

# module "staging_app_elb_duplicate" {
#   source        ="./modules/networking/security_group"
  # vpc_id = module.vpc[0].main_vpc_id
#   name          = "staging-app-elb-duplicate"
#   inbound_rules = [{ from_port = 0, to_port = 65535, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]  # ALL
# }

###################### END Security Group  ######################


###################### TDM ALB & Service  ######################

module "tdm_alb" {
  source                = "./modules/alb"
  lb_name               = var.tdm_alb_name
  internal              = false
  security_groups       = [module.tdm_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.tdm_target_group_name
  target_group_port     = var.tdm_target_group_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.tdm_health_check_path

  tags = {
    Name = "${var.cluster_name}-${var.tdm_alb_name}"
  }
}

data "aws_ecs_task_definition" "tdm_task_def" {
  task_definition = "${var.tdm_app_name}-${var.cluster_name}"
}

module "tdm_ecs_service" {
  source                            = "./modules/ecs"
  family                            = "${var.tdm_app_name}-${var.cluster_name}"
  execution_role_arn                = var.ecs_task_execution_role
  task_role_arn                     = var.ecs_task_execution_role
  cpu                               = var.cpu
  memory                            = var.memory
  operating_system_family           = "LINUX"
  cpu_architecture                  = "X86_64"
  task_definition                   = data.aws_ecs_task_definition.tdm_task_def.arn
  service_name                      = var.tdm_app_name
  cluster_id                        = module.ecs.cluster_id
  desired_count                     = 1
  subnets                           = module.vpc[0].public_subnet_ids
  security_groups                   = [module.tdm_sg.sg_id]
  target_group_arn                  = [module.tdm_alb.target_group_arn]
  container_name                    = var.tdm_app_name
  container_port                    = 80
  assign_public_ip                  = true
  force_new_deployment              = true
  health_check_grace_period_seconds = 600
}

resource "aws_cloudwatch_log_group" "ecs_log_group-tdm" {
  name              = var.tdm_cloudwatch_log_path
  retention_in_days = 7
}

# module "tdm_cloud_map" {
#   source                          = "./modules/cloud_map"
#   cluster_name                    = var.cluster_name
#   aws_region                      = var.aws_region
#   aws_cloud_map_availability_zone = var.aws_cloud_map_availability_zone
#   namespace_id                    = aws_service_discovery_private_dns_namespace.main_cloud_map.id
#   service_name                    = var.tdm_app_name
#   ttl                             = 60
#   failure_threshold               = 1
#   instance_id                     = module.tdm_ecs_service.ecs_instance_id
#   aws_instance_ipv4               = module.tdm_ecs_service.ecs_instance_ipv4
#   ecs_service_name                = var.tdm_app_name
#   ecs_task_definition_family      = "${var.tdm_app_name}-staging"
# }

########################### queue-http-proxy Service ###########################
module "alb_queue-http-proxy" {
  source                = "./modules/alb"
  lb_name               = var.queue_http_proxy_alb_name
  internal              = false
  security_groups       = [module.queue_http_proxy_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.queue_http_proxy_target_group_name
  target_group_port     = var.queue_http_proxy_target_group_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.queue_http_proxy_health_path
  tags = {
    Name = "${var.cluster_name}-${var.queue_http_proxy_app_name}-elb"
  }
}
data "aws_ecs_task_definition" "queue_http_proxy_task_def" {
  task_definition = "${var.queue_http_proxy_app_name}-${var.cluster_name}"
}
module "queue_http_proxy_ecs_service" {
  source                            = "./modules/ecs"
  family                            = "${var.queue_http_proxy_app_name}-http-proxy-${var.cluster_name}"
  execution_role_arn                = var.ecs_task_execution_role
  task_role_arn                     = var.ecs_task_execution_role
  cpu                               = var.cpu
  memory                            = var.memory
  operating_system_family           = "LINUX"
  cpu_architecture                  = "X86_64"
  task_definition                   = data.aws_ecs_task_definition.queue_http_proxy_task_def
  service_name                      = var.queue_http_proxy_app_name
  cluster_id                        = module.ecs.cluster_id
  desired_count                     = 1
  subnets                           = module.vpc[0].public_subnet_ids
  security_groups                   = [module.queue_http_proxy_sg.sg_id]
  target_group_arn                  = module.alb_queue-http-proxy.target_group_arn
  container_name                    = var.queue_http_proxy_app_name
  container_port                    = var.queue_http_proxy_container_port
  assign_public_ip                  = true
  force_new_deployment              = true
  health_check_grace_period_seconds = 60
}


######################## ADMIN SERVICE ###########################
module "admin_alb" {
  source = "./modules/alb"

  lb_name               = var.admin_alb_name
  internal              = false
  security_groups       = [module.admin_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.admin_target_group_name
  target_group_port     = var.admin_target_group_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.admin_health_path

  tags = {
    Name = var.admin_alb_name
  }
}
data "aws_ecs_task_definition" "queue_task_def" {
  task_definition = "${var.admin_app_name}-${var.cluster_name}"
}

module "admin_ecs_service" {
  source                            = "./modules/ecs"
  family                            = "${var.admin_app_name}-${var.cluster_name}"
  execution_role_arn                = var.ecs_task_execution_role
  task_role_arn                     = var.ecs_task_execution_role
  cpu                               = var.cpu
  memory                            = var.memory
  operating_system_family           = "LINUX"
  cpu_architecture                  = "X86_64"
  task_definition                   = data.aws_ecs_task_definition.queue_task_def
  service_name                      = var.admin_app_name
  cluster_id                        = module.ecs.cluster_id
  desired_count                     = 1
  subnets                           = module.vpc[0].public_subnet_ids
  security_groups                   = [module.admin_sg.sg_id]
  target_group_arn                  = module.admin_alb.target_group_arn
  container_name                    = var.admin_app_name
  container_port                    = var.admin_http_container_port
  assign_public_ip                  = true
  force_new_deployment              = true
  health_check_grace_period_seconds = 180
}

resource "aws_cloudwatch_log_group" "admin_ecs_log_group_admin" {
  name              = var.admin_cloudwatch_log_path
  retention_in_days = 7
}

######################## APP SERVICE ###########################

module "app_alb" {
  source                = "./modules/alb"
  lb_name               = var.app_alb_name
  internal              = false
  security_groups       = [module.app_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.app_target_group_name
  target_group_port     = var.app_target_group_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.app_cloudwatch_log_path

  tags = {
    Name = var.app_alb_name
  }
}

data "aws_ecs_task_definition" "app_task_def" {
  task_definition = "${var.app_app_name}-${var.cluster_name}"
}
module "app_ecs_service" {
  source                            = "./modules/ecs"
  family                            = "${var.app_app_name}-${var.cluster_name}"
  execution_role_arn                = var.ecs_task_execution_role
  task_role_arn                     = var.ecs_task_execution_role
  cpu                               = 4096
  memory                            = 16384
  operating_system_family           = "LINUX"
  cpu_architecture                  = "X86_64"
  task_definition                   = data.aws_ecs_task_definition.app_task_def.arn
  service_name                      = var.app_app_name
  cluster_id                        = module.ecs.cluster_id
  desired_count                     = 1
  subnets                           = module.vpc[0].public_subnet_ids
  security_groups                   = [module.app_sg.sg_id]
  target_group_arn                  = module.app_alb.target_group_arn
  container_name                    = var.app_app_name
  container_port                    = var.app_container_port
  assign_public_ip                  = true
  force_new_deployment              = true
  health_check_grace_period_seconds = 360
}

resource "aws_cloudwatch_log_group" "ecs_log_group-app" {
  name              = var.app_cloudwatch_log_path
  retention_in_days = 7 
}

######################## APP-REACT SERVICE ###########################
module "alb_app-react" {
  source = "./modules/alb"

  lb_name               = var.app_react_alb_name
  internal              = false
  security_groups       = [module.app_react_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.app_react_target_group_name
  target_group_port     = var.app_react_target_group_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.app_react_health_path

  tags = {
    Name = var.app_react_alb_name
  }
}

data "aws_ecs_task_definition" "app_react_task_def" {
  task_definition = "${var.app_react_app_name}-${var.cluster_name}"
}
module "app_react_ecs_service" {
  source                  = "./modules/ecs"
  family                  = "${var.app_react_app_name}-${var.cluster_name}"
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 2048
  memory                  = 4096
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition                   = data.aws_ecs_task_definition.app_react_task_def.arn
  service_name                      = var.app_react_app_name
  cluster_id                        = module.ecs.cluster_id
  desired_count                     = 1
  subnets                           = module.vpc[0].public_subnet_ids
  security_groups                   = [module.app_react_sg.sg_id]
  target_group_arn                  = module.alb_app-react.target_group_arn
  container_name                    = var.app_react_app_name
  container_port                    = var.app_react_container_port
  assign_public_ip                  = true
  force_new_deployment              = true
  health_check_grace_period_seconds = 30
}

resource "aws_cloudwatch_log_group" "ecs_log_group-app-react" {
  name              = var.app_react_cloudwatch_log_path
  retention_in_days = 7
}

######################## ARCHIVER SERVICE ###########################
module "alb_archiver" {
  source = "./modules/alb"

  lb_name               = var.archiver_alb_name
  internal              = false
  security_groups       = [module.archiver_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.archiver_target_group_name
  target_group_port     = var.archiver_target_group_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.archiver_health_path

  tags = {
    Name = var.archiver_alb_name
  }
}
data "aws_ecs_task_definition" "archiver_task_def" {
  task_definition = "${var.archiver_app_name}-${var.cluster_name}"
}
module "ecs_archiver_taskdefination" {
  source                            = "./modules/ecs"
  family                            = "${var.archiver_app_name}-${var.cluster_name}"
  execution_role_arn                = var.ecs_task_execution_role
  task_role_arn                     = var.ecs_task_execution_role
  cpu                               = 2048
  memory                            = 4096
  operating_system_family           = "LINUX"
  cpu_architecture                  = "X86_64"
  task_definition                   = data.aws_ecs_task_definition.archiver_task_def
  service_name                      = var.archiver_app_name
  cluster_id                        = module.ecs.cluster_id
  desired_count                     = 1
  subnets                           = module.vpc[0].public_subnet_ids
  security_groups                   = [module.archiver_sg.sg_id]
  target_group_arn                  = module.alb_archiver.target_group_arn
  container_name                    = var.archiver_app_name
  container_port                    = var.archiver_container_port
  assign_public_ip                  = true
  force_new_deployment              = true
  health_check_grace_period_seconds = 60
}

resource "aws_cloudwatch_log_group" "ecs_log_group-archiver" {
  name              = var.archiver_cloudwatch_log_path
  retention_in_days = 7
}

######################## GTFS-RT SERVICE ###########################
module "alb_gtfs-rt" {
  source = "./modules/alb"

  lb_name               = var.gtfs_rt_alb_name
  internal              = false
  security_groups       = [module.gtfsrt_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.gtfs_rt_target_group_name
  target_group_port     = var.gtfs_rt_target_group_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.gtfs_rt_health_path

  tags = {
    Name = "${var.cluster_name}-${var.gtfs_rt_app_name}-elb"
  }
}
data "aws_ecs_task_definition" "gtfs_rt_task_def" {
  task_definition = "${var.gtfs_rt_app_name}-${var.cluster_name}"
}
module "gtfs_rt_ecs_service" {
  source                            = "./modules/ecs"
  family                            = "${var.gtfs_rt_app_name}-${var.cluster_name}"
  execution_role_arn                = var.ecs_task_execution_role
  task_role_arn                     = var.ecs_task_execution_role
  cpu                               = 2048
  memory                            = 16384
  operating_system_family           = "LINUX"
  cpu_architecture                  = "X86_64"
  task_definition                   = data.aws_ecs_task_definition.gtfs_rt_task_def
  service_name                      = var.gtfs_rt_app_name
  cluster_id                        = module.ecs.cluster_id
  desired_count                     = 1
  subnets                           = module.vpc[0].public_subnet_ids
  security_groups                   = [module.gtfsrt_sg.sg_id]
  target_group_arn                  = module.alb_gtfs-rt.target_group_arn
  container_name                    = var.gtfs_rt_app_name
  container_port                    = var.gtfs_rt_container_port
  assign_public_ip                  = true
  force_new_deployment              = true
  health_check_grace_period_seconds = 60
}

resource "aws_cloudwatch_log_group" "ecs_log_group-gtfs-rt" {
  name              = var.gtfs_rt_cloudwatch_log_path
  retention_in_days = 7
}
################## OPS-API #######################
module "alb_ops-api" {
  source                = "./modules/alb"
  lb_name               = "${var.cluster_name}-${var.ops_api_app_name}-elb"
  internal              = false
  security_groups       = [module.ops_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.ops_api_target_group_name
  target_group_port     = var.ops_api_target_group_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.ops_api_health_path

  tags = {
    Name = "${var.cluster_name}-${var.ops_api_app_name}-elb"
  }
}

data "aws_ecs_task_definition" "ops_api_task_def" {
  task_definition = "${var.ops_api_app_name}-${var.cluster_name}"
}
module "ops_api_ecs_service" {
  source                            = "./modules/ecs"
  family                            = "${var.ops_api_app_name}-${var.cluster_name}"
  execution_role_arn                = var.ecs_task_execution_role
  task_role_arn                     = var.ecs_task_execution_role
  cpu                               = 2048
  memory                            = 16384
  operating_system_family           = "LINUX"
  cpu_architecture                  = "X86_64"
  task_definition                   = data.aws_ecs_task_definition.ops_api_task_def
  service_name                      = var.ops_api_app_name
  cluster_id                        = module.ecs.cluster_id
  desired_count                     = 1
  subnets                           = module.vpc[0].public_subnet_ids
  security_groups                   = [module.ops_api_sg.sg_id]
  target_group_arn                  = module.alb_ops-api.target_group_arn
  container_name                    = var.ops_api_app_name
  container_port                    = var.ops_api_container_port
  assign_public_ip                  = true
  force_new_deployment              = true
  health_check_grace_period_seconds = 360
}

resource "aws_cloudwatch_log_group" "ecs_log_group-ops-api" {
  name              = var.ops_api_cloudwatch_log_path
  retention_in_days = 7
}
#####################IE0 SERVICE##########
data "aws_ecs_task_definition" "ie0_task_def" {
  task_definition = "${var.ie0_app_name}-${var.cluster_name}"
}
module "ie0_ecs_service" {
  source                  = "./modules/ecs"
  family                  = "${var.ie0_app_name}-${var.cluster_name}"
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 16384
  memory                  = 32768
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.ie0_task_def.arn
  service_name            = var.ie0_app_name
  cluster_id              = module.ecs.cluster_id
  target_group_arn = var.ie0_target_group_arn
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         = [module.ie_sg.sg_id]
  container_name          = var.ie0_app_name
  container_port          = var.ie0_container_port
  assign_public_ip        = true
  force_new_deployment    = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-ie0" {
  name              = var.ie0_cloudwatch_log_path
  retention_in_days = 7 # Adjust retention as needed
}

############### IE1 SERVICE ###################
data "aws_ecs_task_definition" "ie1_task_def" {
  task_definition = "${var.ie1_app_name}-${var.cluster_name}"
}
module "ie1_ecs_service" {
  source                  = "./modules/ecs"
  family                  = "${var.ie1_app_name}-${var.cluster_name}"
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 16384
  memory                  = 32768
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.ie1_task_def.arn
  service_name            = var.ie1_app_name
  cluster_id              = module.ecs.cluster_id
  target_group_arn = var.ie1_target_group_arn
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         = [module.ie_sg.sg_id]
  container_name          = var.ie1_app_name
  container_port          = var.ie1_container_port
  assign_public_ip        = true
  force_new_deployment    = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-ie1" {
  name              = var.ie1_cloudwatch_log_path
  retention_in_days = 7
}

############### IE2 SERVICE ###################
data "aws_ecs_task_definition" "ie2_task_def" {
  task_definition = "${var.ie2_app_name}-${var.cluster_name}"
}
module "ie2_ecs_service" {
  source                  = "./modules/ecs"
  family                  = "${var.ie2_app_name}-${var.cluster_name}"
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 16384
  memory                  = 32768
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.ie2_task_def.arn
  service_name            = var.ie2_app_name
  cluster_id              = module.ecs.cluster_id
  target_group_arn = var.ie2_target_group_arn
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         = [module.ie_sg.sg_id]
  container_name          = var.ie2_app_name
  container_port          = var.ie2_container_port
  assign_public_ip        = true
  force_new_deployment    = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-ie2" {
  name              = var.ie2_cloudwatch_log_path
  retention_in_days = 7
}

############### Monitoring HTTP SERVICE ###################
data "aws_ecs_task_definition" "monitoring_http_task_def" {
  task_definition = "${var.monitoring_http_app_name}-${var.cluster_name}"
}
module "monitoring_http_ecs_service" {
  source                  = "./modules/ecs"
  family                  = "${var.monitoring_http_app_name}-${var.cluster_name}"
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 16384
  memory                  = 32768
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.monitoring_http_task_def.arn
  service_name            = var.monitoring_http_app_name
  cluster_id              = module.ecs.cluster_id
  target_group_arn = var.monitoring_http_target_group_arn
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         = [module.monitoring_sg.sg_id]
  container_name          = var.monitoring_http_app_name
  container_port          = var.monitoring_http_container_port
  assign_public_ip        = true
  force_new_deployment    = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-monitoring_http" {
  name              = var.monitoring_http_cloudwatch_log_path
  retention_in_days = 7 # Adjust retention as needed
}


############### Monitoring QUEUE SERVICE ###################
data "aws_ecs_task_definition" "monitoring_queue_task_def" {
  task_definition = "${var.monitoring_queue_app_name}-${var.cluster_name}"
}
module "monitoring_queue_ecs_service" {
  source                  = "./modules/ecs"
  family                  = "${var.monitoring_queue_app_name}-${var.cluster_name}"
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 16384
  memory                  = 32768
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.monitoring_queue_task_def.arn
  service_name            = var.monitoring_queue_app_name
  cluster_id              = module.ecs.cluster_id
  target_group_arn = var.monitoring_queue_target_group_arn
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         = [module.monitoring_sg.sg_id]
  container_name          = var.monitoring_queue_app_name
  container_port          = var.monitoring_queue_container_port
  assign_public_ip        = true
  force_new_deployment    = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-monitoring_queue" {
  name              = var.monitoring_queue_cloudwatch_log_path
  retention_in_days = 7 # Adjust retention as needed
}


###################### queue-broker-inf ######################

data "aws_ecs_task_definition" "queue_broker_inf_task_def" {
  task_definition = "${var.queue_broker_inf_app_name}-${var.cluster_name}"
}

module "queue_broker_inf_ecs_service" {
  source                  = "./modules/ecs"
  family                  = "${var.queue_broker_inf_app_name}-${var.cluster_name}"
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 16384
  memory                  = 32768
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.queue_broker_inf_task_def.arn
  service_name            = var.queue_broker_inf_app_name
  cluster_id              = module.ecs.cluster_id
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         = [module.queue_inf_sg.sg_id]
  container_name          = var.queue_broker_inf_app_name
  container_port          = var.queue_broker_inf_container_port
  target_group_arn        = var.queue_broker_inf_target_group_arn
  assign_public_ip        = true
  force_new_deployment    = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-queue_broker_inf" {
  name              = var.queue_broker_inf_cloudwatch_log_path
  retention_in_days = 7
}


###################### queue-broker-time ######################
module "nlb_queue-broker-time-first" {
  source                = "./modules/nlb"
  lb_name               = "${var.cluster_name}-${var.queue_broker_time_app_name}-elb"
  internal              = false
  security_groups       = [module.queue_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.queue_broker_time_target_group_first_name
  target_group_port     = var.queue_broker_time_target_group_first_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.queue_broker_time_health_path

  tags = {
    Name = "${var.cluster_name}-${var.queue_broker_time_app_name}-elb"
  }
}
module "nlb_queue-broker-time-second" {
  source                = "./modules/nlb"
  lb_name               = "${var.cluster_name}-${var.queue_broker_time_app_name}-elb"
  internal              = false
  security_groups       = [module.queue_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.queue_broker_time_target_group_second_name
  target_group_port     = var.queue_broker_time_target_group_second_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.queue_broker_time_health_path

  tags = {
    Name = "${var.cluster_name}-${var.queue_broker_time_app_name}-elb"
  }
}
data "aws_ecs_task_definition" "queue_broker_time_task_def" {
  task_definition = "${var.queue_broker_time_app_name}-${var.cluster_name}"
}
module "queue-broker-time_ecs_service" {
  source                  = "./modules/ecs"
  family                  = var.queue_broker_time_app_name
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 1024
  memory                  = 2048
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.queue_broker_time_task_def
  service_name            = var.queue_broker_time_app_name
  cluster_id              = module.ecs.cluster_id
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         = [module.queue_broker_time_sg.sg_id]
  target_group_arn = [
    module.nlb_queue-broker-time-first.target_group_arn,
    module.nlb_queue-broker-time-second.target_group_arn
  ]
  container_name       = var.queue_broker_time_app_name
  container_port       = 5568
  assign_public_ip     = true
  force_new_deployment = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-queue-broker-time" {
  name              = var.queue_broker_time_cloudwatch_log_path
  retention_in_days = 7
}


################## queue-broker-bhs   ######################
module "nlb_queue-broker-bhs-first" {
  source                = "./modules/nlb"
  lb_name               = "${var.queue_broker_bhs_alb_name}"
  internal              = false
  security_groups       = [module.queue_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.queue_broker_bhs_target_group_first_name
  target_group_port     = var.queue_broker_bhs_target_group_first_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.queue_broker_bhs_health_path

  tags = {
    Name = "${var.cluster_name}-${var.queue_broker_bhs_app_name}-nlb"
  }
}
module "nlb_queue-broker-bhs-second" {
  source                = "./modules/nlb"
  lb_name               = "${var.queue_broker_bhs_alb_name}"
  internal              = false
  security_groups       =  [module.queue_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.queue_broker_bhs_target_group_second_name
  target_group_port     = var.queue_broker_bhs_target_group_second_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.queue_broker_bhs_health_path

  tags = {
    Name = "${var.cluster_name}-${var.queue_broker_bhs_app_name}-elb"
  }
}
data "aws_ecs_task_definition" "queue_broker_bhs_task_def" {
  task_definition = "${var.queue_broker_bhs_app_name}-${var.cluster_name}"
}
module "queue_broker_bhs_ecs_service" {
  source                  = "./modules/ecs"
  family                  = var.queue_broker_bhs_app_name
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 1024
  memory                  = 2048
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.queue_broker_bhs_task_def
  service_name            = var.queue_broker_bhs_app_name
  cluster_id              = module.ecs.cluster_id
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         =  [module.queue_bhs_sg.sg_id]
  target_group_arn = [
    module.nlb_queue-broker-time-first.target_group_arn,
    module.nlb_queue-broker-time-second.target_group_arn
  ]
  container_name       = var.queue_broker_bhs_app_name
  container_port       = 5568
  assign_public_ip     = true
  force_new_deployment = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-queue-broker-bhs" {
  name              = var.queue_broker_bhs_cloudwatch_log_path
  retention_in_days = 7
}
################## queue-broker-bhs-high-freq  ######################

module "nlb_queue-broker-bhs-high-freq-first" {
  source                = "./modules/nlb"
  lb_name               = "${var.queue_broker_bhs_high_freq_alb_name}"
  internal              = false
  security_groups       = [module.queue_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.queue_broker_bhs_high_freq_target_group_first_name
  target_group_port     = var.queue_broker_bhs_high_freq_target_group_first_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.queue_broker_bhs_high_freq_health_path

  tags = {
    Name = "${var.cluster_name}-${var.queue_broker_bhs_high_freq_app_name}-elb"
  }
}
module "nlb_queue-broker-bhs-high-freq-second" {
  source                = "./modules/nlb"
  lb_name               = "${var.cluster_name}-${var.queue_broker_bhs_high_freq_app_name}-elb"
  internal              = false
  security_groups       = [module.queue_lb_sg.sg_id]
  subnets               = module.vpc[0].public_subnet_ids
  certificate_arn       = var.certificate_arn
  target_group_name     = var.queue_broker_bhs_high_freq_target_group_second_name
  target_group_port     = var.queue_broker_bhs_high_freq_target_group_second_port
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc[0].main_vpc_id
  health_check_path     = var.queue_broker_bhs_high_freq_health_path

  tags = {
    Name = "${var.cluster_name}-${var.queue_broker_bhs_high_freq_app_name}-elb"
  }
}
data "aws_ecs_task_definition" "queue_broker_bhs_high_freq_task_def" {
  task_definition = "${var.queue_broker_bhs_high_freq_app_name}-${var.cluster_name}"
}
module "queue_broker_bhs_high_freq_ecs_service" {
  source                  = "./modules/ecs"
  family                  = var.queue_broker_bhs_high_freq_app_name
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 1024
  memory                  = 2048
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.queue_broker_bhs_high_freq_task_def
  service_name            = var.queue_broker_bhs_high_freq_app_name
  cluster_id              = module.ecs.cluster_id
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         = [module.queue_bhs_sg.sg_id]
  target_group_arn = [
    module.nlb_queue-broker-time-first.target_group_arn,
    module.nlb_queue-broker-time-second.target_group_arn
  ]
  container_name       = var.queue_broker_bhs_high_freq_app_name
  container_port       = var.queue_broker_bhs_high_freq_container_port
  assign_public_ip     = true
  force_new_deployment = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-queue_broker_bhs_high_freq" {
  name              = var.queue_broker_bhs_high_freq_cloudwatch_log_path
  retention_in_days = 7
}

################## queue-forwarder-predictions ######################
data "aws_ecs_task_definition" "queue_forwarder_predictions_task_def" {
  task_definition = "${var.queue_forwarder_predictions_app_name}-${var.cluster_name}"
}
module "queue_forwarder_predictions_ecs_service" {
  source                  = "./modules/ecs"
  family                  = var.queue_forwarder_predictions_app_name
  execution_role_arn      = var.ecs_task_execution_role
  task_role_arn           = var.ecs_task_execution_role
  cpu                     = 1024
  memory                  = 2048
  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"
  task_definition         = data.aws_ecs_task_definition.queue_forwarder_predictions_task_def
  service_name            = var.queue_forwarder_predictions_app_name
  cluster_id              = module.ecs.cluster_id
  desired_count           = 1
  subnets                 = module.vpc[0].public_subnet_ids
  security_groups         = [module.queue_forwarder_sg.sg_id]
  target_group_arn = [
    module.nlb_queue-broker-time-first.target_group_arn,
    module.nlb_queue-broker-time-second.target_group_arn
  ]
  container_name       = var.queue_forwarder_predictions_app_name
  container_port       = var.queue_forwarder_predictions_container_port
  assign_public_ip     = true
  force_new_deployment = true
}

resource "aws_cloudwatch_log_group" "ecs_log_group-queue-forwarder_predictions" {
  name              = var.queue_forwarder_predictions_cloudwatch_log_path
  retention_in_days = 7
}



##################### CLOUD MAP #####################

# resource "null_resource" "retrieve_task_details" {
#   for_each = toset(var.ecs_services)  

#   provisioner "local-exec" {
#     command = <<EOT
#       TASK_ARNS=$(aws ecs list-tasks --cluster ${module.ecs.cluster_id} --service-name ${each.value} --query "taskArns" --output text)
      
#       > /tmp/${each.value}.csv

#       for task_arn in $TASK_ARNS; do
#         ENI_ID=$(aws ecs describe-tasks --cluster ${module.ecs.cluster_id} --tasks $task_arn --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)
#         IP_ADDRESS=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query "NetworkInterfaces[0].PrivateIpAddress" --output text)
        
#         echo "$ENI_ID,$IP_ADDRESS" >> /tmp/${each.value}.csv
#       done
#     EOT
#   }

#   triggers = {
#     service_name = each.value
#   }
# }


# data "ecs-ip" "task_details" {
#   for_each = toset(var.ecs_services)

#   program = [
#     "bash", "-c", 
#     "cat /tmp/${each.value}.csv | jq -Rn '[inputs | split(\",\") | {instance_id: .[0], ip: .[1]}]'"
#   ]
#   depends_on = [null_resource.retrieve_task_details]
# }
# module "queue_http_proxy_cloud_map" {
#   for_each = toset(var.ecs_services)

#   source                          = "./modules/cloud_map"
#   cluster_name                    = var.cluster_name
#   aws_region                      = var.aws_region
#   aws_cloud_map_availability_zone = var.aws_cloud_map_availability_zone
#   namespace_id                    = aws_service_discovery_private_dns_namespace.main_cloud_map.id
#   service_name                    = each.value
#   ttl                             = 60
#   failure_threshold               = 1
#   instance_id                     = data.queue-http-proxy-ip.task_details[each.key].result[0].instance_id
#   aws_instance_ipv4               = data.queue-http-proxy-ip.task_details[each.key].result[0].ip
#   ecs_service_name                = each.value
#   ecs_task_definition_family      = "${each.value}-staging"
# }
# resource "queue-http-proxy-ip-null_resource" "cleanup_task_details" {
#   depends_on = [
#     queue-http-proxy-ip-null_resource.retrieve_task_details,
#     module.queue-http-proxy_cloud_map
#   ]
#   provisioner "local-exec" {
#     command = "rm -f /tmp/${var.queue_http_proxy_app_name}.csv"
#   }
# }

# ##################### ADMIN  #####################
# resource "admin-null-resource" "retrieve_task_details" {
#   depends_on = [module.admin_ecs_service]

#   provisioner "local-exec" {
#     command = <<EOT
#       TASK_ARNS=$(aws ecs list-tasks --cluster ${module.ecs.cluster_id} --service-name ${module.admin_ecs_service.service_name} --query "taskArns" --output text)
      
#       > /tmp/${var.admin_app_name}.csv

#       for task_arn in $TASK_ARNS; do
#         ENI_ID=$(aws ecs describe-tasks --cluster ${module.ecs.cluster_id} --tasks $task_arn --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)
#         IP_ADDRESS=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query "NetworkInterfaces[0].PrivateIpAddress" --output text)
        
#         echo "$ENI_ID,$IP_ADDRESS" >> /tmp/${var.admin_app_name}.csv
#       done
#     EOT
#   }
#   triggers = {
#     service_name = module.queue_http_proxy_ecs_service.service_name
#   }
# }

# data "admin-ip" "task_details" {
#   program = ["bash", "-c", "cat /tmp/${var.admin_app_name}.csv | jq -Rn '[inputs | split(\",\") | {instance_id: .[0], ip: .[1]}]'"]
#   depends_on = [admin-null-resource.retrieve_task_details]
# }
# module "admin_cloud_map" {
#   source                          = "./modules/cloud_map"
#   cluster_name                    = var.cluster_name
#   aws_region                      = var.aws_region
#   aws_cloud_map_availability_zone = var.aws_cloud_map_availability_zone
#   namespace_id                    = aws_service_discovery_private_dns_namespace.main_cloud_map.id
#   service_name                    = var.admin_app_name
#   ttl                             = 60
#   failure_threshold               = 1
#   instance_id                     = data.admin-ip.task_details.result[0].instance_id
#   aws_instance_ipv4               = data.admin-ip.task_details.result[0].ip
#   ecs_service_name                = var.admin_app_name
#   ecs_task_definition_family      = "${var.admin_app_name}-staging"
# }
# resource "admin-null-resource" "cleanup_task_details" {
#   depends_on = [
#     admin-null-resource.retrieve_task_details,
#     module.queue-http-proxy_cloud_map
#   ]

#   provisioner "local-exec" {
#     command = "rm -f /tmp/${var.admin_app_name}.csv"
#   }
# }

