module Disk
  def self.perc_usage
    {}.tap do |disks|
      `df`.split("\n")[1..-1].each do |line|
        line = line.split
        next if line[0] == 'tmpfs'

        disks[line[0]] = {
          size: to_gigabytes(line[1].to_f),
          used: to_gigabytes(line[2].to_f),
          avail: to_gigabytes(line[3].to_f),
          used_perc: line[4].to_f,
          mounted_on: line[5]
        }
      end
    end
  end

  private

  def self.to_gigabytes(float_num) float_num / 1024 ** 2 end
end
