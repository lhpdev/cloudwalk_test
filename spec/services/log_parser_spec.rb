
require "rails_helper"
require "log_parser"

RSpec.describe LogParser do
  before do
    file_content = "InitGame\nKill: player1 killed player2 by MOD_RAILGUN\nInitGame\nKill: player2 killed player3 by MOD_RAILGUN\n"
    allow(File).to receive(:read).and_return(file_content)
  end

  describe ".generate_grouped_information_by_player" do
    subject {
      described_class.generate_grouped_information("sample_game_log.log.txt", kills_by_player: true)
    }

    it "should read and parse a game log file" do
      expect_any_instance_of(LogParser::Match).to receive(:parse)
      subject
    end
  end

  describe ".generate_grouped_information" do
    subject {
      described_class.generate_grouped_information("sample_game_log.log.txt", kills_by_player: false)
    }

    it "should read and parse a game log file" do
      expect_any_instance_of(LogParser::Match).to receive(:parse)
      subject
    end
  end


  describe LogParser::Match do
    describe "#kills_by_player" do
      before do
        @match_parser = described_class.new(file_content, kills_by_player: true)
      end

      let(:file_content) { "InitGame\nKill: player1 killed player2 by MOD_RAILGUN\nInitGame\nKill: player2 killed player3 by MOD_RAILGUN\n" }

      it "should read and parse a game log file correctly" do
        result = @match_parser.parse
        expect(result).to be_a(Hash)
        expect(result).to have_key("game_1")
        expect(result).to have_key("game_2")
        expect(result).to_not have_key("game_3")
      end

      context "when game logs includes more than one match" do
        let(:file_content) { "InitGame\nKill: player1 killed player2 by MOD_RAILGUN\nKill: player3 killed player4 by MOD_RAILGUN\nInitGame\nKill: player1 killed player2\nKill: player3 killed player1 by MOD_RAILGUN\n" }

        it "should read and parse a game log file correctly" do
          result = @match_parser.parse
          expect(result).to have_key("game_1")
          expect(result).to have_key("game_2")
          expect(result["game_1"]["total_kills"]).to eq(2)
          expect(result["game_1"]["players"]).to eq(["player1", "player2", "player3", "player4"])
          expect(result["game_1"]["kills"]).to eq({ "player1" => 1, "player3" => 1 })
          expect(result["game_2"]["total_kills"]).to eq(2)
          expect(result["game_2"]["players"]).to eq(["player1", "player2", "player3"])
          expect(result["game_2"]["kills"]).to eq({ "player1" => 1, "player3" => 1 })
        end
      end

      context "when logs include only matches with no kills" do
        let(:file_content) { "InitGame\n" }

        it "should return default values when no kills" do
          result = @match_parser.parse
          expect(result["game_1"]["total_kills"]).to eq(0)
          expect(result["game_1"]["players"]).to be_empty
          expect(result["game_1"]["kills"]).to be_empty
        end
      end

      context "when there is a <world> killer in play" do
        let(:file_content) { "InitGame\nKill: player1 killed player2 by MOD_RAILGUN\nKill: player2 killed player3 by MOD_RAILGUN\nKill: <world> killed player2 by MOD_RAILGUN\nKill: <world> killed player4 by MOD_RAILGUN" }

        it "should parse kill information" do
          result = @match_parser.parse
          expect(result["game_1"]["kills"]["player1"]).to eq(1)
          expect(result["game_1"]["kills"]["player2"]).to eq(0)
          expect(result["game_1"]["kills"]["player4"]).to eq(-1)
        end
      end
    end

    describe "#kills_by_means" do
      before do
        @match_parser = described_class.new(file_content, kills_by_player: false)
      end

      let(:file_content) { "InitGame\nKill: player1 killed player2 by MOD_RAILGUN\nInitGame\nKill: player2 killed player3 by MOD_RAILGUN\n" }

      it "should read and parse a game log file correctly" do
        result = @match_parser.parse
        expect(result).to be_a(Hash)
        expect(result).to have_key("game_1")
        expect(result).to have_key("game_2")
        expect(result).to_not have_key("game_3")
      end

      context "when game logs includes more than one match" do
        let(:file_content) { "InitGame\nKill: player1 killed player2 by MOD_RAILGUN\nKill: player3 killed player4 by MOD_ROCKET\nKill: player1 killed player2 by MOD_ROCKET\nKill: player3 killed player1 by MOD_ROCKET\n" }

        it "should read and parse a game log file correctly" do
          result = @match_parser.parse
          expect(result).to have_key("game_1")
          expect(result["game_1"]["kills_by_means"]).to eq({"MOD_ROCKET"=>3, "MOD_RAILGUN" => 1 })
        end
      end

      context "when logs include only matches with no kills" do
        let(:file_content) { "InitGame\n" }

        it "should return default values when no kills" do
          result = @match_parser.parse
          expect(result["game_1"]["kills_by_means"]).to eq({})
        end
      end
    end
  end
end