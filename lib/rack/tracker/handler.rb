class Rack::Tracker::Handler
  class_attribute :position
  self.position = :head

  attr_accessor :options
  attr_accessor :env

  # Allow javascript escaping in view templates
  include Rack::Tracker::JavaScriptHelper

  def initialize(env, options = {})
    self.env = env
    self.options  = options
    self.position = options[:position] if options.has_key?(:position)
  end

  def events
    events = env.fetch('tracker', {})[self.class.to_s.demodulize.underscore] || []
    events.map{ |ev| "#{self.class}::#{ev['class_name']}".constantize.new(ev.except('class_name')) }
  end

  def render
    raise NotImplementedError.new('needs implementation')
  end

  def self.track(name, event)
    raise NotImplementedError.new("class method `#{__callee__}` is not implemented.")
  end

  def ignore?
    return false unless options.include?(:ignore)
    options[:ignore].respond_to?(:call) ? options[:ignore].call(env) : options[:ignore]
  end
end
