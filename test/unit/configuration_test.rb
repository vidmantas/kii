require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  def setup
    Rails.cache.clear
  end
  
  test "reading directly from cache" do
    Rails.cache.write("config::foo", 5)
    Configuration.expects(:store_in_cache).never
    assert_equal 5, Configuration["foo"]
  end
  
  test "reading from db, storing in cache, and reading from cache" do
    Factory(:configuration, :key => "foo", :value => 5)
    Configuration.expects(:store_in_cache).once.returns(5)
    assert_equal 5, Configuration["foo"]
  end
  
  test "key not in db" do
    assert_raises(Configuration::KeyNotFound) { Configuration["foo"] }
  end
end
