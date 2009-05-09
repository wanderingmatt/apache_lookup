require 'optparse'
require 'resolv'
require 'thread'
require 'time'
require 'yaml'

class ApacheLookup
  VERSION = '0.0.1'
  
  IP_REGEX = /^((\d{1,3}\.){3}\d{1,3})/
  CACHE_PATH = 'cache/cache.yml'
  EXPIRATION = 2419200 # 30 days
    
  def initialize cache_path, file_path, thread_limit = 10
    load_cache cache_path
    @file = File.new(file_path)
    @thread_limit = thread_limit.to_i
    @queue = Queue.new
    @lines = []
  end
  
  def self.run thread_limit, file_path
    cache_path = CACHE_PATH
    @al = ApacheLookup.new cache_path, file_path, thread_limit
    @al.store_lines
    @al.process_lines
    @al.save_cache
  end
  
  def load_cache path
    if File.exist?(path)
      @cache = YAML.load_file(path)
    else
      @cache = {}
    end
  end
  
  def store_lines log = @file
    log.each_line do |line|
      @lines << line.chomp
    end
  end
  
  def process_lines
    @lines.each_with_index do |l, i|
      Thread.new(l, i) do |line, index|
        @lines[index] = parse_line line   
      end
    end
  end
  
  def parse_line line    
    line =~ IP_REGEX
    line.gsub($1, resolv_ip($1))
  end
  
  def resolv_ip ip    
    if !@cache[ip] || Time.parse(@cache[ip]['created_at']) < Time.now - EXPIRATION
      @cache[ip] = {}
      @cache[ip]['url'] = Resolv.getname(ip)
      @cache[ip]['created_at'] = Time.now.to_s
    end
    @cache[ip]['url']
  end
  
  def save_cache
    File.open(CACHE_PATH, 'w') do |out|
      YAML.dump(@cache, out)
    end
  end
end

ApacheLookup.run(ARGV[0], ARGV[1])if $0 == __FILE__