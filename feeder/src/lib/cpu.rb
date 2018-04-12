# Reabrindo classe da gem systeminformation para:
# 1. Desconsiderar estatísticas individuais de CPUs
# 2. Reportar steal (presente em '/proc/stat' desde o Linux 2.6.11 - REF: https://bit.ly/2jGKrRd)
# 3. Reportar cálculo de utilização da CPU com base em # REF: https://bit.ly/2HwrDMm

class SystemInformation::Linux::CPU
  def initialize
    @prev_data = read_data
  end

  def utilization
    new_data = read_data
    diff = @prev_data.zip(new_data).map{ |i| i[1] - i[0] }
    sum = diff.inject{|a,b| a+b}
    diff.map!{ |i| i/sum }.map!{ |i| i.nan? ? 0 : i }
    @prev_data = new_data
    
    {
      user:       diff[0],
      nice:       diff[1],
      system:     diff[2],
      idle:       diff[3],
      iowait:     diff[4],
      irq:        diff[5],
      softirq:    diff[6],
      steal:      diff[7], # REF: https://bit.ly/2jGKrRd
      guest:      diff[8],
      guest_nice: diff[9],
      usage:      diff.select.each_with_index{ |el, i| [0, 1, 2, 5, 6].include? i }.sum # REF: https://bit.ly/2HwrDMm
    }
  end

  private

  def read_data
    File.readlines('/proc/stat').grep(/^cpu /).first.split[1..-1].map(&:to_f)
  end
end
