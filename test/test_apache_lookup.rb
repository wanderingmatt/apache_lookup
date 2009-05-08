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
    test_cache = YAML.load_file('test/test_cache.yml')
    @test_line = '208.77.188.166 - - [29/Apr/2009:16:07:38 -0700] "GET / HTTP/1.1" 200 1342'
    
    @al = ApacheLookup.new test_cache
  end
  
  def test_parses_line_and_replaces_ip
    expected = 'resolved.com - - [29/Apr/2009:16:07:38 -0700] "GET / HTTP/1.1" 200 1342'
    actual = @al.parse_line @test_line
    
    assert_equal expected, actual
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
  
  def test_updates_created_at_if_expired
    @al.resolv_ip '1.1.1.2'
    actual = @al.cache['1.1.1.2']['created_at']

    assert_equal Time.now.to_s, actual
  end
end