# Although this script is running within a container, comands such as free
# report system status data (rathen than container one).
# 
# REF: https://shuheikagawa.com/blog/2017/05/27/memory-usage/

require 'statsd-ruby'
require 'docker'
require 'systeminformation'
require_relative 'lib/cpu'
require_relative 'lib/disk'

$statsd = Statsd.new 'monitor-data', 8125
$hostname = Docker.info["Name"][/\w+/] # Obtém nome do subdomínio (homolog; radar...)

STDERR.puts "#{Time.now} Starting Monitor of System Resources"

# /proc/meminfo
# [0.0, 1.0]
def report_memory_usage
  mmry = SystemInformation.memory
  $statsd.gauge "#{$hostname}.system.memory.usage", mmry[:used].to_f / mmry[:total]
end

# /proc/stat
# [0.0, 1.0]
def report_cpu_and_steal_usage
  usage = SystemInformation.cpu
  $statsd.gauge "#{$hostname}.system.cpu.usage", usage[:usage]
  $statsd.gauge "#{$hostname}.system.cpu.steal", usage[:steal]
end

# /proc/loadavg
# [0.0, INFINITY]
def report_load_avg_time
  $statsd.gauge "#{$hostname}.system.load.avg1min", SystemInformation.load[:load_1]
  $statsd.gauge "#{$hostname}.system.load.avg5min", SystemInformation.load[:load_5]
  $statsd.gauge "#{$hostname}.system.load.avg15min", SystemInformation.load[:load_15]
end

# df
# [0.0, 1.0]
def report_disk_usage
  Disk.perc_usage.each_pair do |disk, details|
    $statsd.gauge "#{$hostname}.system.disk.#{disk}", details[:used_perc]
  end
end

while true
  # Ignorando primeira obtenção de dados da CPU.
  # REF: https://github.com/tliff/systeminformation/blob/master/lib/systeminformation.rb#L22
  SystemInformation.cpu

  sleep 60

  begin
    report_memory_usage
    report_cpu_and_steal_usage
    report_load_avg_time
    report_disk_usage
  rescue => e
    STDERR.puts e
    STDERR.puts e.backtrace
  end

end
