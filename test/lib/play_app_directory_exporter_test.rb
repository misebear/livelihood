# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require Rails.root.join("lib/play_app_directory_exporter")

class PlayAppDirectoryExporterTest < ActiveSupport::TestCase
  test "exports a complete static directory without held app install pages" do
    Dir.mktmpdir do |directory|
      base_url = "https://example.github.io/apps"
      PlayAppDirectoryExporter.new(output_root: directory, base_url: base_url).export

      assert File.exist?(File.join(directory, "index.html"))
      assert File.exist?(File.join(directory, "favicon.svg"))
      assert_equal 36, Dir.glob(File.join(directory, "apps/*/index.html")).length
      assert_equal 36, File.read(File.join(directory, "apps/rss.xml")).scan("<item>").length
      assert_equal 37, File.read(File.join(directory, "sitemap.xml")).scan("<url>").length
      assert_includes File.read(File.join(directory, "apps/mulmi/index.html")), "com.mulmi.ridecue"
      assert_includes File.read(File.join(directory, "apps/mulmi/index.html")), "SoftwareApplication"
      assert_includes File.read(File.join(directory, "apps/mulmi/index.html")), "utm_campaign%3Dapp-mulmi"
      assert_not File.exist?(File.join(directory, "apps/secret-signal/index.html"))
      assert_not_includes File.read(File.join(directory, "sitemap.xml")), "secret-signal"
    end
  end
end
