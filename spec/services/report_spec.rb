require "rails_helper"
require "report"

RSpec.describe Report do
  describe '.print_default' do
    it 'prints grouped information and ranking' do
      parsed_info = {
        'game_1' => { 'kills' => { 'Player1' => 10, 'Player2' => 5 } },
        'game_2' => { 'kills' => { 'Player3' => 8, 'Player4' => 15 } }
      }

      expected_output = <<~EOS
        Grouped Information:
        #{parsed_info}
        Ranking:
        1 - Player4: 15
        2 - Player1: 10
        3 - Player3: 8
        4 - Player2: 5
      EOS

      expect { described_class.print_default(parsed_info) }
        .to output(expected_output).to_stdout
    end
  end

  describe Report::PlayerRanking do
    describe '#calculate' do
      it 'calculates player ranking' do
        parsed_info = {
          'game_1' => { 'kills' => { 'Player1' => 10, 'Player2' => 5 } },
          'game_2' => { 'kills' => { 'Player3' => 8, 'Player4' => 15 } }
        }

        player_ranking = described_class.new(parsed_info)
        result = player_ranking.calculate

        expect(result).to eq([['Player4', 15], ['Player1', 10], ['Player3', 8], ['Player2', 5]])
      end
    end
  end
end