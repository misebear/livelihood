# frozen_string_literal: true

require_relative "../config/environment"
require_relative "../lib/play_app_directory_exporter"

output_root = ARGV.fetch(0)
base_url = ARGV.fetch(1, "https://misebear.github.io/jejubucketlist-app-support-site")

PlayAppDirectoryExporter.new(output_root: output_root, base_url: base_url).export
puts "Exported #{PlayAppCatalog.active.length} production app pages to #{output_root}"
