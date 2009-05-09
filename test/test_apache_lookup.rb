require 'test/unit'
require 'apache_lookup'

class Resolv
  def getname ip
    'resolved.com'
  end
end

class ApacheLookup
  attr_accessor :cache, :lines
end

class TestApacheLookup < Test::Unit::TestCase
  def setup
    test_cache_path = 'test/test_cache.yml'
    @test_log = File.new('test/test_log.log')
    @test_line = '208.77.188.166 - - [29/Apr/2009:16:07:38 -0700] "GET / HTTP/1.1" 200 1342'
    
    @al = ApacheLookup.new test_cache_path
  end
  
  def test_cache_is_empty_on_first_run
    @al.load_cache '../flunk/cache.yml'
    
    assert @al.cache.empty?
  end
  
  def test_stores_lines_from_log
    @al.store_lines @test_log
    expected = [
      '208.77.188.166 - - [29/Apr/2009:16:07:38 -0700] "GET / HTTP/1.1" 200 1342',
      '75.146.57.34 - - [29/Apr/2009:16:08:38 -0700] "GET / HTTP/1.1" 304 -'
      ]
    
    assert_equal expected, @al.lines
  end
  
  def test_processes_stored_lines
    @al.store_lines @test_log
    @al.process_lines
    
    expected = [
      'resolved.com - - [29/Apr/2009:16:07:38 -0700] "GET / HTTP/1.1" 200 1342',
      'resolved.com - - [29/Apr/2009:16:08:38 -0700] "GET / HTTP/1.1" 304 -'
      ]    
    
    assert_equal expected, @al.lines
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