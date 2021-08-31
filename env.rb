require 'open3'
require 'ipaddr'
require 'yaml'

require_relative 'lib/cmd_lib'
require_relative 'lib/lib'

PATH = File.expand_path "../", __FILE__

STACK_ID = "02"
STACK_NAME = "env-#{STACK_ID}"

# static ips for deployed VMs
IP_VM_A = "10.1.3.4"
IP_VM_B = "10.1.4.4"

DEBUG = true

include CmdLib
include Lib
