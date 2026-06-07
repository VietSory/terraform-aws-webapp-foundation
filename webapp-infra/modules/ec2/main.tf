data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  user_data_replace_on_change = true

  user_data = <<-EOF_USER_DATA
              #!/bin/bash
              dnf update -y
              dnf install -y httpd

              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html lang="en">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Terraform AWS Webapp Foundation</title>
                <style>
                  body {
                    font-family: Arial, sans-serif;
                    background: #f4f7fb;
                    margin: 0;
                    padding: 0;
                  }
                  .container {
                    max-width: 820px;
                    margin: 70px auto;
                    background: white;
                    padding: 36px;
                    border-radius: 14px;
                    box-shadow: 0 4px 18px rgba(0,0,0,0.08);
                  }
                  h1 {
                    color: #173f6d;
                    margin-bottom: 10px;
                  }
                  .badge {
                    display: inline-block;
                    background: #e8f3ff;
                    color: #1261a0;
                    padding: 8px 12px;
                    border-radius: 20px;
                    font-weight: bold;
                  }
                  li {
                    margin: 10px 0;
                  }
                  code {
                    background: #f1f1f1;
                    padding: 2px 6px;
                    border-radius: 5px;
                  }
                </style>
              </head>
              <body>
                <div class="container">
                  <span class="badge">AWS Terraform Foundation</span>
                  <h1>Web application infrastructure deployed with Terraform</h1>
                  <p>This EC2 web server was provisioned from reusable Terraform modules.</p>
                  <ul>
                    <li>VPC created by Terraform module</li>
                    <li>EC2 deployed in a public subnet</li>
                    <li>RDS MySQL deployed in private subnets</li>
                    <li>S3 bucket stores static assets</li>
                    <li>Security Groups allow only required traffic</li>
                    <li>Terraform state is stored remotely in S3</li>
                  </ul>
                </div>
              </body>
              </html>
              HTML

              systemctl enable httpd
              systemctl start httpd
              EOF_USER_DATA

  tags = {
    Name = "${var.project_name}-web-server"
  }
}
