# AutoScale Group
A simple NodeJS application with autoscaling infrastructure.

## What is this?
This is a simple NodeJS service that runs on a cluster of small AWS instances. I used Packer to
make an Amazon Machine Image (AMI) that is consumed by an Amazon Auto-Scaling Group (ASG). To help
manage elastic network flow, I stuck an Elastic Load Balancer (ELB) in front of the ASG to
evenly distribute traffic to every node in the ASG.

The ASG can be deployed through Terraform to any region, using multiple AZs to increase stability. I
have also set up this system so that in case one AZ goes down, the other AZ's ASG will scale up to
pick up the extra load.
