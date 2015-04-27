require 'test_helper'

module Lagunitas
  class AppTest < TestCase
    def setup
      @ipa = Lagunitas::IPA.new('test/data/Sample.ipa')
      @app = @ipa.app
    end

    def test_identifier
      assert_equal 'com.samsoffes.Sample', @app.identifier
    end

    def test_display_name
      assert_equal 'Sample', @app.display_name
    end

    def test_version
      assert_equal '13', @app.version
    end

    def test_short_version
      assert_equal '2.2', @app.short_version
    end

    def test_icons
      assert_includes @app.icon(120), 'AppIcon60x60@2x.png'
      assert_nil @app.icon(1024)
    end

    def test_path
      assert_match(/Payload\/Sample\.app*/, @app.path)
    end

    def test_real_path
      assert_equal 'test/data/Sample.ipa', @app.real_path
    end

    def teardown
      @ipa.cleanup if @ipa
    end

    def test_team_name
      assert_equal 'Nothing Magical Inc.', @app.team_name
    end

    def test_certificate_name
      assert_equal 'iOS Team Provisioning Profile: *', @app.certificate_name
    end

    def test_expiration_date
      assert_equal '2014-10-30 18:23:25 +0100', @app.expiration_date.to_s
    end
  end
end
