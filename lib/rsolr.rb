$: << "#{File.dirname(__FILE__)}" unless $:.include? File.dirname(__FILE__)

require 'rubygems'

module RSolr
  
  %W(Char Client Error Connection Pagination Uri Xml).each{|n|autoload n.to_sym, "rsolr/#{n.downcase}"}
  autoload :FiberedEmConnection, "rsolr/fibered_em_connection"
  
  def self.version
    @version ||= File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).chomp
  end
  
  VERSION = self.version
  
  def self.connect *args
    driver = Class === args[0] ? args[0] : default_connection
    opts = Hash === args[-1] ? args[-1] : {}
    Client.new driver.new, opts
  end

  def self.default_connection
    if defined?(EM) and defined?(Fiber) and EM.reactor_running? and Fiber.respond_to?(:current)
      RSolr::FiberedEmConnection
    else
      RSolr::Connection
    end
  end
  
  # RSolr.escape
  extend Char
  
end
