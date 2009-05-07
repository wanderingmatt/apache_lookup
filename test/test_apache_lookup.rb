require 'test/unit'
require 'apache_lookup'

class TestApacheLookup < Test::Unit::TestCase
  def setup
    CACHE = YAML.load_file("cache.yml")
  end
  
  def test_reads_from_cache_if_cached_and_not_expired
    actual = ApacheLookup.resolv_ip "1.1.1.1"
    
    assert_equal "http://1111.com", actual
  end
  
  def test_resolves_ip_if_not_cached
    actual = ApacheLookup.resolv_ip "1.1.1.0"
    
    assert_equal "http://1110.com", actual
  end
  
  def test_resolves_ip_if_expired
    actual = ApacheLookup.resolv_ip "1.1.1.2"
    
    assert_equal "http://1112.com", actual
  end
  
  def test_writes_to_cache_if_not_cached
    actual = ApacheLookup.resolv_ip "1.1.1.0"
    expected = CACHE['1.1.1.0']['URL']
    
    assert_equal "http://1110.com", actual
  end
  
  def test_writes_to_cache_if_expired
    actual = ApacheLookup.resolv_ip "1.1.1.2"
    expected = CACHE['1.1.1.2']['URL']
    
    assert_equal "http://1112.com", actual
  end
end