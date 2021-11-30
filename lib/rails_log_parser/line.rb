# frozen_string_literal: true

class RailsLogParser::Line
  attr_reader :parser, :line

  def initialize(parser, line)
    @parser = parser
    @line = line.strip

    parse
  end

  def parse
    return if line.empty?

    # empty log line
    match = line.match(/
      \A(?<severity_id>[DIWEFU]),\s                 # I,
      \[(?<datetime>[^\]]+)\s\#(?<pid>\d+)\]\s+     # [2021-11-26T13:11:01.255168 #10158]
      (?<severity_label>[A-Z]+)\s+--\s+[^:]*:\s+    # INFO -- :
      \[(?<id>[a-f0-9\-]{36})\]\s*                  # [b42b65ab-7985-4bc2-a5b5-1fb23e6ad940]
      \z/x)
    return if match

    # normal log line
    match = line.match(/
      \A(?<severity_id>[DIWEFU]),\s                 # I,
      \[(?<datetime>[^\]]+)\s\#(?<pid>\d+)\]\s+     # [2021-11-26T13:11:01.255168 #10158]
      (?<severity_label>[A-Z]+)\s+--\s+[^:]*:\s+    # INFO -- :
      \[(?<id>[a-f0-9\-]{36})\]\s                   # [b42b65ab-7985-4bc2-a5b5-1fb23e6ad940]
      (?<message>.*)                                # Processing by Public::Controller
      \z/x)
    if match
      parser.request(match)
      return
    end

    match = line.match(/
      \A(?<severity_id>[DIWEFU]),\s                 # I,
      \[(?<datetime>[^\]]+)\s\#(?<pid>\d+)\]\s+     # [2021-11-26T13:11:01.255168 #10158]
      (?<severity_label>[A-Z]+)\s+--\s+[^:]*:\s+    # INFO -- :
      \[ActiveJob\]                                 # [ActiveJob]
      (?:\s\[[^\]]+\])?                             # [ActionMailer::Parameterized::DeliveryJob]
      \s\[(?<id>[^\]]+)\]\s                         # [09f4c08a-b92e-42e3-9046-7effcf87aa2f]
      (?<message>.*)                                # Performing ActionMailer::Parameterized::DeliveryJob
      \z/x)
    if match
      parser.active_job(match)
      return
    end

    match = line.match(/
      \A(?<severity_id>[DIWEFU]),\s                 # I,
      \[(?<datetime>[^\]]+)\s\#(?<pid>\d+)\]\s+     # [2021-11-26T13:11:01.255168 #10158]
      (?<severity_label>[A-Z]+)\s+--\s+[^:]*:\s     # INFO -- :
      (?<datetime2>[^\s]+)\s                        # 2021-11-26T13:51:30+0000:
      \[Worker[^\]]+\]\s                            # [Worker(delayed_job host:production pid:10411)]
      (?<message>.*)                                # Job GeoLocationSearch
      (?<id>\(id=\d+\)\s\([^)]+\))                  # (id=148781) (queue=default)
      (?<message2>.*)                               # RUNNING
      \z/x)
    if match
      parser.delayed_job(match)
      return
    end

    match = line.match(/
      \A(?<severity_id>[DIWEFU]),\s                 # I,
      \[(?<datetime>[^\]]+)\s\#(?<pid>\d+)\]\s+     # [2021-11-26T13:11:01.255168 #10158]
      (?<severity_label>[A-Z]+)\s+--\s+[^:]*:\s     # INFO -- :
      (?<datetime2>[^\s]+)\s                        # 2021-11-26T13:51:30+0000:
      \[Worker[^\]]+\]\s                            # [Worker(delayed_job host:production pid:10411)]
      (?:\d+\sjobs\sprocessed)|(?:Starting\sjob)    # 19 jobs processed
      (?:.*)                                        # at 2.8816
      \z/x)
    return if match

    # Warning or Message without request
    match = line.match(/
      \A(?<severity_id>[DIWEFU]),\s                 # I,
      \[(?<datetime>[^\]]+)\s\#(?<pid>\d+)\]\s+     # [2021-11-26T13:11:01.255168 #10158]
      (?<severity_label>[A-Z]+)\s+--\s+[^:]*:\s     # INFO -- :
      (?<message>.*)                                # Creating scope :for_tipster. Overwriting existing...
      \z/x)
    if match
      parser.without_request(match)
      return
    end

    match = line.match(/
      \A\[(?<id>[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12})\]\s # [UUID]
      (?<message>.*)
      \z/x)
    if match
      parser.add_message(match)
      return
    end

    if parser.last_action&.error? || parser.last_action&.fatal?
      parser.last_action.add_stacktrace(line)
      return
    end

    parser.not_parseable_lines.push(line)
  end
end
