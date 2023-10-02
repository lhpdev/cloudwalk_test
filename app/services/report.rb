class Report
  def self.print_default(parsed_info)
    puts "Grouped Information:"
    puts parsed_info
    puts "Ranking:"
    PlayerRanking.new(parsed_info).calculate.each_with_index do |data, i|
      puts "#{i + 1} - #{data.first}: #{data.second}\n"
    end
  end

  class PlayerRanking
    def initialize(parsed_info)
      @parsed_info = parsed_info
    end

    def calculate
      ranking_hash = Hash.new(0)
      @parsed_info.map { |k, v| v["kills"] }.each do |kills|
        kills.each do |k, v|
          ranking_hash[k] += v
        end
      end
      ranking_hash.sort_by { |k, v| v }.reverse
    end
  end
end