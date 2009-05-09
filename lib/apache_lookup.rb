require 'time'
require 'resolv'
require 'yaml'
require 'thread'

class ApacheLookup
  VERSION = '0.0.1'
  
  IP_REGEX = /^((\d{1,3}\.){3}\d{1,3})\s/
  EXPIRATION = 2419200 # 30 days
  CACHE_PATH = '../cache/cache.yml'
  
  attr_accessor :cache, :lines
  
  def initialize cache_path
    load_cache cache_path
    @queue = Queue.new
    @thread_pool = []
    @lines = []
  end
  
  def load_cache path
    if File.exist?(path)
      @cache = YAML.load_file(path)
    else
      @cache = {}
    end
  end
  
  def store_lines log
    log.each_line do |line|
      @lines << line.chomp
    end
  end
  
  def process_lines
    @lines.each do |line|
      @queue << line
    end
    
    100.times do
      @thread_pool << Thread.new do
        until @queue.empty?
          parse_line @queue.pop
        end
      end
    end
    
    @thread_pool.each { |t| t.join }
    
    # threads = (0..20).map { 
    #   Thread.new do 
    #     @lines.each do |line|
    #       parse_line line
    #     end
    #   end 
    # } 
    # puts "hello!!!" 
    # threads.each { |thread| thread.join }
    
  end
  
  def parse_line line
    line =~ IP_REGEX
    line.gsub!($1, resolv_ip($1))
  end
  
  def resolv_ip ip    
    if !@cache[ip] || Time.parse(@cache[ip]['created_at']) < Time.now - EXPIRATION
      @cache[ip] = {}
      @cache[ip]['url'] = Resolv.getname(ip)
      @cache[ip]['created_at'] = Time.now.to_s
    end
    @cache[ip]['url']
  end
end