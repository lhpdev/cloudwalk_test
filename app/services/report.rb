class Report
  def self.print_info_by_player(parsed_info_by_player)
    puts "Grouped Information:"
    puts parsed_info_by_player
    puts "Player Ranking:"
    PlayerRanking.new(parsed_info_by_player).calculate.each_with_index do |data, i|
      puts "#{i + 1} - #{data.first}: #{data.second}\n"
    end
  end

  def self.print_info_by_means(parsed_info_by_means)
    puts "Death by means count:"
    puts parsed_info_by_means
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
      ranking_hash.sort_by { |k, v| v }.reverse.to_h
    end
  end
end