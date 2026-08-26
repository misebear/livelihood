# frozen_string_literal: true

require "cgi"
require "fileutils"
require "json"

class PlayAppDirectoryExporter
  def initialize(output_root:, base_url:)
    @output_root = Pathname(output_root)
    @base_url = base_url.to_s.delete_suffix("/")
  end

  def export
    FileUtils.mkdir_p(@output_root.join("apps"))
    write("index.html", index_html)
    write("app-directory.css", styles)
    write("apps/rss.xml", rss_xml)
    write("sitemap.xml", sitemap_xml)
    write("robots.txt", robots_txt)
    write("llms.txt", llms_txt)
    write("404.html", not_found_html)

    PlayAppCatalog.active.each do |app|
      write("apps/#{app[:slug]}/index.html", app_html(app))
    end
  end

  private

  attr_reader :output_root, :base_url

  def write(relative_path, content)
    destination = output_root.join(relative_path)
    FileUtils.mkdir_p(destination.dirname)
    destination.write(content, encoding: "UTF-8")
  end

  def escape(value)
    CGI.escapeHTML(value.to_s)
  end

  def play_url(app, campaign)
    PlayAppCatalog.play_url(app, campaign: campaign)
  end

  def page_shell(title:, description:, canonical:, body:, schema: nil)
    schema_markup = schema ? %(<script type="application/ld+json">#{JSON.generate(schema)}</script>) : ""
    <<~HTML
      <!doctype html>
      <html lang="ko">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width,initial-scale=1">
          <title>#{escape(title)}</title>
          <meta name="description" content="#{escape(description)}">
          <meta name="robots" content="index,follow,max-image-preview:large">
          <link rel="canonical" href="#{escape(canonical)}">
          <link rel="alternate" type="application/rss+xml" title="JejuBucketList Android 앱" href="#{base_url}/apps/rss.xml">
          <meta property="og:type" content="website">
          <meta property="og:site_name" content="JejuBucketList App Support">
          <meta property="og:locale" content="ko_KR">
          <meta property="og:title" content="#{escape(title)}">
          <meta property="og:description" content="#{escape(description)}">
          <meta property="og:url" content="#{escape(canonical)}">
          <meta name="twitter:card" content="summary">
          <style>#{styles}</style>
          #{schema_markup}
        </head>
        <body>
          <header class="site-header"><a href="#{base_url}/">JejuBucketList Apps</a><nav><a href="#{base_url}/privacy.html">개인정보</a><a href="#{base_url}/data-deletion.html">데이터 삭제</a><a href="#{base_url}/app-ads.txt">app-ads.txt</a></nav></header>
          <main>#{body}</main>
          <footer><p>지원 이메일: <a href="mailto:db0192a@gmail.com">db0192a@gmail.com</a></p><p>각 앱의 기능과 지원 정보를 제공하며 설치 여부는 사용자가 직접 결정합니다.</p></footer>
        </body>
      </html>
    HTML
  end

  def index_html
    active_cards = PlayAppCatalog.active.map do |app|
      <<~HTML
        <article class="app-card">
          <span class="package">#{escape(app[:package_name])}</span>
          <h2>#{escape(app[:name])}</h2>
          <p>#{escape(app[:summary])}</p>
          <div class="actions"><a href="#{base_url}/apps/#{app[:slug]}/">기능·지원</a><a href="#{escape(play_url(app, "directory-#{app[:slug]}"))}">Play 설치</a></div>
        </article>
      HTML
    end.join
    held_cards = PlayAppCatalog.held.map do |app|
      %(<article class="app-card held"><span class="status">#{escape(app[:status])}</span><h2>#{escape(app[:name])}</h2><p class="package">#{escape(app[:package_name])}</p></article>)
    end.join
    body = <<~HTML
      <section class="hero"><p class="eyebrow">JEJUBUCKETLIST ANDROID APPS</p><h1>Android 앱 기능·지원·설치 디렉터리</h1><p>Play Console에서 프로덕션 상태를 확인한 앱 36개의 기능과 지원, 설치 링크를 제공합니다. 임시·거부·삭제 앱은 설치 SEO에서 제외합니다.</p><div class="hero-links"><a href="mailto:db0192a@gmail.com">이메일 문의</a><a href="#{base_url}/apps/rss.xml">앱 RSS</a><a href="#{base_url}/sitemap.xml">사이트맵</a></div></section>
      <section><p class="eyebrow">PRODUCTION</p><h2>프로덕션 앱 #{PlayAppCatalog.active.length}개</h2><div class="grid">#{active_cards}</div></section>
      <section><p class="eyebrow">HOLD / RECOVERY</p><h2>임시·거부·삭제 앱 #{PlayAppCatalog.held.length}개</h2><p>Play 상태가 복구되기 전에는 설치 페이지와 sitemap에 포함하지 않습니다.</p><div class="grid">#{held_cards}</div></section>
    HTML
    schema = {
      "@context": "https://schema.org", "@type": "CollectionPage", name: "JejuBucketList Android 앱 디렉터리",
      description: "프로덕션 Android 앱 36개의 기능, 지원과 설치 안내", url: "#{base_url}/", inLanguage: "ko-KR",
      hasPart: PlayAppCatalog.active.map { |app| { "@type": "SoftwareApplication", name: app[:name], url: "#{base_url}/apps/#{app[:slug]}/" } }
    }
    page_shell(title: "Android 앱 36개 기능·지원·설치 | JejuBucketList", description: "JejuBucketList 프로덕션 Android 앱 36개의 기능, 지원과 Google Play 설치 링크를 확인합니다.", canonical: "#{base_url}/", body: body, schema: schema)
  end

  def app_html(app)
    features = app[:highlights].map { |feature| "<li>#{escape(feature)}</li>" }.join
    caution = app[:caution] ? %(<aside><strong>사용 안내</strong><p>#{escape(app[:caution])}</p></aside>) : ""
    body = <<~HTML
      <nav class="breadcrumb"><a href="#{base_url}/">앱 디렉터리</a><span>›</span><span>#{escape(app[:name])}</span></nav>
      <article class="detail"><p class="eyebrow">ANDROID APP GUIDE</p><h1>#{escape(app[:name])}</h1><p class="lead">#{escape(app[:summary])}</p>
      <div class="actions"><a href="#{escape(play_url(app, "app-#{app[:slug]}"))}">Google Play에서 설치</a><a class="secondary" href="mailto:db0192a@gmail.com?subject=#{CGI.escape("[#{app[:name]}] 문의")}">문의하기</a></div>
      <dl><div><dt>패키지</dt><dd>#{escape(app[:package_name])}</dd></div><div><dt>추천 대상</dt><dd>#{escape(app[:audience])}</dd></div><div><dt>업데이트</dt><dd>#{PlayAppCatalog::UPDATED_ON}</dd></div></dl>
      <h2>주요 기능</h2><ul class="features">#{features}</ul>#{caution}<h2>지원 안내</h2><p>앱 이름, 기기 모델, Android 버전, 앱 버전과 문제 화면을 함께 보내주세요.</p></article>
    HTML
    canonical = "#{base_url}/apps/#{app[:slug]}/"
    schema = {
      "@context": "https://schema.org", "@type": "SoftwareApplication", name: app[:name], description: app[:summary],
      applicationCategory: app[:category], operatingSystem: "Android", url: canonical, downloadUrl: PlayAppCatalog.play_url(app),
      featureList: app[:highlights], inLanguage: "ko-KR", isAccessibleForFree: true,
      offers: { "@type": "Offer", price: "0", priceCurrency: "KRW" }, author: { "@type": "Organization", name: "JejuBucketList", url: "#{base_url}/" }
    }
    page_shell(title: "#{app[:name]} 기능·지원·설치", description: app[:summary], canonical: canonical, body: body, schema: schema)
  end

  def sitemap_xml
    urls = [ "#{base_url}/" ] + PlayAppCatalog.active.map { |app| "#{base_url}/apps/#{app[:slug]}/" }
    nodes = urls.map { |url| "<url><loc>#{escape(url)}</loc><lastmod>#{PlayAppCatalog::UPDATED_ON}</lastmod></url>" }.join
    %(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">#{nodes}</urlset>)
  end

  def rss_xml
    items = PlayAppCatalog.active.map do |app|
      url = "#{base_url}/apps/#{app[:slug]}/"
      description = [ app[:summary], "추천 대상: #{app[:audience]}", "주요 기능: #{app[:highlights].join(', ')}", app[:caution] ].compact.join("\n\n")
      "<item><title>#{escape(app[:name])}</title><link>#{escape(url)}</link><guid isPermaLink=\"true\">#{escape(url)}</guid><pubDate>Wed, 26 Aug 2026 00:00:00 +0900</pubDate><description>#{escape(description)}</description></item>"
    end.join
    %(<?xml version="1.0" encoding="UTF-8"?>\n<rss version="2.0"><channel><title>JejuBucketList Android 앱</title><link>#{base_url}/</link><description>프로덕션 Android 앱 기능과 지원 업데이트</description>#{items}</channel></rss>)
  end

  def robots_txt
    "User-agent: *\nAllow: /\n\nSitemap: #{base_url}/sitemap.xml\nSitemap: #{base_url}/apps/rss.xml\n"
  end

  def llms_txt
    lines = PlayAppCatalog.active.map { |app| "- #{app[:name]}: #{base_url}/apps/#{app[:slug]}/" }
    ([ "# JejuBucketList Android Apps", "", "Production Android app features and support pages.", "" ] + lines).join("\n")
  end

  def not_found_html
    page_shell(title: "페이지를 찾을 수 없습니다", description: "요청한 앱 지원 페이지가 없습니다.", canonical: "#{base_url}/404.html", body: "<section class=\"hero\"><h1>페이지를 찾을 수 없습니다</h1><p><a href=\"#{base_url}/\">앱 디렉터리로 돌아가기</a></p></section>")
  end

  def styles
    <<~CSS
      *{box-sizing:border-box}body{margin:0;background:#f5fbfa;color:#0f172a;font-family:Arial,"Noto Sans KR",sans-serif;line-height:1.65}.site-header{position:sticky;top:0;z-index:5;display:flex;justify-content:space-between;gap:16px;padding:16px max(20px,calc((100% - 1120px)/2));background:rgba(255,255,255,.95);border-bottom:1px solid #dbe7e5}.site-header a{color:#0f766e;font-weight:800;text-decoration:none}.site-header nav{display:flex;flex-wrap:wrap;gap:12px}main{width:min(1120px,calc(100% - 24px));margin:28px auto}section,.detail{margin:22px 0;padding:clamp(22px,5vw,42px);border:1px solid #d9e5e3;border-radius:28px;background:linear-gradient(135deg,#e8f7f4,#f8fafc)}h1{margin:8px 0 16px;font-size:clamp(34px,6vw,58px);line-height:1.12;letter-spacing:-.04em}h2{line-height:1.25}.eyebrow{color:#0f766e;font-weight:900;letter-spacing:.08em}.hero-links,.actions{display:flex;flex-wrap:wrap;gap:10px;margin-top:22px}.hero-links a,.actions a{display:inline-flex;min-height:44px;align-items:center;padding:0 16px;border-radius:999px;background:#0f766e;color:#fff;font-weight:800;text-decoration:none}.actions a.secondary{background:#fff;color:#0f766e;border:1px solid #0f766e}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:14px}.app-card{padding:20px;border:1px solid #d9e5e3;border-radius:22px;background:#fff;box-shadow:0 14px 32px rgba(15,23,42,.06)}.app-card h2{font-size:22px}.package,.status{display:inline-flex;max-width:100%;padding:6px 10px;border-radius:999px;background:#ecfeff;color:#0f766e;font-size:12px;font-weight:800;overflow-wrap:anywhere}.held .status{background:#fff7ed;color:#9a3412}.breadcrumb{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:22px}.breadcrumb a{color:#0f766e;font-weight:800}.lead{font-size:20px;color:#475569}dl{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}dl div,.features li,aside{padding:18px;border:1px solid #d9e5e3;border-radius:18px;background:#fff}dt{color:#64748b;font-size:13px;font-weight:800}dd{margin:8px 0 0;overflow-wrap:anywhere}.features{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;padding:0;list-style:none}.features li{font-weight:700}aside{margin-top:24px;border-left:6px solid #f59e0b}footer{max-width:1120px;margin:30px auto;padding:24px;text-align:center;color:#64748b}@media(max-width:720px){.site-header{align-items:flex-start;flex-direction:column}.grid,.features,dl{grid-template-columns:1fr}main{width:min(100% - 16px,1120px)}section,.detail{border-radius:20px;padding:22px}}
    CSS
  end
end
