resource "aws_key_pair" "tf_apps" {
  key_name   = "tf-key"
  public_key = file("${path.module}/id_rsa.pub")
}

# Create load balancer
resource "aws_lb" "web_lb" {
  name               = "web-lb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [aws_subnet.public_01.id, aws_subnet.public_02.id] # [for subnet in aws_subnet.public : subnet.id]
  security_groups    = [aws_security_group.web_alb_sg.id]
  # cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "web_target_group" {
  name = "web-target-group"
  # target_type = "alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
  }
}

resource "aws_autoscaling_group" "web_autoscaling_group" {
  name                      = "web-autoscaling-group"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.public_01.id, aws_subnet.public_02.id]
  target_group_arns         = [aws_lb_target_group.web_target_group.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.nginx01.id
    version = "$Latest"
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

resource "aws_launch_template" "nginx01" {
  name_prefix            = "nginx01"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = "tf-key"

  user_data = base64encode("${path.module}/web-install.sh")

}

# Encode the user data in Base64
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_lb" "apps_lb" {
  name               = "apps-lb"
  load_balancer_type = "application"
  internal           = true
  subnets            = [aws_subnet.private_01.id, aws_subnet.private_02.id] # [for subnet in aws_subnet.public : subnet.id]
  # cross_zone_load_balancing = true
  # security_groups    = [aws_security_group.web_alb_sg.id]
}

resource "aws_lb_listener" "apps_listener" {
  load_balancer_arn = aws_lb.apps_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apps_target_group.arn
  }
}

resource "aws_lb_target_group" "apps_target_group" {
  name = "apps-target-group"
  # target_type = "alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
  }
}

resource "aws_launch_template" "apps_server" {
  name_prefix            = "appserver01"
  image_id               = "ami-06ca3ca175f37dd66"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = "tf-key"

  user_data = base64encode("${path.module}/apps-install.sh")
  
}

resource "aws_autoscaling_group" "apps_autoscaling_group" {
  name                      = "apps-autoscaling-group"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.private_01.id, aws_subnet.private_02.id]
  target_group_arns         = [aws_lb_target_group.apps_target_group.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.apps_server.id
    version = "$Latest"
  }
}

# Create RDS instance
resource "aws_db_instance" "db_instance" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  db_name                = "mydatabase"
  username               = "admin"
  password               = "mypassword"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}