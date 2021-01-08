module CmdLib
  def exe(cmd, debug: true)
    puts "executing: #{cmd}" if debug
    Open3.popen3(cmd) do |stdin, stdout, stderr, process|
      [stdout, stderr].each do |stream|
        Thread.new do
          until (line = stream.gets).nil? do
            puts line
          end
        end
      end
      process.join
    end
  end
end
