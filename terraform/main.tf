provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# Public, unencrypted, unversioned S3 bucket
resource "aws_s3_bucket" "goof_bucket" {
  bucket = "goof-demo-bucket"
  acl    = "public-read"
}

# SSH and all ports open to the world
resource "aws_security_group" "goof_sg" {
  name        = "goof-sg"
  description = "Open security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
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

# EC2 with IMDSv1 and unencrypted root volume
resource "aws_instance" "goof_server" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.goof_sg.id]

  metadata_options {
    http_tokens = "optional"
  }

  root_block_device {
    encrypted = false
  }
}

# Public, unencrypted RDS with weak password
resource "aws_db_instance" "goof_db" {
  identifier          = "goof-db"
  engine              = "mysql"
  instance_class      = "db.t2.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = "password123"
  publicly_accessible = true
  storage_encrypted   = false
  skip_final_snapshot = true
}
