# frozen_string_literal: true

require "cgi"
require "uri"

class PlayAppCatalog
  UPDATED_ON = Date.new(2026, 8, 26)

  ACTIVE_APPS = [
    { slug: "one-minute-saju", name: "1분 사주", package_name: "app.railway.up.app_1min_saju_production.twa", summary: "사주, 오늘 운세, 궁합과 타로 결과를 짧게 확인하는 엔터테인먼트 앱", category: "LifestyleApplication", audience: "복잡한 용어 없이 가볍게 운세 콘텐츠를 보고 싶은 사용자", highlights: [ "오늘 운세와 사주 흐름", "궁합과 타로 콘텐츠", "짧게 확인하고 공유하는 결과" ], caution: "운세 결과는 오락과 참고용이며 중요한 결정을 대신하지 않습니다." },
    { slug: "bodymagic", name: "BodyMagic", package_name: "com.bodymagic.app", summary: "카메라 기반 자세 관찰과 운동 기록을 한곳에서 관리하는 피트니스 보조 앱", category: "HealthApplication", audience: "자세 변화와 운동 루틴을 꾸준히 기록하고 싶은 사용자", highlights: [ "자세 관찰 기록", "운동 루틴 정리", "변화 흐름 확인" ], caution: "의료 진단이나 치료를 제공하지 않으며 통증이 있으면 전문가의 안내를 우선하세요." },
    { slug: "haruscene", name: "Daily Scene - AI Story Chat", package_name: "com.bodeum.haruscene", summary: "대화와 장면 기록을 이어가는 로컬 중심 AI 스토리 채팅 앱", category: "EntertainmentApplication", audience: "캐릭터와 이야기의 맥락을 이어가며 대화하고 싶은 사용자", highlights: [ "AI 캐릭터 대화", "장면과 기억 기록", "이야기 흐름 관리" ], support_path: "/haruscene/support", privacy_path: "/haruscene/privacy" },
    { slug: "daymint", name: "DayMint", package_name: "com.daymint.routine", summary: "오늘의 작은 루틴을 기록하고 다시 이어가기 쉽게 정리하는 생활 앱", category: "LifestyleApplication", audience: "부담 없는 일상 루틴을 만들고 싶은 사용자", highlights: [ "하루 루틴 기록", "완료 흐름 확인", "다시 시작하기 쉬운 구성" ] },
    { slug: "dialfocus", name: "DialFocus", package_name: "com.dialfocus.app", summary: "집중 시간과 휴식 시간을 다이얼로 빠르게 설정하는 포커스 타이머", category: "ProductivityApplication", audience: "공부와 업무 집중 세션을 단순하게 관리하고 싶은 사용자", highlights: [ "다이얼형 집중 타이머", "집중과 휴식 전환", "짧은 세션 기록" ] },
    { slug: "lumaleaf", name: "LumaLeaf 식물 조도계", package_name: "com.lumaleaf.app", summary: "휴대폰 조도 측정과 식물별 빛 관리 기록을 돕는 식물 케어 앱", category: "LifestyleApplication", audience: "실내 식물이 받는 빛을 확인하고 관리 루틴을 만들고 싶은 사용자", highlights: [ "휴대폰 조도 측정", "식물별 빛 기록", "물주기와 관리 알림" ], caution: "측정값은 기기 센서와 환경에 따라 달라질 수 있습니다." },
    { slug: "mulmi", name: "Mulmi: Car Sickness Aid", package_name: "com.mulmi.ridecue", summary: "차량 탑승자가 화면을 볼 때 움직임을 가장자리 점으로 확인하는 Android 오버레이", category: "UtilitiesApplication", audience: "차와 버스에서 휴대폰 화면을 보는 탑승자", highlights: [ "다른 앱 위 모션 큐", "Quick Settings와 위젯", "탑승자 확인 차량 감지" ], caution: "탑승자 전용 비의료 도구이며 운전 중 사용하면 안 됩니다.", support_path: "https://mulmi.bodeum.me/support/", privacy_path: "https://mulmi.bodeum.me/privacy-policy/" },
    { slug: "neflepedia", name: "Neflepedia", package_name: "com.kmoltbook.neflepedia", summary: "관심 주제를 탐색하고 핵심 내용을 정리해 읽는 지식형 콘텐츠 앱", category: "EducationApplication", audience: "짧은 시간에 새로운 주제의 배경과 핵심을 살펴보고 싶은 사용자", highlights: [ "주제별 콘텐츠 탐색", "핵심 내용 요약", "읽을거리 모아보기" ] },
    { slug: "nownote", name: "NowNote: 메모·할 일·캘린더", package_name: "com.bodeum.nownote", summary: "메모, 할 일과 캘린더 일정을 한 흐름으로 연결하는 개인 정리 앱", category: "ProductivityApplication", audience: "여러 앱에 흩어진 메모와 일정을 한곳에서 관리하고 싶은 사용자", highlights: [ "빠른 메모", "할 일 관리", "캘린더 일정 연결" ] },
    { slug: "pitchflow", name: "PitchFlow - 보컬 트레이너", package_name: "com.pitchflow.vocal", summary: "마이크 입력의 음정 흐름을 실시간으로 보여주는 보컬 연습 앱", category: "MusicApplication", audience: "노래 음정을 직접 확인하며 반복 연습하고 싶은 사용자", highlights: [ "실시간 음정 분석", "피치 곡선 시각화", "연습 결과 확인" ], caution: "보컬 연습 보조 도구이며 음성 질환의 진단이나 치료를 제공하지 않습니다." },
    { slug: "poopbuddy", name: "PoopBuddy - 반려동물 배변기록", package_name: "com.poopbuddy.app", summary: "반려동물 배변, 식사, 산책과 물 섭취를 함께 기록하는 케어 로그", category: "LifestyleApplication", audience: "반려동물의 일상 변화를 꾸준히 기록하려는 보호자", highlights: [ "배변 빠른 기록", "식사와 산책 로그", "홈 화면 위젯" ], caution: "보호자의 기록을 돕는 앱이며 수의학적 진단을 대신하지 않습니다." },
    { slug: "quiet-hour", name: "Quiet Hour: Soft Clock", package_name: "com.bodeum.quiethour", summary: "부드러운 시계 화면과 집중·휴식 타이머를 제공하는 침대 옆 시계 앱", category: "LifestyleApplication", audience: "잠들기 전과 집중 시간에 방해가 적은 시계를 원하는 사용자", highlights: [ "소프트 클록 화면", "집중과 휴식 타이머", "홈 화면 위젯" ] },
    { slug: "rush-pass", name: "Rush Pass Party", package_name: "com.bodeum.party.rushpass", summary: "숨겨진 타이머가 끝나기 전에 휴대폰을 넘기는 오프라인 파티 게임", category: "GameApplication", audience: "모임에서 설명 없이 바로 시작할 파티 게임이 필요한 사용자", highlights: [ "숨겨진 라운드 타이머", "휴대폰 전달 플레이", "오프라인 모임 게임" ], support_path: "/rush-pass/support", privacy_path: "/rush-pass/privacy" },
    { slug: "selah-one", name: "Selah One: Daily Bible", package_name: "app.selahone.mobile", summary: "매일 한 구절과 묵상 흐름을 차분하게 이어가는 성경 읽기 앱", category: "LifestyleApplication", audience: "짧은 성경 읽기와 묵상 루틴을 만들고 싶은 사용자", highlights: [ "매일 한 구절", "묵상 기록", "읽기 루틴 유지" ] },
    { slug: "simplerec", name: "SimpleRec Screen Recorder", package_name: "com.hyunj.simplerecstudio", summary: "복잡한 편집 없이 화면 녹화를 빠르게 시작하고 관리하는 Android 도구", category: "UtilitiesApplication", audience: "앱 사용법과 게임 화면을 간단히 녹화하려는 사용자", highlights: [ "빠른 화면 녹화", "녹화 파일 관리", "간단한 시작과 중지" ] },
    { slug: "smart-running", name: "Smart Running: AI Form Coach", package_name: "com.smartrunning.app", summary: "달리기 동작을 기록하고 폼을 돌아볼 수 있게 돕는 러닝 연습 앱", category: "HealthApplication", audience: "자신의 러닝 동작과 연습 흐름을 점검하고 싶은 사용자", highlights: [ "러닝 폼 기록", "연습 피드백", "변화 흐름 확인" ], caution: "의료·재활 진단을 제공하지 않으며 통증이나 부상이 있으면 운동을 중지하세요." },
    { slug: "typenovel", name: "TypeNovel", package_name: "com.typenovel.app", summary: "문장을 타이핑하며 이야기를 이어가는 소설 작성과 몰입형 타이핑 앱", category: "ProductivityApplication", audience: "글쓰기와 타이핑을 한 흐름에서 즐기고 싶은 사용자", highlights: [ "몰입형 타이핑", "문장과 장면 작성", "작업 이어쓰기" ] },
    { slug: "oil-widget", name: "기름주의보 - 최저가 주유소", package_name: "me.bodeum.oilwidget", summary: "주변 주유소 가격과 전국 유가 흐름을 지도와 위젯으로 확인하는 앱", category: "MapsApplication", audience: "주유 전에 가까운 가격과 유가 변화를 빠르게 확인하려는 운전자", highlights: [ "주변 주유소 가격", "전국 유가 흐름", "홈 화면 위젯" ] },
    { slug: "dyscatch", name: "난독캐치", package_name: "com.dyscatch.app", summary: "읽기 경험을 점검하고 개인별 읽기 보조 설정과 기록을 제공하는 앱", category: "EducationApplication", audience: "읽기 불편을 관찰하고 보조 설정을 시험하려는 사용자와 보호자", highlights: [ "읽기 경험 체크", "글자와 화면 보조", "변화 기록" ], caution: "난독증을 진단하는 의료 도구가 아니며 전문 평가를 대신하지 않습니다." },
    { slug: "malgnyang", name: "맑냥 - 미세먼지 날씨 위젯", package_name: "com.aether.airflow", summary: "미세먼지와 날씨를 캐릭터와 홈 화면 위젯으로 빠르게 확인하는 앱", category: "WeatherApplication", audience: "외출 전에 공기질과 날씨를 한눈에 보고 싶은 사용자", highlights: [ "현재 미세먼지", "날씨 요약", "홈 화면 위젯" ] },
    { slug: "money-notebook", name: "머니수첩 - 자동 기록 가계부", package_name: "com.bodeum.moneynotebook", summary: "수입과 지출을 간단히 기록하고 월별 흐름을 확인하는 개인 가계부", category: "FinanceApplication", audience: "복잡한 예산 도구보다 빠른 생활비 기록이 필요한 사용자", highlights: [ "수입·지출 기록", "월별 흐름", "카테고리별 정리" ], caution: "개인 기록 도구이며 금융 자문이나 세무 판단을 제공하지 않습니다." },
    { slug: "sikgaek-road", name: "식객로드 - 제주 맛집 지도·코스", package_name: "com.jejubucketlist.sikgaekroad", summary: "제주 맛집을 지도에서 찾고 이동 코스로 묶어보는 여행 탐색 앱", category: "TravelApplication", audience: "제주 여행 중 식당과 동선을 함께 계획하고 싶은 사용자", highlights: [ "제주 맛집 지도", "이동 코스 구성", "장소 모아보기" ] },
    { slug: "idol-master", name: "아이돌 마스터 - 사진 수박게임", package_name: "com.mybias.my_bias_arcade", summary: "좋아하는 사진을 넣어 즐기는 수박게임 방식의 캐주얼 아케이드", category: "GameApplication", audience: "개인 사진으로 가볍게 합성 게임을 즐기고 싶은 사용자", highlights: [ "사용자 사진 게임", "합치기 아케이드", "점수 도전" ] },
    { slug: "annyang", name: "안냥 - 고양이 반응 기록", package_name: "com.jejubucketlist.annyang", summary: "고양이의 표정과 울음 반응을 재미있게 기록하는 반려묘 앱", category: "EntertainmentApplication", audience: "반려묘와의 순간을 관찰하고 기록하고 싶은 집사", highlights: [ "표정 반응 기록", "울음 패턴 확인", "반응 히스토리" ], caution: "엔터테인먼트와 기록용이며 행동·건강 진단을 대신하지 않습니다." },
    { slug: "unam-teacher", name: "어남선생", package_name: "com.unamrecipe.app", summary: "집밥 메뉴와 조리 순서를 보기 쉽게 정리해 따라 만드는 레시피 앱", category: "FoodAndDrinkApplication", audience: "오늘 만들 메뉴와 재료를 빠르게 확인하려는 사용자", highlights: [ "집밥 레시피 탐색", "재료와 순서 정리", "즐겨찾기" ] },
    { slug: "healthday", name: "오늘 운동 캘린더", package_name: "com.byjwstudio.fittocalandroid", summary: "운동한 날과 루틴을 캘린더에 기록하고 꾸준함을 확인하는 피트니스 앱", category: "HealthApplication", audience: "운동 루틴을 달력에서 간단히 관리하고 싶은 사용자", highlights: [ "운동 캘린더", "루틴 기록", "홈 화면 위젯" ], caution: "운동 기록 도구이며 의료·재활 지침을 제공하지 않습니다." },
    { slug: "video-recipe", name: "유튜브 레시피", package_name: "com.yeobo.recipe", summary: "요리 영상 링크에서 재료와 분량을 정리해 장보기 목록으로 만드는 앱", category: "FoodAndDrinkApplication", audience: "영상 레시피를 실제 장보기와 요리에 활용하려는 사용자", highlights: [ "영상 링크 분석", "재료와 분량 정리", "장보기 목록" ] },
    { slug: "zenbowl", name: "젠볼 - 싱잉볼 명상", package_name: "com.zenbowl.app", summary: "싱잉볼 사운드와 타이머로 짧은 휴식과 명상 루틴을 만드는 앱", category: "LifestyleApplication", audience: "집중 전이나 잠들기 전에 차분한 소리를 원하는 사용자", highlights: [ "싱잉볼 사운드", "명상 타이머", "햅틱과 시각 반응" ], caution: "휴식용 사운드 앱이며 의료 치료나 수면 개선을 보장하지 않습니다." },
    { slug: "picchina", name: "찍으면 중국어 - 학습지 OCR 복습", package_name: "com.bodeum.chinesestudyhelper", summary: "중국어 학습지를 촬영해 글자를 정리하고 다시 복습하는 OCR 학습 앱", category: "EducationApplication", audience: "종이 학습지와 교재 내용을 휴대폰에서 복습하려는 학습자", highlights: [ "학습지 OCR", "중국어 문장 정리", "복습 목록" ] },
    { slug: "tteulsite", name: "쿠팡 검색 - 뜰사이트 상품 AI 진단", package_name: "com.koreanmatrix.tteulsite", summary: "상품 검색 결과와 노출 요소를 정리해 판매 페이지 점검을 돕는 도구", category: "BusinessApplication", audience: "온라인 상품의 검색 노출과 설명 구성을 점검하려는 판매자", highlights: [ "상품 검색 확인", "콘텐츠 요소 진단", "개선 항목 정리" ], caution: "특정 마켓의 공식 앱이 아니며 판매나 노출 성과를 보장하지 않습니다." },
    { slug: "time-trader", name: "타임 트레이더", package_name: "com.koreanmatrix.timetrader", summary: "시장 시간과 거래 일정을 확인하고 개인 관찰 기록을 남기는 도구", category: "FinanceApplication", audience: "거래 시간과 시장 일정을 정리해 보고 싶은 사용자", highlights: [ "시장 시간 확인", "거래 일정 정리", "개인 관찰 기록" ], caution: "투자 자문이나 수익 보장을 제공하지 않습니다." },
    { slug: "telegraph", name: "텔레프롬프터 - 영상 대본 프롬프터", package_name: "com.bodeum.telegraph", summary: "카메라를 보며 대본을 자연스럽게 읽도록 돕는 촬영용 텔레프롬프터", category: "VideoApplication", audience: "유튜브, 숏폼, 강의와 발표 영상을 촬영하는 사용자", highlights: [ "대본 자동 스크롤", "글자 크기와 여백", "미러와 촬영 설정" ] },
    { slug: "todaklog", name: "토닥로그 - 함께 쓰는 반려동물 돌봄 기록", package_name: "com.dogcat.carehandoff", summary: "가족과 반려동물 돌봄 기록을 공유하고 인수인계를 돕는 케어 로그", category: "LifestyleApplication", audience: "여러 보호자가 식사, 산책과 투약 기록을 함께 관리하는 가정", highlights: [ "공동 돌봄 기록", "할 일 인수인계", "반려동물별 히스토리" ], caution: "돌봄 기록 도구이며 수의학적 판단을 대신하지 않습니다." },
    { slug: "tokpick", name: "톡픽 - 싫은 말 끄고 필요한 톡만", package_name: "com.tokpick.alert", summary: "메신저 알림에서 필요한 키워드와 발신자만 골라 알려주는 알림 필터", category: "ProductivityApplication", audience: "많은 메신저 알림 속에서 중요한 메시지를 놓치고 싶지 않은 사용자", highlights: [ "키워드 알림 규칙", "중복과 쿨다운 제어", "잡힌 알림 보관함" ] },
    { slug: "stab", name: "해적룰렛 STAB!", package_name: "com.stab.pirate", summary: "친구 얼굴 매핑과 룰렛을 함께 즐기는 오프라인 파티 벌칙 게임", category: "GameApplication", audience: "MT, 여행과 모임에서 바로 시작할 게임이 필요한 사용자", highlights: [ "해적 찌르기 게임", "커스텀 룰렛", "친구 얼굴 매핑" ] },
    { slug: "healthstack", name: "헬스스택 - 보충제 루틴 기록", package_name: "com.cleanstack.cleanstack", summary: "운동 보충제 조합과 섭취 루틴을 기록하고 참고하는 피트니스 앱", category: "HealthApplication", audience: "보충제 목록과 섭취 루틴을 정리하고 싶은 운동 사용자", highlights: [ "나만의 스택 기록", "제품과 루틴 검색", "루틴 공유" ], caution: "의료 상담이나 복용 처방을 대신하지 않습니다." }
  ].freeze

  HOLD_APPS = [
    { name: "Secret Signal Party", package_name: "com.bodeum.party.secretsignal", status: "내부 테스트" },
    { name: "Tap Arena 4", package_name: "com.bodeum.party.taparena4", status: "내부 테스트" },
    { name: "도담케어", package_name: "com.dodamcare.app", status: "앱 거부됨" },
    { name: "미세베어", package_name: "kr.co.jejuzone.misebear", status: "Google에서 삭제" },
    { name: "바탕 이슈", package_name: "com.issueon.app", status: "앱 거부됨" },
    { name: "보듬 — 복지 혜택 관리", package_name: "me.bodeum.app", status: "앱 거부됨" },
    { name: "비트코인토크", package_name: "kr.co.bitcointalk", status: "Google에서 삭제" },
    { name: "비트코인토크", package_name: "kr.co.bittalk", status: "Google에서 삭제" },
    { name: "점메추 플러스", package_name: "com.koreanmatrix.eatplus", status: "앱 거부됨" },
    { name: "카드프루프", package_name: "com.misebear.cardproof", status: "내부 테스트 검토 중" }
  ].freeze

  def self.active
    ACTIVE_APPS
  end

  def self.held
    HOLD_APPS
  end

  def self.find(slug)
    ACTIVE_APPS.find { |app| app[:slug] == slug }
  end

  def self.play_url(app, campaign: nil)
    base = "https://play.google.com/store/apps/details?id=#{app[:package_name]}"
    return base unless campaign

    referrer = URI.encode_www_form(
      utm_source: "bodeum_app_directory",
      utm_medium: "organic",
      utm_campaign: campaign
    )
    "#{base}&referrer=#{CGI.escape(referrer)}"
  end
end
