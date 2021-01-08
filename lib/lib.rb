module Lib

  def stack_dir
    "#{PATH}/stacks/#{STACK_NAME}"
  end

  def create_stack_dir rm: true
    puts "prepare" if DEBUG
    if rm
      puts "resetting local terraform state"
      puts system "rm -rf #{stack_dir}"
    end
    puts system "mkdir -p #{stack_dir}"
  end

  def write_stack_file(plan_file:)
    plan = File.read plan_file
    file_name = File.basename plan_file
    plan.gsub! /env-01/, STACK_NAME
    File.open("#{stack_dir}/#{file_name}.tf", "w"){ |f| f.write plan }
  end

  def write_stack_files
    puts "write stack" if DEBUG
    plan_files = Dir.glob "#{PATH}/*.tf"
    plan_files.each do |plan_file|
      write_stack_file plan_file: plan_file
    end
  end

end
