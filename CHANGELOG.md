# Changelog

## 0.1.0

* Drop `enumerize`, `json` and `rails` dependencies, only `activesupport` is required
* `Action#severity` and `Action#type` return symbols
* Require Ruby 3.2 and ActiveSupport 7.0 or newer
* Fix `NameError` on continuation lines of requests which started before the beginning of the log
* Fix crash on log lines with label `ANY` (`Logger#unknown`)
* Fix `summary(last_minutes:)` for actions without datetime
* Fix swallowed log lines containing `Starting job`

## 0.0.21

* Use `ignore_lines` on not parsable lines

## 0.0.20

* Add support for journald

## 0.0.19

* Ignore lines after ActiveJob lines

## 0.0.18

* Known exceptions given with maximum severity

## 0.0.17

* Adding `ActionDispatch::Http::MimeNegotiation::InvalidType` as known exceptions
* Update dependencies

## 0.0.16

* Remove heuristic
* Fix last action handling

## 0.0.15

* Filter lines by config file

## 0.0.14

* Better empty lines handling

## 0.0.13

* Better empty lines handling

## 0.0.12

* Adding `ActionController::UnknownFormat` as known exceptions

## 0.0.11

* Increase minimum requests value for heuristic

## 0.0.10

* Ignore periods with too few requests

## 0.0.9

* Message not parseable lines only once a day
* Delete old heuristic stat files automaticly

## 0.0.8

* Adding `ActionController::UnfilteredParameters` as known exceptions
* Adjust heuristic rate for better matching

## 0.0.7

* Remove empty lines on summary without report

## 0.0.6

* Adding heuristic to rate known exceptions

## 0.0.5

* Removing `URI::InvalidURIError` as known exceptions

## 0.0.4

* Handle stacktrace of fatals too

## 0.0.3

* Adding `URI::InvalidURIError` as known exceptions

## 0.0.2

* Adding `ActionController::InvalidAuthenticityToken` as known exceptions
