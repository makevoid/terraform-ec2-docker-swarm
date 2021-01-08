
# azure-terraform-swarm-template

This is a Docker Swarm terraform configurator for azure

Main Targets:
- highly available environment
- docker swarm based

Docker Swarm is an easy step from Compose and it's a good hosted cluster solution as Kubernetes becomes easier and easier to configure, use, more containerd tooling etc. and you're ready to transition to it.

Docker Swarm is a good middle ground, you know what's happening (as you can ssh into the vm and run `docker ps`, `docker logs`, `docker inspect`, `docker attach`, `docker exec` etc).

This repo is a terraform definition which should be a good start as it's focused on high availability, ease of use and allows for vertical scaling with a configuration change and a `terraform` `plan` + `apply` command.

Feedback is welcome, feel free to open an issue.


#### Configure

Configure terraform to work with your AWS account

Replace
https://github.com/makevoid/aws-infra-1/blob/master/init.tf#L21
with your ssh key name


#### Run


    rake

This will configure the docker swarm aws infrastructure via terraform and plan / apply straight away.

Enjoy your fresh docker swarm cluster :) 


### Open Source

Feel free to open an issue to see if this worked for you or not, if you think you can contribute, open a pull request with your desired improvement.
