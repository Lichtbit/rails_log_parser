# RailsLogParser

This gem helps you to quick analyse your server logs without external monitor servers. Simple applications with a low number of requests cause only a low number of errors. So you can call a cronjob to analyse your logs periodly. If the summary is not empty your server will email you the result automaticly.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_log_parser'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rails_log_parser

## Usage

Sets your server log path:

```ruby
RailsLogParser::Parser.log_path = Rails.root.join('log/production.log')
```

Call the rake tasks in cronjobs:

```
LOG_PATH=/srv/rails/log/production.log
0,20,40 * * * * rake rails_log_parser:parse[22]' # summary of the last 22 minutes
```

Or use it in your code:

```ruby
parser = RailsLogParser::Parser.from_file(log_path)
puts parser.actions.select(&:fatal?).map(&:headline)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Lichtbit/rails_log_parser.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
