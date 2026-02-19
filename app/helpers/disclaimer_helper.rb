# frozen_string_literal: true

# ────────────────────────────────────────────────────────────────
# DisclaimerHelper
# ────────────────────────────────────────────────────────────────
# 면책 조항을 View에 강제 포함하기 위한 Helper.
# 계산기 결과, 혜택 안내 화면 하단에 반드시 표시해야 합니다.
# ────────────────────────────────────────────────────────────────
module DisclaimerHelper
  DISCLAIMER_TEXT = "본 결과는 모의 계산이며, 정확한 자격 유지 여부는 " \
    "반드시 관할 행정복지센터에 확인하세요. 본 앱은 법적 책임을 지지 않습니다.".freeze

  BENEFIT_DISCLAIMER_TEXT = "본 앱은 혜택 정보를 안내할 뿐, 대리 신청 기능은 " \
    "제공하지 않습니다. 반드시 공식 채널을 통해 직접 신청하세요.".freeze

  # 면책 조항 배너를 렌더링합니다.
  # 옵션:
  #   type: :calculator (기본), :benefit
  #   css_class: 추가 CSS 클래스
  def render_disclaimer(type: :calculator, css_class: "")
    text = case type
    when :benefit then BENEFIT_DISCLAIMER_TEXT
    else DISCLAIMER_TEXT
    end

    content_tag(:div,
      class: "disclaimer-banner bg-amber-50 border border-amber-200 rounded-lg p-3 mt-4 #{css_class}".strip) do
      content_tag(:div, class: "flex items-start gap-2") do
        # 경고 아이콘
        icon = content_tag(:svg, class: "w-5 h-5 text-amber-500 flex-shrink-0 mt-0.5",
          fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor") do
          content_tag(:path,
            "",
            stroke_linecap: "round",
            stroke_linejoin: "round",
            d: "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"
          )
        end
        text_el = content_tag(:p, text, class: "text-xs text-amber-700 leading-relaxed")
        safe_join([ icon, text_el ])
      end
    end
  end
end
