provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  cidr_block                = var.vpc_cidr_block
  public_subnet_cidr_block_1 = var.public_subnet_cidr_block_1
  public_subnet_cidr_block_2 = var.public_subnet_cidr_block_2
  private_subnet_cidr_block_1 = var.private_subnet_cidr_block_1
  private_subnet_cidr_block_2 = var.private_subnet_cidr_block_2
  availability_zone_1       = var.availability_zone_1
  availability_zone_2       = var.availability_zone_2
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH traffic from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "jenkins_gitea_sg" {
  name        = "jenkins_gitea_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "jenkins_gitea_server" {
  source        = "./modules/ec2"
  ami           = var.jenkins_ami
  instance_type = var.jenkins_instance_type
  subnet_id     = element(module.vpc.private_subnets, 0)
  name          = "jenkins-gitea-server"
  key_name      = var.ssh_key_name_private
  security_group_ids = [aws_security_group.jenkins_gitea_sg.id]

  volume_size           = 16
  volume_type           = "gp3"
  delete_on_termination = true
}

module "bastion_host" {
  source        = "./modules/ec2"
  ami           = var.bastion_host_ami
  instance_type = var.bastion_host_instance_type
  subnet_id     = element(module.vpc.public_subnets, 0)
  name          = "bastion-host"
  key_name      = var.ssh_key_name_public
  security_group_ids = [aws_security_group.bastion_sg.id]
  volume_size           = 8
  volume_type           = "gp3"
  delete_on_termination = true
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins_gitea_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    interval            = 30
    path                = "/login"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "jenkins_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }

  condition {
    path_pattern {
      values = ["/jenkins/*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "jenkins_app" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = module.jenkins_gitea_server.instance_id
  port             = 8080
}