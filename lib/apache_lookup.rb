require 'time'
require 'resolv'
require 'yaml'

class ApacheLookup
  VERSION = '0.0.1'
  
  attr_accessor :cache
  
  def initialize cache
    @cache = cache
  end
  
  def resolv_ip ip    
    if !@cache[ip] || Time.parse(@cache[ip]['created_at']) < Time.now - 2419200
      @cache[ip] = {}
      @cache[ip]['url'] = Resolv.getname ip
      @cache[ip]['created_at'] = Time.now.to_s
    end
    @cache[ip]['url']
    
    # unless @cache[ip] && Time.parse(@cache[ip]['created_at']) > Time.now - 2419200
    #   @cache[ip] = {}
    #   @cache[ip]['url'] = Resolv.getname ip
    #   @cache[ip]['created_at'] = Time.now.to_s
    # else
    #   @cache[ip]['url']
    # end
  end
end