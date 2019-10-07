provider "aws" {
  region = "${var.region}"
    profile = "${var.profile}"
}

resource "aws_launch_template" "example_temp" {
  name_prefix   = "${var.template_name}"
  image_id      = "${var.image_id}"
  instance_type = "t2.micro"
}


data "aws_availability_zones" "available" {}
resource "aws_autoscaling_group" "example_autoscalling_group" {
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id   = "${aws_launch_template.example_temp.id}"
        launch_template_name = "${aws_launch_template.example_temp.name_prefix}"
      }
      override {
        instance_type = "t2.micro"
    }
    override{
        instance_type = "t2.small"
    }
    }
    
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 1
    }
  }
  tag{
    key = "Autoscalling Group" 
    value = "Spot Instance and On Demand Instance"
    propagate_at_launch = true
  }
}
