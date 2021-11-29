# frozen_string_literal: true
require 'time'
require 'securerandom'

class RailsLogParser::Action
  class << self
    attr_accessor :last
  end

  SEVERITIES = %i[debug info warn error fatal].freeze
  KNOWN_EXCEPTIONS = {
    'ActiveRecord::RecordNotFound' => :fatal,
    'ActionController::RoutingError' => :fatal,
    "Can't verify CSRF token authenticity." => :warn,
    'ActionController::InvalidAuthenticityToken' => :fatal,
    'URI::InvalidURIError' => :fatal,
  }.freeze

  extend Enumerize
  enumerize :severity, in: SEVERITIES, predicates: true
  enumerize :type, in: %i[request without_request delayed_job active_job], predicates: true

  def initialize(type, id)
    self.type = type
    @id = id
    @messages = []
    @stacktrace = []
    self.class.last = self
  end

  def severity=(value)
    value = value.downcase.to_sym
    return unless severity.nil? || SEVERITIES.index(severity.to_sym) < SEVERITIES.index(value)

    super(value)
    @headline = nil
  end

  def known_exception?
    @messages.any? do |message|
      KNOWN_EXCEPTIONS.any? { |e, s| message.include?(e) && severity == s }
    end
  end

  def headline
    @headline.presence || @messages.first
  end

  def datetime=(value)
    @datetime ||= Time.parse(value)
  end

  def after?(datetime)
    @datetime > datetime
  end

  def add_message(value)
    @messages.push(value)
    @headline = value if @headline.nil?
  end

  def add_stacktrace(value)
    @stacktrace.push(value)
  end
end
