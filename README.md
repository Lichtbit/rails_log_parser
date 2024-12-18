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
0,20,40 * * * * rake rails_log_parser:parse[22]'      # summary of the last 22 minutes
```

Or use it in your code:

```ruby
parser = RailsLogParser::Parser.from_file(log_path)
puts parser.actions.select(&:fatal?).map(&:headline)
```

```ruby
parser = RailsLogParser::Parser.from_file(log_path)
print parser.summary(last_minutes: 22)          # print summary for the last 22 minutes
```

You can configure filters:

```ruby
# config/rails_log_parser.rb

RailsLogParser.configure do |parser|
  parser.ignore_lines = [
    /Error performing MailerConfigurationJob .+ Net::ReadTimeout/,
  ]
end
```


## Changelog

### 0.0.18

* Known exceptions given with maximum severity

### 0.0.17

* Adding `ActionDispatch::Http::MimeNegotiation::InvalidType` as known exceptions
* Update dependencies

### 0.0.16

* Remove heuristic
* Fix last action handling

### 0.0.15

* Filter lines by config file

### 0.0.14

* Better empty lines handling

### 0.0.13

* Better empty lines handling

### 0.0.12

* Adding `ActionController::UnknownFormat` as known exceptions

### 0.0.11

* Increase minimum requests value for heuristic

### 0.0.10

* Ignore periods with too few requests

### 0.0.9

* Message not parseable lines only once a day
* Delete old heuristic stat files automaticly

### 0.0.8

* Adding `ActionController::UnfilteredParameters` as known exceptions
* Adjust heuristic rate for better matching

### 0.0.7

* Remove empty lines on summary without report

### 0.0.6

* Adding heuristic to rate known exceptions

### 0.0.5

* Removing `URI::InvalidURIError` as known exceptions

### 0.0.4

* Handle stacktrace of fatals too

### 0.0.3

* Adding `URI::InvalidURIError` as known exceptions

### 0.0.2

* Adding `ActionController::InvalidAuthenticityToken` as known exceptions

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Lichtbit/rails_log_parser.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
