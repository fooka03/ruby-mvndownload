require 'mvndownload'
require 'minitest/autorun'

class MvndownloadTest < MiniTest::Unit::TestCase
    def test_bad_download
        assert_raises(SystemExit) { Mvndownload.download(:source => "http://idontexistwhybother.lol/nofile.txt", :destination => "temp") }
    end

    def test_good_download
        assert_silent { Mvndownload.download(:source => "http://central.maven.org/maven2/com/google/code/gson/gson/2.3/gson-2.3.jar", :destination => "temp", :proxyhost => "www-ad-proxy.sabre.com", :proxyport => "80", :proxyuser => "sg0221439", :proxypass => "MoFo8621!") }
    end
end
