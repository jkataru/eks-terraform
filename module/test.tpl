resource "admin" {
module  = alb 
}

resource "nlb" {
module  = alb 
}


ouput = alb.arn

ouput = nlb.arn

resource "admin taskdef"{ 

module = ecs
target-group-arn = nlb.arn

}

