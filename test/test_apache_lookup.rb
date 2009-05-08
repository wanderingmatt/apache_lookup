require 'test/unit'
require 'apache_lookup'
require 'rubygems'
require 'mocha'

class Resolv
  def getname ip
    'resolved.com'
  end
end

class TestApacheLookup < Test::Unit::TestCase
  def setup
    cache = YAML.load_file('test/test_cache.yml')
    
    @al = ApacheLookup.new cache
  end
  
  def test_reads_from_cache_if_cached_and_not_expired
    actual = @al.resolv_ip '1.1.1.1'
    
    assert_equal 'cached.com', actual
  end
  
  def test_resolves_ip_if_not_cached    
    actual = @al.resolv_ip '1.1.1.0'
    
    assert_equal 'resolved.com', actual
  end
  
  def test_resolves_ip_if_expired
    actual = @al.resolv_ip '1.1.1.2'
    
    assert_equal 'resolved.com', actual
  end
  
  def test_writes_to_cache_if_not_cached
    @al.resolv_ip '1.1.1.0'
    actual = @al.cache['1.1.1.0']['url']
    
    assert_equal 'resolved.com', actual
  end
  
  def test_writes_to_cache_if_expired
    @al.resolv_ip '1.1.1.2'
    actual = @al.cache['1.1.1.2']['url']
    
    assert_equal 'resolved.com', actual
  end
end