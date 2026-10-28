# frozen_string_literal: true

require 'time'
require 'securerandom'

class RailsLogParser::Action
  SEVERITIES = %i[debug info warn error fatal].freeze
  KNOWN_EXCEPTIONS = {
    "Can't verify CSRF token authenticity." => :warn,
    'ActionController::InvalidAuthenticityToken' => :fatal,
    'ActionController::RoutingError' => :fatal,
    'ActionController::UnfilteredParameters' => :fatal,
    'ActionController::UnknownFormat' => :fatal,
    'ActiveRecord::RecordNotFound' => :fatal,
    'ActionDispatch::Http::MimeNegotiation::InvalidType' => :fatal,
  }.freeze

  TYPES = %i[request without_request delayed_job active_job].freeze

  attr_reader :type, :severity, :datetime

  SEVERITIES.each do |value|
    define_method(:"#{value}?") { severity == value }
  end

  TYPES.each do |value|
    define_method(:"#{value}?") { type == value }
  end

  def initialize(type, id)
    raise ArgumentError, "unknown type #{type.inspect}" unless TYPES.include?(type)

    @type = type
    @id = id
    @messages = []
    @stacktrace = []
  end

  def severity=(value)
    value = value.downcase.to_sym
    # Logger::UNKNOWN is written with the label ANY, it carries no severity we can rate
    return unless SEVERITIES.include?(value)
    return unless severity.nil? || SEVERITIES.index(severity) < SEVERITIES.index(value)

    @severity = value
    @headline = nil
  end

  def known_exception?(key = nil)
    severity_index = SEVERITIES.index(severity)
    @messages.any? do |message|
      KNOWN_EXCEPTIONS.any? do |e, s|
        message.include?(e) && severity_index <= SEVERITIES.index(s) && (key.nil? || key == e)
      end
    end
  end

  def ignore?
    @messages.any? do |message|
      RailsLogParser.ignore_lines.any? { |ignore| message.match?(ignore) }
    end
  end

  def headline
    @headline.presence || @messages.first
  end

  def datetime=(value)
    @datetime ||= Time.parse(value)
  end

  def after?(datetime)
    @datetime.present? && @datetime > datetime
  end

  def add_message(value)
    @messages.push(value)
    @headline = value if @headline.nil?
  end

  def add_stacktrace(value)
    @stacktrace.push(value)
  end
end
