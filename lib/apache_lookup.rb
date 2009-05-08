require 'time'
require 'resolv'
require 'yaml'

class ApacheLookup
  VERSION = '0.0.1'
  
  def initialize cache
    @cache = cache
  end
  
  def resolv_ip ip    
    unless @cache[ip] && Time.parse(@cache[ip]['created_at']) > Time.now
      @cache[ip] = {}
      @cache[ip]['url'] = Resolv.getname ip
    else
      @cache[ip]['url']
    end
  end
end