require 'yaml'

class ApacheLookup
  VERSION = '0.0.1'
  
  def initialize cache
    @cache = cache
  end
  
  def resolv_ip ip
    @cache[ip]['url']
  end
end