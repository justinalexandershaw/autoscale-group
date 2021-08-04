data "aws_ami" "from_packer" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
}

resource "aws_launch_configuration" "main" {
  name          = "web_config"
  image_id      = data.aws_ami.from_packer.id
  instance_type = "t2.micro"
}
