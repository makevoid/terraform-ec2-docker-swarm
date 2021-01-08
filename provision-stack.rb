require_relative 'env'

def prepare(rm:)
  create_stack_dir rm: rm
end

def execute_tf
  puts system "cd #{stack_dir} && terraform init"
  exe "cd #{stack_dir} && terraform plan -out plan.json . && terraform apply -auto-approve plan.json"
end

SSH_CONFIG_LOCAL_PATH = File.expand_path "~/.ssh/config"

def update_ssh_config
  ssh_config_orig = File.read SSH_CONFIG_LOCAL_PATH
  ssh_config = ssh_config_parse ssh_config_local: ssh_config_orig
  # p ssh_config if DEBUG
  File.open("#{SSH_CONFIG_LOCAL_PATH}.bak", "w")  { |f| f.write ssh_config_orig }
  File.open(SSH_CONFIG_LOCAL_PATH, "w")           { |f| f.write ssh_config      }
end

def ssh_config_parse(ssh_config_local:)
  split = ssh_config_local.split /--\(sd\)---/
  split_2 = "\n\n#{split[2]}" if split[2] && split[2] != "" && split[2] != "\n"
  ssh_host_config = "#{split[0]}#{split_2}\n"
  "#{ssh_host_config}#{ssh_config_new}"
end

def ssh_config_new
  "# ---(sd)---
# ENV-02 - Docker Swarm Terraform cluster

Host #{STACK_NAME}-bas.sdata.run
  User azureuser
  IdentityFile ~/.ssh/id_env_deployer1

Host #{IP_VM_A}
  User azureuser
  ProxyCommand ssh -W %h:%p #{STACK_NAME}-bas.sdata.run
  IdentityFile ~/.ssh/id_env_azure_bas

Host #{IP_VM_B}
  User azureuser
  ProxyCommand ssh -W %h:%p #{STACK_NAME}-bas.sdata.run
  IdentityFile ~/.ssh/id_env_azure_bas

# ---(sd)---
"
end

def ssh_config_deployer
  "
# ENV-02 - Docker Swarm Terraform cluster
Host #{STACK_NAME}-bas.sdata.run
  User azureuser

Host #{IP_VM_A}
  User azureuser
  ProxyCommand ssh -W %h:%p #{STACK_NAME}-bas.sdata.run
  IdentityFile ~/.ssh/id_env_azure_bas

Host #{IP_VM_B}
  User azureuser
  ProxyCommand ssh -W %h:%p #{STACK_NAME}-bas.sdata.run
  IdentityFile ~/.ssh/id_env_azure_bas
"
end

def clone_provisioner
  exe "cd #{PATH}/vendor && git clone #{PROVISIONER_GIT_URI}"
  pull = "git checkout #{PROVISIONER_BRANCH} && git pull origin #{PROVISIONER_BRANCH} --rebase=false"
  exe "cd #{PATH}/vendor/provisioner && #{pull}"
end

def ssh_check
  puts "if this command hangs it means your setup is "
  exe "ssh #{IP_VM_A} uptime"
end

def provisioner_configure_vms
  ips = "IP_A=#{IP_VM_A} IP_B=#{IP_VM_B}"
  exe "cd #{PATH}/vendor/provisioner/vm && CLI_RUN=1 #{ips} rake"
end

def provision_database
  exe "STACK_ID=#{STACK_ID} rake psql:create"
end

def print_ssh_check_instructions
  # TODO: automate as we automated it for the bastion host
  puts "
  # execute these commands once to register the current VMs ssh keys
  ssh-keygen -f \"$HOME/.ssh/known_hosts\" -R \"#{STACK_NAME}-bas.sdata.run\"
  ssh-keygen -f \"$HOME/.ssh/known_hosts\" -R \"#{IP_VM_A}\"
  ssh-keygen -f \"$HOME/.ssh/known_hosts\" -R \"#{IP_VM_B}\"

  # execute these two individually on another terminal, add the host key and exit (press Ctrl-C there) for both
  ssh #{IP_VM_A}
  ssh #{IP_VM_B}

  # press Enter to proceed
  "
end

def prereqs_check_jq_installed
  exe "echo  \"{}\" | jq"
end

def prereqs_check_aws_cli
  exe "aws --version"
end

def prereqs_check_tf_cli
  exe "terraform version"
end

# check that the default vpc exists in our account
def prereqs_check_aws_config
  exe "aws ec2 describe-vpcs | jq -e '.Vpcs[0] | select(.VpcId==\"#{AWS_DEFAULT_VC}\")'"
end

def prereqs_check_tf_config
  # TODO:
  # exe "terraform "
end

def prereqs_check
  prereqs_check_jq_installed
  prereqs_check_aws_cli
  prereqs_check_tf_cli
  prereqs_check_aws_config
  prereqs_check_tf_config
end

def deployer_setup_ssh
  deployer = "root@#{DEPLOYER_HOST}"
  bastion = "#{STACK_NAME}-bas.sdata.run"

  File.open("#{PATH}/tmp/deployer-ssh-config.txt", "w") { |f| f.write ssh_config_deployer }
  exe "scp #{PATH}/tmp/deployer-ssh-config.txt #{deployer}:.ssh/config"

  # clear existing known hosts
  exe %Q(ssh #{deployer} "ssh-keygen -R \\"#{bastion}\\"")
  exe %Q(ssh #{deployer} "ssh-keygen -R \\"#{IP_VM_A}\\"")
  exe %Q(ssh #{deployer} "ssh-keygen -R \\"#{IP_VM_B}\\"")

  # add new key fingerprints to known hosts
  exe %Q(ssh #{deployer} "ssh-keyscan -H #{bastion} >> ~/.ssh/known_hosts")
  exe %Q(ssh #{deployer} "ssh #{bastion} \\"ssh-keyscan -H #{IP_VM_A}\\" >> ~/.ssh/known_hosts")
  exe %Q(ssh #{deployer} "ssh #{bastion} \\"ssh-keyscan -H #{IP_VM_B}\\" >> ~/.ssh/known_hosts")
end

def deployer_setup_secrets
  exe "scp #{PATH}/config/secrets/deployer-env.sh root@#{IP_VM_A}:deployer-env.sh"
end

def dns_setup_bastion
  bastion_ip = File.read "#{stack_dir}/output_bastion_ip.txt"
  bastion_domain = "#{STACK_NAME}-bas"
  exe "cd #{PATH}/dns && SUBDOMAIN=#{bastion_domain} IP=#{bastion_ip} rake"
end

def dns_setup_app_gateway
  app_gateway_ip = File.read "#{stack_dir}/output_app_gateway_ip.txt"
  app_gateway_domain = STACK_NAME
  exe "cd #{PATH}/dns && SUBDOMAIN=#{app_gateway_domain} IP=#{app_gateway_ip} rake"
end

def dns_setup
  dns_setup_bastion
  dns_setup_app_gateway
  puts "waiting for the DNS to be propagated... (90s)"
  sleep 90
end

def main
  # NOTE: make sure all these lines are uncommented :D

  puts "Prerequisites"
  prereqs_check

  puts "Setup"
  # prepare rm: true  # set up the infra from scratch removing the last state and reprovisioning everything all the time (you need to delete the resource group)
  prepare rm: false

  puts "Terraform"
  write_stack_files
  execute_tf

  exit

  puts "DNS"
  dns_setup

  puts "Provisioning"
  clone_provisioner # todo move to prepare
  update_ssh_config

  print_ssh_check_instructions
  gets

  ssh_check
  provisioner_configure_vms

  puts "Deployer config"
  domain = "#{STACK_NAME}.sdata.run"
  deployer_config_update domain: domain, stack_name: STACK_NAME

  puts "DB"
  provision_database

  puts "Setup Deployer SSH"
  deployer_setup_ssh
  deployer_setup_secrets
end

# TODO

# add load balancer
# - run terraformer
# - customize and integrate plan
# - run dnsimple to connect to ip / cname
# run healthchecks (unit test)
# add database
# clone and add sgx vms
# documentation - github markdown
# profit!

# ---

# ssh- add hosts - take from provisioner
# run an ssh command to validate

main
