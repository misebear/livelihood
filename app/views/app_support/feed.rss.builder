xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.rss version: "2.0", "xmlns:atom": "http://www.w3.org/2005/Atom", "xmlns:dc": "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title "보듬 Android 앱 가이드"
    xml.link app_support_url
    xml.description "JejuBucketList에서 운영하는 Android 앱의 기능, 지원과 설치 안내"
    xml.language "ko-KR"
    xml.lastBuildDate Time.zone.local(2026, 8, 26).rfc2822
    xml.tag! "atom:link", href: play_apps_feed_url, rel: "self", type: "application/rss+xml"

    @apps.each do |app|
      xml.item do
        page_url = play_app_url(app[:slug])
        full_description = [
          app[:summary],
          "추천 대상: #{app[:audience]}",
          "주요 기능: #{app[:highlights].join(', ')}",
          app[:caution],
          "패키지: #{app[:package_name]}"
        ].compact.join("\n\n")

        xml.title app[:name]
        xml.link page_url
        xml.guid page_url, isPermaLink: "true"
        xml.pubDate Time.zone.local(2026, 8, 26).rfc2822
        xml.tag! "dc:language", "ko-KR"
        xml.description full_description
      end
    end
  end
end
