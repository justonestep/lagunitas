require 'test_helper'

module Lagunitas
  class IPAErrorTest < TestCase

    def test_not_found
      assert_raises(NotFoundError) { Lagunitas::IPA.new('test/data/notexisting.ipa') }
    end

    def test_not_valid
      assert_raises(NotIpaFileError) { Lagunitas::IPA.new('test/data/notvalid.ipa').app }
      assert_raises(NotIpaFileError) { Lagunitas::IPA.new('test/data/notvalid.txt').app }
    end

  end
end
