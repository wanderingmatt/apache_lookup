require 'time'
require 'resolv'
require 'yaml'

class ApacheLookup
  VERSION = '0.0.1'
  
  IP_REGEX = /^((\d{1,3}\.){3}\d{1,3})\s/
  EXPIRATION = 2419200 # 30 days
  
  attr_accessor :cache, :lines
  
  def initialize cache
    @cache = cache
    @lines = []
  end
  
  def store_lines log
    log.each_line do |line|
      @lines << line.chomp
    end
  end
  
  def process_lines
    @lines.each do |line|
      parse_line line
    end
  end
  
  def parse_line line
    line =~ IP_REGEX
    line.gsub!($1, resolv_ip($1))
  end
  
  def resolv_ip ip    
    if !@cache[ip] || Time.parse(@cache[ip]['created_at']) < Time.now - EXPIRATION
      @cache[ip] = {}
      @cache[ip]['url'] = Resolv.getname ip
      @cache[ip]['created_at'] = Time.now.to_s
    end
    @cache[ip]['url']
  end
end