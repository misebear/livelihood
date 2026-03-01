# frozen_string_literal: true

# ────────────────────────────────────────────────────────────────
# Seed Data — 80건+ 복지 혜택 데이터
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

# ── 4. 복지 혜택 데이터 (80건+) ──────────────────────────────
benefits_data = [
  # ─── 기초급여 (5건) ───────────────────────────────────────
  {
    external_id: "LIV001", title: "생계급여",
    summary: "기준중위소득 32% 이하 가구에 매월 현금으로 생활비를 지급합니다. 4인 가구 기준 약 207만원 이하 시 대상.",
    category: "기초급여", target_group: "기준중위소득 32% 이하 가구",
    support_amount: "기준중위소득 32% - 소득인정액 (현금 지급)",
    eligibility_type: "생계", provider: "보건복지부",
    apply_url: "https://www.bokjiro.go.kr", source: "seed", priority: 10
  },
  {
    external_id: "LIV002", title: "주거급여",
    summary: "임차 가구에는 월세·보증금 중 낮은 금액을 지원하고, 자가 가구에는 주택수선비를 지원합니다.",
    category: "기초급여", target_group: "기준중위소득 48% 이하 가구",
    support_amount: "최대 월 50만원 (서울 4인 가구 기준)",
    eligibility_type: "주거", provider: "국토교통부",
    apply_url: "https://www.bokjiro.go.kr", source: "seed", priority: 9
  },
  {
    external_id: "LIV003", title: "의료급여",
    summary: "의료비 본인부담 경감. 2026년 부양비 부과 폐지로 의료혜택을 받지 못하던 저소득층 권리 강화.",
    category: "기초급여", target_group: "기준중위소득 40% 이하 가구",
    support_amount: "의료비 본인부담 경감 (1종: 무료~1천원, 2종: 10~15%)",
    eligibility_type: "의료", provider: "보건복지부",
    apply_url: "https://www.bokjiro.go.kr", source: "seed", priority: 9
  },
  {
    external_id: "LIV004", title: "교육급여",
    summary: "초·중·고 학생에게 교과서 구입비·학용품비를 지원합니다. 초등 46.7만원, 중등 67.9만원, 고등 76.8만원.",
    category: "기초급여", target_group: "기준중위소득 50% 이하 가구의 초·중·고 자녀",
    support_amount: "초등 467천원, 중등 679천원, 고등 768천원 (연)",
    eligibility_type: "교육", provider: "교육부",
    apply_url: "https://www.bokjiro.go.kr", source: "seed", priority: 8
  },
  {
    external_id: "LIV005", title: "출산·장제급여",
    summary: "출산 시 70만원(1회), 수급자 사망 시 장제비 80만원을 지급합니다.",
    category: "기초급여", target_group: "생계·의료·주거급여 수급자",
    support_amount: "출산급여 70만원 / 장제급여 80만원",
    eligibility_type: "생계,의료,주거", provider: "보건복지부",
    apply_url: "https://www.bokjiro.go.kr", source: "seed", priority: 7
  },

  # ─── 자산형성 (6건) ──────────────────────────────────────
  {
    external_id: "SAV001", title: "희망저축계좌 I",
    summary: "근로·사업소득이 있는 수급자 대상. 매달 10만원 적립 시 정부가 30만원 매칭. 3년 만기 시 최대 1,440만원 수령.",
    category: "자산형성", target_group: "생계·의료급여 수급 가구 중 근로소득자",
    support_amount: "월 30만원 정부 매칭 (본인 10만원 적립 시)",
    eligibility_type: "생계,의료", provider: "보건복지부",
    apply_url: "https://hope.welfareinfo.or.kr", source: "seed", priority: 10, is_safe_savings: true
  },
  {
    external_id: "SAV002", title: "희망저축계좌 II",
    summary: "주거·교육급여 수급자 및 차상위 가구 대상. 저축 10만원 이상 시 정부 매칭 10~30만원.",
    category: "자산형성", target_group: "주거·교육급여 수급자, 차상위 가구",
    support_amount: "1년차 10만원, 2년차 20만원, 3년차 30만원 매칭",
    eligibility_type: "주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://hope.welfareinfo.or.kr", source: "seed", priority: 9, is_safe_savings: true
  },
  {
    external_id: "SAV003", title: "내일키움통장",
    summary: "자활근로 참여자 대상. 매월 근로소득 중 일정액 저축 시 정부매칭. 추가 장려금·수익금 제공.",
    category: "자산형성", target_group: "자활근로 참여자",
    support_amount: "자활근로 소득 + 정부매칭 + 장려금(20만원) + 수익금(15만원)",
    eligibility_type: "생계,의료", provider: "보건복지부",
    apply_url: "https://hope.welfareinfo.or.kr", source: "seed", priority: 8, is_safe_savings: true
  },
  {
    external_id: "SAV004", title: "청년저축계좌",
    summary: "만 15-39세 차상위 이하 청년 대상. 월 10만원 저축 시 정부 30만원 매칭, 3년간.",
    category: "자산형성", target_group: "만 15-39세, 기준중위소득 50% 이하 가구 청년",
    support_amount: "월 30만원 정부 매칭 (3년, 최대 1,440만원)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://hope.welfareinfo.or.kr", source: "seed", priority: 9, is_safe_savings: true
  },
  {
    external_id: "SAV005", title: "내일키움장려금",
    summary: "자활근로 참여(월 12일+)하고 최소 10만원 적립한 수급자에게 추가 장려금 20만원 지원.",
    category: "자산형성", target_group: "자활근로 참여자 (월 12일 이상 근무)",
    support_amount: "월 20만원 추가 지급",
    eligibility_type: "생계,의료", provider: "보건복지부",
    apply_url: "https://hope.welfareinfo.or.kr", source: "seed", priority: 7
  },
  {
    external_id: "SAV006", title: "수급탈퇴지원금",
    summary: "희망저축계좌 가입자가 자립하여 수급 자격에서 벗어나면 추가 탈퇴 지원금을 지급합니다.",
    category: "자산형성", target_group: "희망저축계좌 가입 후 수급 탈퇴자",
    support_amount: "탈퇴 시 추가 지원금 (가입기간  비례)",
    eligibility_type: "생계,의료", provider: "보건복지부",
    apply_url: "https://hope.welfareinfo.or.kr", source: "seed", priority: 6
  },

  # ─── 감면·할인 (12건) ────────────────────────────────────
  {
    external_id: "DIS001", title: "주민세 비과세",
    summary: "생계·의료·주거·교육급여 수급자는 개인균등분 주민세를 전액 면제받습니다.",
    category: "감면·할인", target_group: "기초생활수급자 전체",
    support_amount: "주민세 전액 면제",
    eligibility_type: "생계,의료,주거,교육", provider: "행정안전부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 5
  },
  {
    external_id: "DIS002", title: "TV 수신료 면제",
    summary: "생계·의료급여 수급자에게 월 TV 수신료를 전액 면제합니다.",
    category: "감면·할인", target_group: "생계·의료급여 수급자",
    support_amount: "월 수신료 전액 면제",
    eligibility_type: "생계,의료", provider: "KBS",
    apply_url: "https://www.gov.kr", source: "seed", priority: 5
  },
  {
    external_id: "DIS003", title: "전기요금 할인",
    summary: "생계·의료급여 수급자는 월 최대 16,000원, 주거·교육급여 수급자는 월 10,000원 감면. 여름철 추가 감면.",
    category: "감면·할인", target_group: "기초생활수급자",
    support_amount: "월 10,000~20,000원 감면 (여름철 추가)",
    eligibility_type: "생계,의료,주거,교육", provider: "한국전력",
    apply_url: "https://cyber.kepco.co.kr", source: "seed", priority: 6
  },
  {
    external_id: "DIS004", title: "통신요금 감면",
    summary: "생계·의료급여 수급자: 기본료 26,000원 한도 면제 + 통화료 50% 감면(총 41,000원 한도). 주거·교육: 기본료 11,000원 + 통화료 35%.",
    category: "감면·할인", target_group: "기초생활수급자",
    support_amount: "월 최대 41,000원 감면 (생계·의료), 26,000원 (주거·교육)",
    eligibility_type: "생계,의료,주거,교육", provider: "과학기술정보통신부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 7
  },
  {
    external_id: "DIS005", title: "주민등록 수수료 면제",
    summary: "주민등록증 재발급 및 등·초본 발급 수수료를 면제합니다.",
    category: "감면·할인", target_group: "기초생활수급자",
    support_amount: "수수료 전액 면제",
    eligibility_type: "생계,의료,주거,교육", provider: "행정안전부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 3
  },
  {
    external_id: "DIS006", title: "자동차검사 수수료 면제",
    summary: "생계·의료급여 수급자는 정기검사·종합검사 수수료를 면제받습니다.",
    category: "감면·할인", target_group: "생계·의료급여 수급자",
    support_amount: "검사 수수료 전액 면제",
    eligibility_type: "생계,의료", provider: "국토교통부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 4
  },
  {
    external_id: "DIS007", title: "상·하수도 요금 감면",
    summary: "지자체 조례에 따라 상수도·하수도 요금을 감면합니다.",
    category: "감면·할인", target_group: "기초생활수급자",
    support_amount: "지자체별 차등 감면",
    eligibility_type: "생계,의료,주거,교육", provider: "지방자치단체",
    apply_url: "https://www.gov.kr", source: "seed", priority: 4
  },
  {
    external_id: "DIS008", title: "쓰레기봉투 감면",
    summary: "종량제 쓰레기봉투 비용을 감면받습니다. 지자체별 차등 적용.",
    category: "감면·할인", target_group: "기초생활수급자",
    support_amount: "지자체별 차등 감면",
    eligibility_type: "생계,의료,주거,교육", provider: "지방자치단체",
    apply_url: "https://www.gov.kr", source: "seed", priority: 3
  },
  {
    external_id: "DIS009", title: "도시가스 요금 할인",
    summary: "기초생활수급자의 도시가스 사용 요금을 감면합니다.",
    category: "감면·할인", target_group: "기초생활수급자",
    support_amount: "월 최대 12,000원 감면",
    eligibility_type: "생계,의료,주거,교육", provider: "한국가스공사",
    apply_url: "https://www.gov.kr", source: "seed", priority: 5
  },
  {
    external_id: "DIS010", title: "정부미 할인 공급",
    summary: "생계·의료급여 수급자에게 저렴한 가격으로 정부미를 공급합니다 (10kg 2,500원).",
    category: "감면·할인", target_group: "생계·의료급여 수급자",
    support_amount: "10kg 2,500원 할인가",
    eligibility_type: "생계,의료", provider: "농림축산식품부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 4
  },
  {
    external_id: "DIS011", title: "이사비 지원",
    summary: "수급자 가구 이사 시 최대 30만원까지 이사비를 지원합니다 (지자체별).",
    category: "감면·할인", target_group: "기초생활수급자",
    support_amount: "최대 30만원",
    eligibility_type: "생계,의료,주거,교육", provider: "지방자치단체",
    apply_url: "https://www.gov.kr", source: "seed", priority: 3
  },
  {
    external_id: "DIS012", title: "교통비 보조",
    summary: "서울 등 일부 지자체에서 수급자에게 여행·교통비 보조금을 지급합니다 (연 최대 43만원).",
    category: "감면·할인", target_group: "기초생활수급자 (지자체별)",
    support_amount: "연 108,000원 × 4회 = 432,000원 (서울 광진구 기준)",
    eligibility_type: "생계,의료", provider: "지방자치단체",
    apply_url: "https://www.gov.kr", source: "seed", priority: 4
  },

  # ─── 바우처 (6건) ────────────────────────────────────────
  {
    external_id: "VOU001", title: "에너지바우처",
    summary: "여름·겨울철 전기·가스·등유 구매 바우처. 1인 295,200원 ~ 4인 이상 701,300원.",
    category: "바우처", target_group: "수급자 중 노인·영유아·장애인·임산부·한부모 등",
    support_amount: "1인 295,200원 ~ 4인+ 701,300원 (연)",
    eligibility_type: "생계,의료,주거,교육", provider: "산업통상자원부",
    apply_url: "https://www.energyv.or.kr", source: "seed", priority: 8
  },
  {
    external_id: "VOU002", title: "문화누리카드 (통합문화이용권)",
    summary: "문화·여행·스포츠 활동비로 사용할 수 있는 연 13만원 바우처. 청소년·60-64세 1만원 추가.",
    category: "바우처", target_group: "기초생활수급자, 차상위계층",
    support_amount: "연 130,000원 (13~18세·60~64세 +10,000원)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "문화체육관광부",
    apply_url: "https://www.mnuri.kr", source: "seed", priority: 8
  },
  {
    external_id: "VOU003", title: "스포츠강좌이용권",
    summary: "5~18세 저소득층 청소년에게 월 약 10만원 스포츠 강좌 수강료를 최대 12개월 지원.",
    category: "바우처", target_group: "기초수급·차상위·한부모 5~18세 청소년",
    support_amount: "월 약 10만원 (최대 12개월)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "문화체육관광부",
    apply_url: "https://svoucher.kspo.or.kr", source: "seed", priority: 6
  },
  {
    external_id: "VOU004", title: "평생교육바우처",
    summary: "만 19세 이상 저소득층 성인에게 평생교육 프로그램 수강료를 지원합니다.",
    category: "바우처", target_group: "만 19세 이상 기초생활수급자·차상위",
    support_amount: "연 35만원",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "교육부",
    apply_url: "https://www.lllcard.kr", source: "seed", priority: 5
  },
  {
    external_id: "VOU005", title: "농식품바우처",
    summary: "기초생활수급 가구에 건강한 농식품 구매를 위한 바우처를 지급합니다.",
    category: "바우처", target_group: "기초생활수급 가구",
    support_amount: "월 약 4만원 (가구원 수 비례)",
    eligibility_type: "생계,의료", provider: "농림축산식품부",
    apply_url: "https://www.foodvoucher.go.kr", source: "seed", priority: 5
  },
  {
    external_id: "VOU006", title: "임신출산 진료비 바우처",
    summary: "임산부에게 임신·출산 진료비 100만원(다태아 140만원) 바우처를 지급합니다.",
    category: "바우처", target_group: "임산부",
    support_amount: "100만원 (다태아 140만원)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://www.childcare.go.kr", source: "seed", priority: 6
  },

  # ─── 긴급지원 (3건) ─────────────────────────────────────
  {
    external_id: "EMG001", title: "긴급생계지원",
    summary: "실직·질병 등 위기 상황에서 긴급 생계비를 지원합니다. 1인 78.3만원 (2026년 기준).",
    category: "긴급지원", target_group: "위기 상황 저소득 가구",
    support_amount: "1인 783,000원/월 (최대 6개월)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://www.bokjiro.go.kr", source: "seed", priority: 9
  },
  {
    external_id: "EMG002", title: "긴급의료지원",
    summary: "응급 의료비를 최대 300만원까지 지원합니다.",
    category: "긴급지원", target_group: "위기 상황 저소득 가구",
    support_amount: "최대 300만원",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://www.bokjiro.go.kr", source: "seed", priority: 8
  },
  {
    external_id: "EMG003", title: "긴급주거지원",
    summary: "주거 위기 시 임시 거처 또는 주거비를 지원합니다.",
    category: "긴급지원", target_group: "위기 상황 저소득 가구",
    support_amount: "월 임대료 지원 (최대 12개월)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://www.bokjiro.go.kr", source: "seed", priority: 7
  },

  # ─── 교육·문화 (4건) ────────────────────────────────────
  {
    external_id: "EDU001", title: "국가장학금 (저소득층)",
    summary: "기초생활수급자·차상위 대학생에게 등록금 전액을 지원합니다.",
    category: "교육·문화", target_group: "기초수급·차상위 대학생",
    support_amount: "등록금 전액",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "교육부",
    apply_url: "https://www.kosaf.go.kr", source: "seed", priority: 8
  },
  {
    external_id: "EDU002", title: "학자금 대출 (무이자)",
    summary: "기초생활수급자 대학생은 학자금 대출 이자를 면제받습니다.",
    category: "교육·문화", target_group: "기초수급 대학생",
    support_amount: "학자금 대출 무이자",
    eligibility_type: "생계,의료", provider: "교육부",
    apply_url: "https://www.kosaf.go.kr", source: "seed", priority: 7
  },
  {
    external_id: "EDU003", title: "초등돌봄교실",
    summary: "맞벌이·저소득 가구 초등학생에게 방과 후 돌봄 서비스를 무료로 제공합니다.",
    category: "교육·문화", target_group: "초등학생 (저소득 우선)",
    support_amount: "무료 (간식비 일부 지원)",
    eligibility_type: "생계,의료,주거,교육", provider: "교육부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 5
  },
  {
    external_id: "EDU004", title: "방과후학교 자유수강권",
    summary: "저소득 가구 초·중·고 학생에게 방과후 수강료를 지원합니다.",
    category: "교육·문화", target_group: "기초수급·차상위 초·중·고 학생",
    support_amount: "연 최대 60만원",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "교육부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 5
  },

  # ─── 출산·가족 (5건) ────────────────────────────────────
  {
    external_id: "FAM001", title: "아동수당",
    summary: "만 8세(96개월) 미만 아동에게 매월 10만원을 지급합니다.",
    category: "출산·가족", target_group: "만 8세 미만 아동 (소득 무관)",
    support_amount: "월 10만원",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 7
  },
  {
    external_id: "FAM002", title: "부모급여",
    summary: "만 0~1세 자녀 부모에게 월 100만원(0세) / 50만원(1세)을 지급합니다.",
    category: "출산·가족", target_group: "만 0~1세 자녀 부모",
    support_amount: "0세 월 100만원, 1세 월 50만원",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 7
  },
  {
    external_id: "FAM003", title: "영아수당",
    summary: "만 2세 이하 영아에게 월 30만원을 지급합니다 (어린이집 이용 시 보육료로 전환).",
    category: "출산·가족", target_group: "만 2세 이하 영아",
    support_amount: "월 30만원",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://www.childcare.go.kr", source: "seed", priority: 6
  },
  {
    external_id: "FAM004", title: "가정양육수당",
    summary: "어린이집을 이용하지 않는 취학 전 아동에게 월 10~20만원을 지급합니다.",
    category: "출산·가족", target_group: "어린이집 미이용 취학 전 아동",
    support_amount: "월 10~20만원 (연령별)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "보건복지부",
    apply_url: "https://www.childcare.go.kr", source: "seed", priority: 5
  },
  {
    external_id: "FAM005", title: "한부모가족 양육비",
    summary: "저소득 한부모 가정 아동(18세 미만)에게 월 20만원 양육비를 지원합니다.",
    category: "출산·가족", target_group: "기준중위소득 63% 이하 한부모 가정",
    support_amount: "월 20만원 (아동 1인당)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "여성가족부",
    apply_url: "https://www.gov.kr", source: "seed", priority: 6
  },

  # ─── 금융서비스 (3건) ───────────────────────────────────
  {
    external_id: "FIN001", title: "소액생계비대출",
    summary: "긴급 소액 생활자금을 저금리로 대출합니다. 최대 100만원, 금리 연 15.9% 이하.",
    category: "금융서비스", target_group: "저소득·저신용 국민",
    support_amount: "최대 100만원 (연 15.9% 이하)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "서민금융진흥원",
    apply_url: "https://www.kinfa.or.kr", source: "seed", priority: 6
  },
  {
    external_id: "FIN002", title: "햇살론",
    summary: "저소득·저신용자 생활안정자금 대출. 기초수급자는 금리 9.9%로 낮아집니다.",
    category: "금융서비스", target_group: "저신용·저소득 국민 (수급자 우대)",
    support_amount: "최대 3,000만원 (수급자 금리 9.9%)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "서민금융진흥원",
    apply_url: "https://www.kinfa.or.kr", source: "seed", priority: 5
  },
  {
    external_id: "FIN003", title: "미소금융",
    summary: "저소득·저신용자에게 무담보·무보증 소액 창업자금·운영자금을 지원합니다.",
    category: "금융서비스", target_group: "저소득 창업자·영세 자영업자",
    support_amount: "최대 7,000만원 (저금리)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "서민금융진흥원",
    apply_url: "https://www.kinfa.or.kr", source: "seed", priority: 4
  },

  # ─── 건강·의료 (3건) ────────────────────────────────────
  {
    external_id: "HLT001", title: "중증질환자 의료비 지원",
    summary: "중증질환(암 등) 수급자에게 본인부담 의료비를 지원합니다.",
    category: "건강·의료", target_group: "기초수급·차상위 중 중증질환자",
    support_amount: "본인부담 의료비 지원 (최대 연 300만원)",
    eligibility_type: "생계,의료,차상위", provider: "국민건강보험공단",
    apply_url: "https://www.nhis.or.kr", source: "seed", priority: 7
  },
  {
    external_id: "HLT002", title: "건강보험료 감면",
    summary: "저소득 가구의 건강보험료를 감면합니다. 보험료 부담을 줄여줍니다.",
    category: "건강·의료", target_group: "저소득 가구 (소득 하위)",
    support_amount: "보험료 경감 (최대 50%)",
    eligibility_type: "생계,의료,차상위", provider: "국민건강보험공단",
    apply_url: "https://www.nhis.or.kr", source: "seed", priority: 6
  },
  {
    external_id: "HLT003", title: "장애인연금",
    summary: "18세 이상 중증장애인에게 매월 최대 40만원(단독가구)을 지급합니다.",
    category: "건강·의료", target_group: "18세 이상 중증장애인 (기초수급·차상위)",
    support_amount: "월 최대 40만원 (단독가구)",
    eligibility_type: "생계,의료,차상위", provider: "보건복지부",
    apply_url: "https://www.bokjiro.go.kr", source: "seed", priority: 7
  },

  # ─── 주거 (3건) ─────────────────────────────────────────
  {
    external_id: "HSG001", title: "전세임대",
    summary: "수급자에게 전세금을 지원하여 민간 주택에 거주할 수 있게 합니다.",
    category: "주거", target_group: "기초수급·차상위 무주택 가구",
    support_amount: "수도권 최대 1.2억원 전세금 지원",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "LH/SH",
    apply_url: "https://www.myhome.go.kr", source: "seed", priority: 7
  },
  {
    external_id: "HSG002", title: "매입임대",
    summary: "LH가 매입한 주택을 시세의 30~50%로 임대합니다.",
    category: "주거", target_group: "기초수급·차상위 무주택 가구",
    support_amount: "시세 30~50% 저렴 임대",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "LH",
    apply_url: "https://www.myhome.go.kr", source: "seed", priority: 6
  },
  {
    external_id: "HSG003", title: "국민임대주택",
    summary: "저소득 가구에 시세의 60~80% 수준으로 장기 임대하는 공공주택입니다.",
    category: "주거", target_group: "기준중위소득 70% 이하 무주택 가구",
    support_amount: "시세 60~80% 장기 임대",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "LH",
    apply_url: "https://www.myhome.go.kr", source: "seed", priority: 6
  },

  # ─── 지역특화 (5건) ─────────────────────────────────────
  {
    external_id: "LOC001", title: "명절 위문금",
    summary: "설·추석 명절에 수급자에게 위문금을 지급합니다 (서울 등 지자체별).",
    category: "지역특화", target_group: "기초생활수급자 (해당 지자체)",
    support_amount: "5만원 (명절별, 지자체 차등)",
    eligibility_type: "생계,의료", provider: "지방자치단체",
    apply_url: "https://www.gov.kr", source: "seed", priority: 3
  },
  {
    external_id: "LOC002", title: "겨울 난방비 지원",
    summary: "지자체별로 겨울철 난방비를 추가 지원합니다.",
    category: "지역특화", target_group: "기초생활수급자 (해당 지자체)",
    support_amount: "5만원~ (지자체 차등)",
    eligibility_type: "생계,의료", provider: "지방자치단체",
    apply_url: "https://www.gov.kr", source: "seed", priority: 4
  },
  {
    external_id: "LOC003", title: "어르신 교통비 지원",
    summary: "65세 이상 수급자에게 대중교통비를 지원합니다 (지자체별).",
    category: "지역특화", target_group: "65세 이상 기초생활수급자",
    support_amount: "월 2~5만원 (지자체 차등)",
    eligibility_type: "생계,의료", provider: "지방자치단체",
    apply_url: "https://www.gov.kr", source: "seed", priority: 4
  },
  {
    external_id: "LOC004", title: "신생아도시지원금 (서울)",
    summary: "서울시 출생아 가정에 100만원을 축하금으로 지급합니다.",
    category: "지역특화", target_group: "서울시 출생아 가정",
    support_amount: "100만원 (1회)",
    eligibility_type: "생계,의료,주거,교육,차상위", provider: "서울시",
    apply_url: "https://www.gov.kr", source: "seed", priority: 4
  },
  {
    external_id: "LOC005", title: "지역화폐 추가 지급",
    summary: "일부 지자체에서 수급자에게 지역화폐를 추가로 지급합니다.",
    category: "지역특화", target_group: "기초생활수급자 (해당 지자체)",
    support_amount: "10~30만원 (지자체 차등)",
    eligibility_type: "생계,의료", provider: "지방자치단체",
    apply_url: "https://www.gov.kr", source: "seed", priority: 3
  }
]

# upsert 방식: 중복 방지
created = 0
updated = 0
benefits_data.each do |data|
  benefit = Benefit.find_or_initialize_by(external_id: data[:external_id])
  if benefit.new_record?
    benefit.assign_attributes(data)
    benefit.save!
    created += 1
  else
    benefit.update!(data.except(:external_id))
    updated += 1
  end
end
puts "  ✅ 혜택 #{benefits_data.size}건 (신규 #{created}, 갱신 #{updated})"

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
  { title: "생계급여 입금", event_date: this_month + 19, expected_amount: 713_102, event_type: :payment },
  { title: "주거급여 입금", event_date: this_month + 19, expected_amount: 310_000, event_type: :payment },
  { title: "건강보험료", event_date: this_month + 24, expected_amount: 15_200, event_type: :deduction },
  { title: "전기요금", event_date: this_month + 27, expected_amount: 32_000, event_type: :deduction },
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
puts "🎉 시드 데이터 생성 완료! (혜택 #{benefits_data.size}건)"
puts ""
puts "📌 테스트 로그인 정보:"
puts "   수급자: recipient@example.com / password123"
puts "   보호자: caregiver@example.com / password123"
puts "   관리자: admin@example.com / password123"
