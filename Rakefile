PATH = File.expand_path "..", __FILE__
require_relative 'env'

TF_ARGS = "-auto-approve"

BastionIP = -> {
  bastion_ip = File.read OUTPUT_PUBLIC_IP_PATH
  bastion_ip.strip
}

desc "main provision run"
task :run do
  sh "ruby provision-stack.rb"
end

namespace :template do
  desc "setup"
  task :setup do
    sh "terraform init"
  end

  desc "run"
  task :run do
    sh "terraform plan -out plan.json . && terraform apply #{TF_ARGS} plan.json"
  end
end

task default: :run

task "destroy - warning! destructive :)"
task :destroy do
  sh "cd #{PATH}/stacks/#{STACK_NAME} && terraform destroy"
end
