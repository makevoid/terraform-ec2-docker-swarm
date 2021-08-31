require_relative 'env'

def prepare(rm:)
  create_stack_dir rm: rm
end

def execute_tf
  puts system "cd #{stack_dir} && terraform init"
  exe "cd #{stack_dir} && terraform plan -out plan.json . && terraform apply -auto-approve plan.json"
end

def ssh_config_parse(ssh_config_local:)
  split = ssh_config_local.split /--\(sd\)---/
  split_2 = "\n\n#{split[2]}" if split[2] && split[2] != "" && split[2] != "\n"
  ssh_host_config = "#{split[0]}#{split_2}\n"
  "#{ssh_host_config}#{ssh_config_new}"
end


def clone_provisioner
  exe "cd #{PATH}/vendor && git clone #{PROVISIONER_GIT_URI}"
  pull = "git checkout #{PROVISIONER_BRANCH} && git pull origin #{PROVISIONER_BRANCH} --rebase=false"
  exe "cd #{PATH}/vendor/provisioner && #{pull}"
end

def provisioner_configure_vms
  ips = "IP_A=#{IP_VM_A} IP_B=#{IP_VM_B}"
  exe "cd #{PATH}/vendor/provisioner/vm && CLI_RUN=1 #{ips} rake"
end

def provision_database
  exe "STACK_ID=#{STACK_ID} rake psql:create"
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

def deployer_setup_secrets
  exe "scp #{PATH}/config/secrets/deployer-env.sh root@#{IP_VM_A}:deployer-env.sh"
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
end

main
