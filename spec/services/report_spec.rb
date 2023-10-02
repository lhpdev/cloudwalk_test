require "rails_helper"
require "report"

RSpec.describe Report do
  describe ".print_info_by_player" do
    it "prints grouped information and ranking" do
      parsed_info = {
        "game_1" => { "kills" => { "Player1" => 10, "Player2" => 5 } },
        "game_2" => { "kills" => { "Player3" => 8, "Player4" => 15 } }
      }

      expected_output = <<~EOS
        Grouped Information:
        #{parsed_info}
        Player Ranking:
        1 - Player4: 15
        2 - Player1: 10
        3 - Player3: 8
        4 - Player2: 5
      EOS

      expect { described_class.print_info_by_player(parsed_info) }
        .to output(expected_output).to_stdout
    end
  end

  describe ".print_info_by_means" do
    it "prints deaths by means" do
      parsed_info = {
        "game_1" => { "kills_by_means" => { "MOD_ROCKET"=>2, "MOD_RAILGUN" => 0 } },
        "game_2" => { "kills_by_means" => { "MOD_ROCKET"=>3, "MOD_RAILGUN" => 1 } }
      }

      expected_output = <<~EOS
        Death by means count:
        #{parsed_info}
      EOS

      expect { described_class.print_info_by_means(parsed_info) }
        .to output(expected_output).to_stdout
    end
  end

  describe Report::PlayerRanking do
    describe "#calculate" do
      it "calculates player ranking" do
        parsed_info = {
          "game_1" => { "kills" => { "Player1" => 10, "Player2" => 5 } },
          "game_2" => { "kills" => { "Player3" => 8, "Player4" => 15 } }
        }

        player_ranking = described_class.new(parsed_info)
        result = player_ranking.calculate

        expect(result).to eq({ "Player4" => 15, "Player1" => 10, "Player3" => 8, "Player2" => 5 })
      end
    end
  end
end