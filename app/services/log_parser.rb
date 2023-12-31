class LogParser
  def self.generate_grouped_information(file_name="game_log.log.txt", kills_by_player: true)
    file_path = Rails.root.join("public", "game_logs", file_name)
    file_content = File.read(file_path)
    matches_parser = Match.new(file_content, kills_by_player: kills_by_player)
    parsed_matches = matches_parser.parse
  end

  class Match
    def initialize(file_content, kills_by_player: true)
      @file_content = file_content
      @kills_by_player = kills_by_player
    end

    def parse
      matches = split_into_matches(@file_content)
      group_info_by_match(matches)
    end

    private

    def split_into_matches(text)
      matches = text.split(/(?=#{Regexp.escape("InitGame")})/).filter { |potential_match| potential_match.include?("InitGame") }
    end

    def group_info_by_match(matches)
      result = {}
      matches.each_with_index do |match, i|
        result["game_#{i+1}"] = parse_kills_info(match)
      end
      result
    end

    def parse_kills_info(match)
      if match.include?("killed")
        kills = match.split("\n").filter { |potential_kill| potential_kill.include?("Kill:") }
        return @kills_by_player ? parse_kills_by_player(kills) : parse_kills_by_means(kills)
      end

      return @kills_by_player ? {
        "total_kills" => 0,
        "players" => [],
        "kills" => {}
      } : {
        "kills_by_means" => {}
      }
    end

    def parse_kills_by_player(kills)
      result = kills.each_with_object({
        "total_kills" => kills.length,
        "players" => [],
        "kills" => Hash.new(0)
      }) do |game_kill, data|
        array = game_kill.split(" ")
        reference_index = array.index("killed")
        killer_player = array[reference_index - 1]
        killed_player = array[reference_index + 1]

        if killer_player == "<world>"
          data["kills"][killed_player] -= 1
        else
          data["players"].push(killer_player) unless data["players"].include?(killer_player)
          data["kills"][killer_player] += 1
        end

        data["players"].push(killed_player) unless data["players"].include?(killed_player)
      end

      result
    end

    def parse_kills_by_means(kills)
      result = kills.each_with_object({
        "kills_by_means" => Hash.new(0)
      }) do |game_kill, data|
        array = game_kill.split(" ")
        reference_index = array.index("by")
        kill_reason = array[reference_index + 1]
        data["kills_by_means"][kill_reason] += 1
      end

      result
    end
  end
end