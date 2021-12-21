data "aws_availability_zones" "az" {
  state = "available"
}

# ceating ec2-instance 
resource "aws_instance" "ipstack-serv" {
  ami           = var.ami-id
  instance_type = var.type
  associate_public_ip_address = true
  key_name = aws_key_pair.ipstack.id
  security_groups = [aws_security_group.ipstack-sg.name]
  availability_zone = data.aws_availability_zones.az.names[0]
  user_data = file ("setup.sh")

  tags = {
    Name = "${var.project}-instance"
    Project = var.project
  }
}

#create target group -1
resource "aws_lb_target_group" "ipstack-tg" {
  name     = "ipstack-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id

  tags = {
    Name = "${var.project}-tg"
    Project = var.project
  }
}

## Adding instance on 8081 to target group
resource "aws_lb_target_group_attachment" "tgr1" {
  target_group_arn = aws_lb_target_group.ipstack-tg.arn
  target_id        = aws_instance.ipstack-serv.id
  port             = 8081
}

## Adding instance on 8082 to target group
resource "aws_lb_target_group_attachment" "tgr2" {
  target_group_arn = aws_lb_target_group.ipstack-tg.arn
  target_id        = aws_instance.ipstack-serv.id
  port             = 8082
}

## Adding instance on 8083 to target group
resource "aws_lb_target_group_attachment" "tgr3" {
  target_group_arn = aws_lb_target_group.ipstack-tg.arn
  target_id        = aws_instance.ipstack-serv.id
  port             = 8083
}

# application LB
resource "aws_lb" "ipstack-alb" {
  name               = "ipstack-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ipstack-sg.id]
  subnets = data.aws_subnet_ids.vpc.ids
  depends_on = [ aws_lb_target_group.ipstack-tg]


    tags = {
     Name = "${var.project}-lb"
   }
}

#create - Listener1 : Fixed response rule
resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.ipstack-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  depends_on = [  aws_lb.ipstack-alb ]
}

# Listener - HTTPS
resource "aws_lb_listener" "listener-https" {
  load_balancer_arn = aws_lb.ipstack-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert-arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ipstack-tg.arn
  }
  }
