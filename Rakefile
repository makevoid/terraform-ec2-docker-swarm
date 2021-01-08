PATH = File.expand_path "..", __FILE__
require_relative 'env'

TF_ARGS = "-auto-approve"

OUTPUT_PUBLIC_IP_PATH     = "#{PATH}/stacks/env-#{STACK_ID}/output_bastion_public_ip.txt"
OUTPUT_ELB_HOSTNAME_PATH  = "#{PATH}/stacks/env-#{STACK_ID}/output_elb_hostname.txt"
OUTPUT_DB_HOSTNAME_PATH   = "#{PATH}/stacks/env-#{STACK_ID}/output_db_hostname.txt"

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

desc "provision"
task :provision do
  bastion_ip = BastionIP.()

  # copy_keys
  key_name = "id_env_azure_bas"

  puts system "cat ~/.ssh/#{key_name} | ssh admin@#{bastion_ip} 'cat >> .ssh/id_rsa && chmod 700 .ssh/id_rsa && echo \"Key copied\"'"

  # puts system "ssh admin@#{bastion_ip} ssh admin@#{vm1_ip} 'mkdir -p ~/api && cd ~/api && echo \"OK\" > ~/api/health && sudo python -m SimpleHTTPServer 80'"
end

def exe_vm(cmd, bas_ip:, vm: 1)
  bastion_ip = bas_ip
  vm_ip = "10.1.3.4"
  vm_ip = "10.1.4.4" if vm == 2
  ct = "-o ConnectTimeout=5 -o ConnectionAttempts=1"
  puts "executing: #{cmd}"
  system "ssh #{ct} admin@#{bastion_ip} \"bash -c 'ssh #{ct} admin@#{vm_ip} #{cmd}'\""
end

desc "test"
task :test do
  vm1_ip = "10.1.3.4" # private ip swarm master #1 (AZ A)
  vm2_ip = "10.1.4.4" # private ip swarm master #2 (AZ B)

  bastion_ip = BastionIP.()
  db_hostname = File.read OUTPUT_DB_HOSTNAME_PATH

  Thread.abort_on_exception = true

  debug = true

  ct = "-o ConnectTimeout=5 -o ConnectionAttempts=1"

  puts "checking bastion ssh and elb status:"
  bastion = nil
  t = Thread.new do
    # check bastion - TODO: refactor extract function
    bastion = system "ssh #{ct} admin@#{bastion_ip} uptime"
    puts bastion if debug
  end
  t.join

  # check elb - ...
  elb = system "curl -m 4 \"http://$(cat #{OUTPUT_ELB_HOSTNAME_PATH})\""
  puts elb if debug

  ip_present = system "ssh #{ct} admin@#{bastion_ip} \"ssh-keygen -F #{vm1_ip}\""
  unless ip_present
    # add ip - TODO: refactor - extract function
    exe %Q(ssh #{ct} admin@#{bastion_ip} "ssh-keyscan -H #{vm1_ip} >> ~/.ssh/known_hosts")
    exe %Q(ssh #{ct} admin@#{bastion_ip} "ssh-keyscan -H #{vm2_ip} >> ~/.ssh/known_hosts")
  end

  # check VMs
  vm1 = exe_vm "hostname", bas_ip: bastion_ip
  vm2 = exe_vm "hostname", bas_ip: bastion_ip, vm: 2
  if debug
    puts vm1
    puts vm2
  end

  nc_installed = exe_vm "socat -V", bas_ip: bastion_ip
  exe_vm "sudo apt-get update -y && sudo apt-get install -y socat", bas_ip: bastion_ip unless nc_installed

  # check db
  db = exe_vm "socat /dev/null TCP4:#{db_hostname}:5432,connect-timeout=2", bas_ip: bastion_ip

  puts "\n\nInfra:"
  puts "bastion: #{bastion_ip}"
  puts "vm1: #{vm1_ip}"
  puts "vm2: #{vm2_ip}"
  puts "db: #{db_hostname}"

  puts "\n\nInfra online:"
  puts "bastion: #{bastion}"
  puts "VM1: #{vm1}"
  puts "VM2: #{vm2}"
  puts "elb: #{elb}"
  puts "db: #{db}"
end
