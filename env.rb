require 'open3'
require 'ipaddr'
require 'yaml'

require_relative 'lib/cmd_lib'
require_relative 'lib/lib'
require_relative 'lib/deployer_config'

PATH = File.expand_path "../", __FILE__

STACK_ID = "02"
STACK_NAME = "env-#{STACK_ID}"

# static ips for deployed VMs
IP_VM_A = "10.1.3.4"
IP_VM_B = "10.1.4.4"

DEBUG = true

PROVISIONER_GIT_URI = "git@github.com:appliedblockchain/provisioner" # development - Provisioner (VM provisioner) is open source already
PROVISIONER_BRANCH = "master"

# AB's AWS account default VPC
AWS_DEFAULT_VC = ""

DEPLOYER_HOST = "deployer.abtech.dev"

DEPLOYER_CONFIG_GIT_URI = "git@github.com:makevoid/deployer-config" # NOTE: not open source yet

DEPLOYER_CONFIG_STACK_CONF = {
  stack_name: "docker-app",
  github_repo: "docker-app",
  containers: [
    "docker-app",
    "nginx",
    "redis",
  ]
}

include CmdLib
include Lib
include DeployerConfig
