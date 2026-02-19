# frozen_string_literal: true

# ────────────────────────────────────────────────────────────────
# Seed Data — 개발/데모용 초기 데이터
# ────────────────────────────────────────────────────────────────
# 실행: rails db:seed
# ────────────────────────────────────────────────────────────────

puts "🌱 시드 데이터 생성 시작..."

# ── 1. 테스트 사용자 ─────────────────────────────────────────
recipient = User.find_or_create_by!(email: "recipient@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.name = "김수급"
  u.role = :recipient
end
puts "  ✅ 수급자 계정: recipient@example.com / password123"

caregiver = User.find_or_create_by!(email: "caregiver@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.name = "이보호"
  u.role = :caregiver
end
puts "  ✅ 보호자 계정: caregiver@example.com / password123"

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.name = "관리자"
  u.role = :admin
end
puts "  ✅ 관리자 계정: admin@example.com / password123"

# ── 2. 수급자 프로필 ─────────────────────────────────────────
profile = recipient.user_profile || recipient.build_user_profile
profile.update!(
  household_size: 4,
  region_type: "metropolitan",
  housing_type: "monthly_rent",
  declared_monthly_income: "800000",
  declared_assets: "30000000",
  vehicle_value: "0"
)
puts "  ✅ 수급자 프로필 (4인 가구, 대도시, 월세)"

# ── 3. 보호자 관계 ───────────────────────────────────────────
care = CareRelation.find_or_create_by!(caregiver: caregiver, recipient: recipient) do |c|
  c.status = :accepted
end
care.update!(status: :accepted)
puts "  ✅ 보호 관계: 이보호 → 김수급 (수락됨)"

# ── 4. 혜택 데이터 ───────────────────────────────────────────
benefits_data = [
  {
    external_id: "LIV001",
    title: "생계급여",
    summary: "기초생활보장 생계급여. 중위소득 32% 이하 가구에 생활비를 지원합니다.",
    apply_url: "https://www.bokjiro.go.kr",
    is_safe_savings: false
  },
  {
    external_id: "LIV002",
    title: "주거급여",
    summary: "중위소득 48% 이하 가구에 임차료 또는 수선비를 지원합니다.",
    apply_url: "https://www.bokjiro.go.kr",
    is_safe_savings: false
  },
  {
    external_id: "LIV003",
    title: "의료급여",
    summary: "의료비 부담을 줄여주는 의료급여. 본인부담금 경감 혜택이 포함됩니다.",
    apply_url: "https://www.bokjiro.go.kr",
    is_safe_savings: false
  },
  {
    external_id: "LIV004",
    title: "교육급여",
    summary: "중위소득 50% 이하 가구의 초·중·고 자녀에게 교육비를 지원합니다.",
    apply_url: "https://www.bokjiro.go.kr",
    is_safe_savings: false
  },
  {
    external_id: "SAV001",
    title: "희망저축계좌 I",
    summary: "근로·사업소득이 있는 생계·의료급여 수급자 대상. 월 10만원 저축 시 정부가 30만원 매칭.",
    apply_url: "https://www.bokjiro.go.kr/ssis-tbu/twataa/sociGuaSa498Lst.do",
    is_safe_savings: true
  },
  {
    external_id: "SAV002",
    title: "희망저축계좌 II",
    summary: "주거·교육급여 수급자 및 차상위계층 대상. 월 10만원 저축 시 정부가 10만원 매칭.",
    apply_url: "https://www.bokjiro.go.kr/ssis-tbu/twataa/sociGuaSa498Lst.do",
    is_safe_savings: true
  },
  {
    external_id: "SAV003",
    title: "내일키움통장",
    summary: "자활근로 참여자 대상 자산형성 지원. 매월 근로소득에서 일정액 저축 시 정부매칭.",
    apply_url: "https://www.bokjiro.go.kr",
    is_safe_savings: true
  },
  {
    external_id: "SAV004",
    title: "청년저축계좌",
    summary: "만 15-39세 차상위 이하 청년 대상. 월 10만원 저축 시 정부 30만원 매칭, 3년간.",
    apply_url: "https://www.bokjiro.go.kr",
    is_safe_savings: true
  }
]

benefits_data.each do |data|
  Benefit.find_or_create_by!(external_id: data[:external_id]) do |b|
    b.assign_attributes(data)
  end
end
puts "  ✅ 혜택 #{benefits_data.size}건 (일반 #{benefits_data.count { |b| !b[:is_safe_savings] }}, 저축통장 #{benefits_data.count { |b| b[:is_safe_savings] }})"

# ── 5. 관심 혜택 등록 ────────────────────────────────────────
livelihood = Benefit.find_by(external_id: "LIV001")
savings = Benefit.find_by(external_id: "SAV001")

if livelihood
  UserBenefit.find_or_create_by!(user: recipient, benefit: livelihood) do |ub|
    ub.status = :applied
  end
end

if savings
  UserBenefit.find_or_create_by!(user: recipient, benefit: savings) do |ub|
    ub.status = :preparing_documents
  end
end
puts "  ✅ 관심 혜택 등록 (생계급여: 신청완료, 희망저축 I: 서류준비중)"

# ── 6. 현금흐름 이벤트 ───────────────────────────────────────
today = Date.current
this_month = today.beginning_of_month

events_data = [
  # 이번 달
  { title: "생계급여 입금", event_date: this_month + 19, expected_amount: 713_102, event_type: :payment },
  { title: "주거급여 입금", event_date: this_month + 19, expected_amount: 310_000, event_type: :payment },
  { title: "건강보험료", event_date: this_month + 24, expected_amount: 15_200, event_type: :deduction },
  { title: "전기요금", event_date: this_month + 27, expected_amount: 32_000, event_type: :deduction },

  # 다음 달
  { title: "생계급여 입금", event_date: (this_month >> 1) + 19, expected_amount: 713_102, event_type: :payment },
  { title: "주거급여 입금", event_date: (this_month >> 1) + 19, expected_amount: 310_000, event_type: :payment },
  { title: "건강보험료", event_date: (this_month >> 1) + 24, expected_amount: 15_200, event_type: :deduction },
]

events_data.each do |data|
  CashflowEvent.find_or_create_by!(
    user: recipient,
    title: data[:title],
    event_date: data[:event_date]
  ) do |ev|
    ev.expected_amount = data[:expected_amount]
    ev.event_type = data[:event_type]
  end
end
puts "  ✅ 현금흐름 이벤트 #{events_data.size}건"

puts ""
puts "🎉 시드 데이터 생성 완료!"
puts ""
puts "📌 테스트 로그인 정보:"
puts "   수급자: recipient@example.com / password123"
puts "   보호자: caregiver@example.com / password123"
puts "   관리자: admin@example.com / password123"
