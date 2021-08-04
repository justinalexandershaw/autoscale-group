// The packer block contains Packer settings, including specifying a required Packer version. The
// required_plugins block specifies the plugins required to build your image. 
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

// The source block configures a specific builder plugin, which is then invoked by a build block.
source "amazon-ebs" "ubuntu" {
  ami_name      = "node-ami-test-1234567890"
  instance_type = "t2.micro"
  region        = "us-west-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

// The build block defines what Packer should do with the Docker container after it launches.
build {
  name = "nodejs-ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  // Using provisioners allows you to completely automate modifications to your image. You can use
  // shell scripts, file uploads, and integrations with modern configuration management tools such
  // as Chef or Puppet.
  provisioner "shell" {
    inline = [
      "curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "sudo apt-get install -y npm",
    ]
  }
}

