# Create security group for ALB
resource "aws_security_group" "web_alb_sg" {
  name_prefix = "web-alb-sg"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "web-alb Security Group"
  }
}

resource "aws_security_group_rule" "alb_ingress_rule_1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb_sg.id
}
resource "aws_security_group_rule" "alb_ingress_rule_2" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb_sg.id
}
resource "aws_security_group_rule" "alb_ingress_rule_3" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb_sg.id
}
resource "aws_security_group_rule" "alb_egress_rule_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb_sg.id
}

# Create security group for public instances
resource "aws_security_group" "public_sg" {
  name   = "public-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-sg"
  }
}
resource "aws_security_group_rule" "public_ingress_rule_1" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_alb_sg.id
  security_group_id        = aws_security_group.public_sg.id
}
resource "aws_security_group_rule" "public_ingress_rule_2" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_alb_sg.id
  security_group_id        = aws_security_group.public_sg.id
}
resource "aws_security_group_rule" "public_egress_rule_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
}

# Create security group for private instances
resource "aws_security_group" "private_sg" {
  name   = "private-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-sg"
  }
}
resource "aws_security_group_rule" "private_ingress_rule_1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_sg.id
}
resource "aws_security_group_rule" "private_ingress_rule_2" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_sg.id
  security_group_id        = aws_security_group.private_sg.id
}
resource "aws_security_group_rule" "private_ingress_rule_3" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_sg.id
  security_group_id        = aws_security_group.private_sg.id
}
resource "aws_security_group_rule" "private_egress_rule_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_sg.id
}
# Create security group for database instances
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "db-sg"
  }
}
resource "aws_security_group_rule" "db_ingress_rule_1" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.private_sg.id
  security_group_id        = aws_security_group.db_sg.id
}
resource "aws_security_group_rule" "db_egress_rule_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
}
