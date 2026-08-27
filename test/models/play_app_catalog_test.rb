# frozen_string_literal: true

require "test_helper"

class PlayAppCatalogTest < ActiveSupport::TestCase
  test "catalog separates production and held Play apps" do
    assert_equal 37, PlayAppCatalog.active.length
    assert_equal 10, PlayAppCatalog.held.length
    assert_equal 47, PlayAppCatalog.active.length + PlayAppCatalog.held.length
    assert_equal PlayAppCatalog.active.length, PlayAppCatalog.active.pluck(:slug).uniq.length
    assert_equal PlayAppCatalog.active.length, PlayAppCatalog.active.pluck(:package_name).uniq.length
  end

  test "every production app has useful search content" do
    PlayAppCatalog.active.each do |app|
      assert app[:summary].length >= 30, app[:slug]
      assert app[:audience].length >= 20, app[:slug]
      assert_equal 3, app[:highlights].length, app[:slug]
      assert_match(/\A[a-z0-9-]+\z/, app[:slug])
      assert_match(/\A[a-zA-Z0-9_]+(?:\.[a-zA-Z0-9_]+)+\z/, app[:package_name])
    end
  end

  test "Play URL contains package and allowlisted campaign referrer" do
    app = PlayAppCatalog.find("mulmi")
    url = PlayAppCatalog.play_url(app, campaign: "app-mulmi")

    assert_includes url, "id=com.mulmi.ridecue"
    assert_includes CGI.unescape(url), "utm_source=bodeum_app_directory"
    assert_includes CGI.unescape(url), "utm_campaign=app-mulmi"
  end
end
