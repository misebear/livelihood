# frozen_string_literal: true

require "test_helper"

class BrakemanBinstubTest < ActiveSupport::TestCase
  test "CI uses the lockfile scanner instead of requiring the remote latest release" do
    binstub = Rails.root.join("bin/brakeman").read

    refute_includes binstub, "--ensure-latest"
    assert_includes binstub, 'load Gem.bin_path("brakeman", "brakeman")'
  end
end
