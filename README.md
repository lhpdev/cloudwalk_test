# README

In order to get the required outputs from the assessment description please follow the next steps

1 - Setup the project

2 - Once the project is setup, then please open rails console and run:

"require 'log_parser'"
"LogParser.generate_grouped_information"

The previous command will parse the game log file provided by default and generate the outcome from Task 3.1

3 - To print the report requested on task 3.2 on rails console please run:

"require 'log_parser'"
"parsed_data = LogParser.generate_grouped_information"
"require 'report'"
"Report.print_info_by_player(parsed_data)"

4 - To print the report requested on task 3.3 on rails console please run:

"require 'log_parser'"
"parsed_data = LogParser.generate_grouped_information(kills_by_player: false)"
"require 'report'"
"Report.print_info_by_means(parsed_data)"

* Ruby version

ruby-2.7.6

* System dependencies

postgres

* Configuration

"bundle install""

* Database initialization

"bundle exec rails db:create db:setup"

* How to run the test suite

"bundle exec rspec"
