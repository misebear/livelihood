# frozen_string_literal: true

# Search landing pages for public welfare queries.
class SeoGuide
  UPDATED_ON = Date.new(2026, 6, 13)

  THRESHOLD_COLUMNS = %w[1인가구 2인가구 3인가구 4인가구 5인가구 6인가구].freeze

  THRESHOLD_ROWS = {
    livelihood: {
      label: "생계급여",
      ratio: "기준 중위소득 32%",
      values: %w[820,556 1,343,773 1,714,892 2,078,316 2,418,150 2,737,905]
    },
    medical: {
      label: "의료급여",
      ratio: "기준 중위소득 40%",
      values: %w[1,025,695 1,679,717 2,143,614 2,597,895 3,022,688 3,422,381]
    },
    housing: {
      label: "주거급여",
      ratio: "기준 중위소득 48%",
      values: %w[1,230,834 2,015,660 2,572,337 3,117,474 3,627,225 4,106,857]
    },
    education: {
      label: "교육급여·차상위 확인",
      ratio: "기준 중위소득 50%",
      values: %w[1,282,119 2,099,646 2,679,518 3,247,369 3,778,360 4,277,976]
    }
  }.freeze

  SOURCES = {
    thresholds: {
      label: "보건복지부 수급자 선정기준",
      url: "https://www.mohw.go.kr/menu.es?mid=a10708010300"
    },
    middle_income: {
      label: "보건복지부 2026년 기준 중위소득 보도자료",
      url: "https://www.mohw.go.kr/board.es?act=view&bid=0027&list_no=1487098&mid=a10503000000"
    },
    payment_law: {
      label: "국가법령정보센터 국민기초생활 보장법 시행령 제6조",
      url: "https://www.law.go.kr/법령/국민기초생활보장법시행령/제6조"
    },
    housing: {
      label: "마이홈 주거급여 안내",
      url: "https://www.myhome.go.kr/hws/portal/cont/selectHousingBenefitView.do"
    },
    medical: {
      label: "보건복지부 의료급여 안내",
      url: "https://www.mohw.go.kr/menu.es?mid=a10708030100"
    },
    near_poverty: {
      label: "복지로 차상위계층 확인 온라인 신청 안내",
      url: "https://www.bokjiro.go.kr/ssis-tbu/cms/pc/customer/notice/1304241_1141.html"
    },
    asset_building: {
      label: "보건복지부 자산형성지원사업",
      url: "https://www.mohw.go.kr/menu.es?mid=a10708020400"
    }
  }.freeze

  GUIDE_DEFINITIONS = [
    {
      slug: "basic-living-security-benefits",
      title: "2026 기초생활수급자 혜택 한눈에 보기",
      short_title: "기초생활수급자 혜택",
      meta_description: "2026년 생계급여, 의료급여, 주거급여, 교육급여 선정기준과 신청 전 확인할 항목을 정리했습니다.",
      keyword: "기초생활수급자 혜택",
      benefit_category: "기초급여",
      benefit_query: "기초생활",
      threshold_keys: %i[livelihood medical housing education],
      source_keys: %i[thresholds middle_income],
      quick_answers: [
        [ "핵심 기준", "급여별 선정기준 이하의 소득인정액" ],
        [ "2026 생계급여", "기준 중위소득 32% 이하" ],
        [ "신청 창구", "주소지 행정복지센터 또는 복지로" ]
      ],
      sections: [
        {
          heading: "가장 먼저 볼 기준",
          paragraphs: [
            "기초생활보장 급여는 한 가지 기준으로 끝나지 않습니다. 생계급여, 의료급여, 주거급여, 교육급여마다 기준 중위소득 비율이 다릅니다.",
            "실제 판정은 소득과 재산을 합산한 소득인정액, 가구원 수, 주거 형태, 부양의무자 기준 적용 여부를 함께 봅니다."
          ],
          bullets: [
            "생계급여는 생활비 성격의 현금 급여입니다.",
            "의료급여는 병원 이용 시 본인부담을 낮추는 제도입니다.",
            "주거급여는 임차료 또는 자가 주택 수선 비용을 지원합니다.",
            "교육급여는 학생이 있는 가구의 교육비 부담을 낮춥니다."
          ]
        },
        {
          heading: "신청 전에 준비하면 좋은 것",
          paragraphs: [
            "복지 신청은 서류보다 상황 설명이 먼저입니다. 가구원, 소득, 재산, 월세, 부채, 의료비처럼 생활에 직접 영향을 주는 항목을 미리 정리하면 상담이 빨라집니다."
          ],
          bullets: [
            "가구원 수와 실제 함께 사는 사람",
            "최근 소득과 근로 형태",
            "전월세 계약서 또는 주거 형태",
            "금융재산, 자동차, 부채, 의료비 지출"
          ]
        }
      ],
      faqs: [
        [ "기초생활수급자 혜택은 한 번에 모두 받을 수 있나요?", "소득인정액과 급여별 기준에 따라 받을 수 있는 급여가 달라집니다. 통합 신청을 하더라도 생계, 의료, 주거, 교육급여 판정은 각각 확인됩니다." ],
        [ "작년에 탈락했어도 다시 신청해도 되나요?", "가능합니다. 기준 중위소득과 가구 상황은 매년 또는 생활 변화에 따라 달라질 수 있으므로, 소득이나 재산이 바뀌었다면 다시 상담해 볼 만합니다." ],
        [ "보듬에서는 무엇을 확인할 수 있나요?", "입금일, 현금흐름, 수급 안전선, 관련 복지 혜택을 한 화면에서 확인할 수 있습니다." ]
      ]
    },
    {
      slug: "livelihood-benefit-payment-date",
      title: "2026 생계급여 입금일과 조기 지급 기준",
      short_title: "생계급여 입금일",
      meta_description: "생계급여 지급일은 언제인지, 20일이 주말·공휴일일 때 어떻게 조정되는지 정리했습니다.",
      keyword: "생계급여 입금일",
      benefit_category: "기초급여",
      benefit_query: "생계급여",
      threshold_keys: %i[livelihood],
      source_keys: %i[payment_law thresholds],
      quick_answers: [
        [ "정기 지급일", "매월 20일" ],
        [ "20일이 휴일이면", "그 전날 지급 원칙" ],
        [ "관리 포인트", "다음 입금일까지 쓸 생활비 나누기" ]
      ],
      sections: [
        {
          heading: "입금일 기준",
          paragraphs: [
            "생계급여는 원칙적으로 매월 20일에 수급자 명의 계좌로 지급됩니다. 20일이 토요일이거나 공휴일이면 그 전날로 조정됩니다.",
            "명절이나 시스템 점검처럼 별도 사정이 있으면 지자체 또는 보건복지부 안내가 우선이므로, 문자와 주민센터 공지를 함께 확인하는 것이 안전합니다."
          ],
          bullets: [
            "입금 시간은 은행과 지자체 처리 상황에 따라 달라질 수 있습니다.",
            "신규 책정자는 첫 지급 시점이 정기 지급과 다를 수 있습니다.",
            "보듬 홈에서는 다음 입금일까지 남은 날짜를 바로 확인할 수 있습니다."
          ]
        },
        {
          heading: "생활비 계획 방법",
          paragraphs: [
            "조기 지급이 되면 돈을 일찍 받는 대신 다음 지급일까지 버텨야 하는 기간이 길어질 수 있습니다. 입금 직후 고정지출과 남은 일수를 나눠 보는 방식이 가장 단순합니다."
          ],
          bullets: [
            "월세, 공과금, 통신비처럼 날짜가 정해진 지출 먼저 분리",
            "남은 현금을 다음 입금일까지의 일수로 나누기",
            "급한 병원비나 교통비는 별도 비상금으로 남겨두기"
          ]
        }
      ],
      faqs: [
        [ "생계급여는 매월 며칠에 들어오나요?", "정기 지급은 매월 20일 기준입니다. 20일이 토요일이나 공휴일이면 그 전날 지급되는 것이 원칙입니다." ],
        [ "입금 시간이 매달 같나요?", "정확한 입금 시간은 지역과 금융기관 처리 상황에 따라 달라질 수 있습니다." ],
        [ "주거급여도 같은 날 들어오나요?", "많은 경우 20일 전후로 함께 확인하지만, 급여 종류와 지역 처리에 따라 달라질 수 있어 개별 안내를 확인해야 합니다." ]
      ]
    },
    {
      slug: "housing-benefit-eligibility",
      title: "2026 주거급여 조건과 신청 전 체크리스트",
      short_title: "주거급여 조건",
      meta_description: "2026년 주거급여 선정기준, 임차가구와 자가가구가 확인할 항목, 신청 전 체크리스트를 정리했습니다.",
      keyword: "주거급여 조건",
      benefit_category: "주거",
      benefit_query: "주거급여",
      threshold_keys: %i[housing],
      source_keys: %i[thresholds housing],
      quick_answers: [
        [ "2026 기준", "기준 중위소득 48% 이하" ],
        [ "임차가구", "월세 등 실제 임차료 확인" ],
        [ "자가가구", "주택 노후도와 수선 필요 확인" ]
      ],
      sections: [
        {
          heading: "지원 대상의 큰 틀",
          paragraphs: [
            "주거급여는 소득인정액이 주거급여 선정기준 이하인 가구의 주거비 부담을 줄이는 제도입니다. 임차가구와 자가가구의 지원 방식이 다릅니다.",
            "임차가구는 실제 임차료와 기준임대료를 함께 보고, 자가가구는 주택 상태에 따른 수선유지급여를 확인합니다."
          ],
          bullets: [
            "전월세 계약서와 실제 거주 여부",
            "보증금, 월세, 관리비 등 주거비 구조",
            "가구원 수와 지역",
            "자가 주택이면 노후도와 수선 필요"
          ]
        },
        {
          heading: "탈락을 줄이는 확인 순서",
          paragraphs: [
            "주거급여는 월세만 낮다고 바로 결정되지 않습니다. 소득, 재산, 자동차, 부채를 반영한 소득인정액이 기준 안에 들어오는지부터 확인해야 합니다."
          ],
          bullets: [
            "가구원 수에 맞는 2026년 기준 금액 확인",
            "복지로 또는 마이홈 자가진단으로 1차 확인",
            "주소지 행정복지센터에서 실제 서류와 함께 상담"
          ]
        }
      ],
      faqs: [
        [ "주거급여는 월세 사는 사람만 받을 수 있나요?", "아닙니다. 임차가구는 임차료 지원을, 자가가구는 주택 상태에 따른 수선유지급여를 확인할 수 있습니다." ],
        [ "부양의무자 소득도 보나요?", "주거급여는 신청가구의 소득과 재산을 중심으로 봅니다. 다만 실제 판정은 주민센터 상담으로 확인해야 합니다." ],
        [ "주거급여와 생계급여를 같이 받을 수 있나요?", "급여별 기준을 각각 충족하면 함께 받을 수 있습니다. 선정기준 비율이 다르므로 따로 확인해야 합니다." ]
      ]
    },
    {
      slug: "medical-benefit-recipient",
      title: "의료급여 1종·2종 대상자와 병원 이용 순서",
      short_title: "의료급여 대상자",
      meta_description: "의료급여 1종·2종 대상자 차이, 병원 이용 절차, 2026년 의료급여 선정기준을 정리했습니다.",
      keyword: "의료급여 대상자",
      benefit_category: "건강·의료",
      benefit_query: "의료급여",
      threshold_keys: %i[medical],
      source_keys: %i[thresholds medical],
      quick_answers: [
        [ "2026 기준", "기준 중위소득 40% 이하" ],
        [ "구분", "1종·2종 수급권자" ],
        [ "진료 순서", "1차 의료급여기관부터 이용" ]
      ],
      sections: [
        {
          heading: "1종과 2종의 차이",
          paragraphs: [
            "의료급여는 생활이 어려운 저소득 국민의 의료비 부담을 줄이는 공공부조입니다. 대상자는 1종과 2종으로 나뉘며 본인부담 수준과 대상 범위가 다릅니다.",
            "1종은 근로무능력 가구, 중증질환 등록자, 시설수급자 등으로 구분되고, 2종은 1종 대상이 아닌 기초생활보장대상자가 주로 해당합니다."
          ],
          bullets: [
            "현재 자격이 1종인지 2종인지 먼저 확인",
            "외래·입원 본인부담 기준 확인",
            "상급종합병원 이용 전 의뢰서 필요 여부 확인"
          ]
        },
        {
          heading: "병원 이용 전 체크",
          paragraphs: [
            "의료급여는 진료 절차가 중요합니다. 예외가 없는 경우 1차 의료급여기관을 먼저 이용하고, 필요하면 의료급여의뢰서를 받아 2차·3차 기관으로 이동합니다."
          ],
          bullets: [
            "응급 상황인지 일반 진료인지 구분",
            "의뢰서가 필요한 진료인지 병원에 사전 확인",
            "약국 본인부담과 경증질환 예외 확인"
          ]
        }
      ],
      faqs: [
        [ "의료급여 대상자는 모두 1종인가요?", "아닙니다. 대상 특성과 가구 상황에 따라 1종 또는 2종으로 나뉩니다." ],
        [ "상급종합병원에 바로 가도 되나요?", "응급 등 예외를 제외하면 1차 의료급여기관부터 이용하고 의뢰 절차를 따르는 것이 원칙입니다." ],
        [ "의료급여 기준은 생계급여와 같나요?", "다릅니다. 2026년 의료급여 선정기준은 기준 중위소득 40%이고, 생계급여는 32%입니다." ]
      ]
    },
    {
      slug: "near-poverty-class-benefits",
      title: "차상위계층 혜택과 확인서 신청 기준",
      short_title: "차상위계층 혜택",
      meta_description: "차상위계층 확인 기준, 신청 경로, 감면·의료·자산형성 혜택을 찾는 순서를 정리했습니다.",
      keyword: "차상위계층 혜택",
      benefit_category: "감면·할인",
      benefit_query: "차상위",
      threshold_keys: %i[education],
      source_keys: %i[near_poverty asset_building thresholds],
      quick_answers: [
        [ "확인 기준", "소득인정액 기준 중위소득 50% 이하" ],
        [ "온라인 경로", "복지로 서비스 신청" ],
        [ "찾을 혜택", "감면, 의료비, 자산형성, 교육비" ]
      ],
      sections: [
        {
          heading: "차상위 확인이 필요한 이유",
          paragraphs: [
            "차상위계층은 기초생활보장 수급자는 아니지만 소득인정액이 낮아 별도 지원이 필요한 가구를 말합니다. 확인서가 있으면 여러 감면과 지원사업을 찾기 쉬워집니다.",
            "복지로 안내에 따르면 차상위계층 확인은 본인가구의 소득인정액이 기준 중위소득 50% 이하인지 여부를 중심으로 봅니다."
          ],
          bullets: [
            "통신요금, 전기요금 등 생활요금 감면",
            "의료비 본인부담 경감 관련 제도",
            "희망저축계좌, 청년내일저축계좌 등 자산형성 지원",
            "교육·문화·지역별 추가 지원"
          ]
        },
        {
          heading: "신청 전 확인 순서",
          paragraphs: [
            "차상위계층은 이름이 비슷한 제도가 많습니다. 차상위 확인, 차상위 자활, 차상위 장애수당, 본인부담 경감은 대상과 경로가 다를 수 있습니다."
          ],
          bullets: [
            "내가 이미 다른 보호제도 대상인지 확인",
            "가구 소득과 재산을 최신 기준으로 정리",
            "복지로 온라인 신청 가능 여부 확인",
            "불가하면 주소지 행정복지센터 방문 상담"
          ]
        }
      ],
      faqs: [
        [ "차상위계층은 기준 중위소득 몇 퍼센트인가요?", "차상위계층 확인은 본인가구 소득인정액이 기준 중위소득 50% 이하인지 여부를 중심으로 봅니다." ],
        [ "기초생활수급자도 차상위 확인서를 신청하나요?", "일반적으로 기초생활보장 급여 수급자는 별도 보호제도 대상이라 차상위 확인 대상에서 제외될 수 있습니다." ],
        [ "차상위 혜택은 어디서 찾나요?", "보듬 혜택 검색에서 차상위 관련 혜택을 찾고, 실제 신청은 복지로 또는 관할 행정복지센터에서 확인하는 것이 안전합니다." ]
      ]
    },
    {
      slug: "support-obligor-standard",
      title: "부양의무자 기준이 적용되는 경우 정리",
      short_title: "부양의무자 기준",
      meta_description: "생계·의료·주거급여 신청 전 부양의무자 기준을 어떻게 확인해야 하는지 정리했습니다.",
      keyword: "부양의무자 기준",
      benefit_category: "기초급여",
      benefit_query: "부양의무자",
      threshold_keys: %i[livelihood medical housing],
      source_keys: %i[thresholds near_poverty],
      quick_answers: [
        [ "먼저 확인", "신청 급여 종류" ],
        [ "주거급여", "신청가구 중심 확인" ],
        [ "주의", "의료급여는 별도 확인 필요" ]
      ],
      sections: [
        {
          heading: "급여마다 다르게 봅니다",
          paragraphs: [
            "부양의무자 기준은 신청하는 급여 종류에 따라 적용 여부와 세부 판단이 달라질 수 있습니다. 그래서 '부양의무자 때문에 무조건 안 된다'고 단정하지 않는 것이 중요합니다.",
            "최근 제도는 신청가구의 실제 생활 여건을 더 많이 보도록 바뀌어 왔지만, 의료급여 등 일부 영역은 별도 확인이 필요합니다."
          ],
          bullets: [
            "생계급여, 의료급여, 주거급여 중 어떤 급여를 신청하는지 구분",
            "부모·자녀와 실제 생계가 분리되어 있는지 정리",
            "소득·재산뿐 아니라 부양을 받을 수 없는 사유도 함께 설명",
            "주민센터 상담 전 가족관계와 거주 상황을 메모"
          ]
        },
        {
          heading: "상담 때 말해야 할 내용",
          paragraphs: [
            "가족관계만으로 판단되지 않는 사정이 있다면 상담 때 구체적으로 설명해야 합니다. 연락 단절, 실질적 부양 불가, 의료비·채무 부담처럼 생활을 어렵게 만드는 사유가 중요합니다."
          ],
          bullets: [
            "실제 도움을 받고 있는지 여부",
            "가족과 연락 또는 왕래가 가능한지 여부",
            "부양의무자도 생계가 어려운지 여부",
            "긴급지원이나 다른 제도가 먼저 필요한 상황인지 여부"
          ]
        }
      ],
      faqs: [
        [ "부양의무자가 있으면 무조건 탈락인가요?", "아닙니다. 급여 종류와 실제 부양 가능 여부에 따라 달라질 수 있습니다." ],
        [ "주거급여도 부양의무자 기준을 보나요?", "주거급여는 신청가구의 소득과 재산을 중심으로 확인합니다. 실제 판정은 관할 기관 상담으로 확인해야 합니다." ],
        [ "가족과 연락이 끊긴 경우 어떻게 하나요?", "상담 때 연락 단절이나 실질적 부양 불가 사유를 구체적으로 설명하고 필요한 증빙을 안내받는 것이 좋습니다." ]
      ]
    },
    {
      slug: "monthly-benefit-budgeting-routine",
      title: "생계급여 입금 후 30일 생활비 나누는 방법",
      short_title: "입금 후 생활비 루틴",
      meta_description: "생계급여 입금 직후 고정지출, 식비, 교통비, 비상금을 다음 지급일까지 나누는 현실적인 순서를 정리했습니다.",
      keyword: "생계급여 생활비 관리",
      benefit_category: "기초급여",
      benefit_query: "생계급여",
      threshold_keys: %i[livelihood],
      source_keys: %i[payment_law thresholds],
      quick_answers: [
        [ "첫 단계", "월세·공과금·통신비 먼저 분리" ],
        [ "둘째 단계", "남은 돈을 다음 입금일까지 일 단위로 나누기" ],
        [ "주의", "조기 지급월은 버텨야 할 기간이 길어질 수 있음" ]
      ],
      sections: [
        {
          heading: "입금 당일에 먼저 나눌 돈",
          paragraphs: [
            "생계급여는 매월 생활을 이어가기 위한 현금 흐름의 기준점입니다. 입금이 확인되면 전체 금액을 한 번에 쓰기보다 고정지출, 생활비, 예비비를 분리해 두는 편이 안전합니다.",
            "보듬에서는 다음 입금일까지 남은 날짜를 보여주므로, 실제로 남은 기간에 맞춰 하루 예산을 다시 계산하는 데 활용할 수 있습니다."
          ],
          bullets: [
            "월세, 관리비, 전기·가스·수도요금처럼 날짜가 정해진 지출을 먼저 빼둡니다.",
            "휴대폰 요금, 보험료, 자동이체처럼 연체가 생활에 영향을 주는 지출을 확인합니다.",
            "병원비, 약값, 교통비처럼 갑자기 생길 수 있는 비용을 작은 비상금으로 남깁니다.",
            "남은 금액을 다음 지급일까지의 일수로 나눠 하루 기준액을 만듭니다."
          ]
        },
        {
          heading: "조기 지급월에 놓치기 쉬운 점",
          paragraphs: [
            "20일이 주말이나 공휴일이면 생계급여가 전날 들어올 수 있습니다. 돈을 일찍 받는 것은 좋아 보이지만, 다음 달 정기 지급일까지 실제로 버텨야 하는 날짜가 더 길어질 수 있습니다.",
            "이때는 '이번 달 말까지 쓸 돈'이 아니라 '다음 입금 전날까지 쓸 돈'으로 계산해야 생활비가 중간에 비는 일을 줄일 수 있습니다."
          ],
          bullets: [
            "명절 전 조기 지급이 있으면 다음 지급일까지 남은 날짜를 다시 셉니다.",
            "식비는 주 단위 봉투나 계좌로 나누면 초반 과소비를 줄이기 쉽습니다.",
            "반드시 내야 하는 고정지출은 생활비 계좌와 분리해 두는 것이 안전합니다."
          ]
        },
        {
          heading: "보듬에 기록하면 좋은 항목",
          paragraphs: [
            "금액을 정확히 맞추는 것보다 매달 반복되는 흐름을 파악하는 것이 중요합니다. 지출이 컸던 날짜, 부족했던 기간, 다음 달에 미리 빼둘 돈을 기록하면 같은 실수를 줄일 수 있습니다."
          ],
          bullets: [
            "자동이체 날짜와 금액",
            "월말에 부족했던 항목",
            "다음 달 입금 전까지 꼭 남겨야 하는 최소 금액",
            "행정복지센터 상담이나 신고가 필요한 생활 변화"
          ]
        }
      ],
      faqs: [
        [ "입금되자마자 어떤 돈부터 빼야 하나요?", "월세, 공과금, 통신비처럼 연체되면 바로 생활에 영향을 주는 고정지출부터 분리하는 것이 좋습니다." ],
        [ "조기 지급되면 생활비가 더 여유로운 건가요?", "항상 그렇지는 않습니다. 돈을 일찍 받으면 다음 지급일까지 버텨야 하는 기간도 길어질 수 있어 남은 날짜 기준으로 다시 나눠야 합니다." ],
        [ "하루 예산은 꼭 지켜야 하나요?", "엄격한 규칙이라기보다 기준선입니다. 병원비처럼 꼭 필요한 지출이 생기면 남은 기간의 하루 예산을 다시 계산하면 됩니다." ]
      ]
    },
    {
      slug: "income-recognition-checklist",
      title: "소득인정액 계산 전 확인할 소득·재산 항목",
      short_title: "소득인정액 체크리스트",
      meta_description: "기초생활보장 신청 전 근로소득, 금융재산, 자동차, 부채, 주거 형태처럼 소득인정액에 영향을 주는 항목을 정리했습니다.",
      keyword: "소득인정액 계산",
      benefit_category: "기초급여",
      benefit_query: "소득인정액",
      threshold_keys: %i[livelihood medical housing education],
      source_keys: %i[thresholds middle_income],
      quick_answers: [
        [ "판정 기준", "가구 소득과 재산을 환산한 소득인정액" ],
        [ "준비 항목", "소득·재산·자동차·부채·주거 정보" ],
        [ "확정 판단", "복지로 모의계산 후 행정복지센터 확인" ]
      ],
      sections: [
        {
          heading: "소득으로 확인할 것",
          paragraphs: [
            "소득인정액은 단순 월급만 보는 개념이 아닙니다. 근로소득, 사업소득, 공적 이전소득, 기타 반복 수입처럼 가구에 들어오는 돈의 성격을 함께 정리해야 합니다.",
            "불규칙하게 일하거나 최근에 소득이 줄었다면 상담 때 최근 변화를 설명할 수 있도록 날짜와 금액을 메모해 두는 것이 좋습니다."
          ],
          bullets: [
            "최근 3개월 근로소득 또는 일용직 수입",
            "사업소득, 배달·플랫폼 수입, 부업 수입",
            "연금, 수당, 다른 공적 지원금",
            "소득이 끊긴 날짜나 근무 시간이 줄어든 사유"
          ]
        },
        {
          heading: "재산으로 확인할 것",
          paragraphs: [
            "재산은 금융재산만이 아니라 보증금, 자동차, 부동산, 보험 해지환급금, 부채까지 함께 봅니다. 같은 금액이라도 주거 형태와 지역에 따라 실제 판정이 달라질 수 있습니다.",
            "부채는 생활 상황을 설명하는 중요한 자료가 될 수 있으므로, 대출 잔액과 상환액을 따로 적어두면 상담이 빨라집니다."
          ],
          bullets: [
            "전월세 보증금과 월세 계약서",
            "예금, 적금, 보험, 주식 등 금융재산",
            "자동차 보유 여부와 사용 목적",
            "대출 잔액, 월 상환액, 연체 여부"
          ]
        },
        {
          heading: "가구원과 실제 생활",
          paragraphs: [
            "복지 판정은 주민등록상 구성만으로 끝나지 않을 수 있습니다. 실제 함께 사는 사람, 생계를 같이하는 사람, 따로 살아도 부양 관계가 있는 사람을 구분해서 설명해야 합니다."
          ],
          bullets: [
            "실제 같이 사는 가족과 따로 사는 가족",
            "주소 이전, 이혼, 별거, 사망, 군복무 등 최근 변화",
            "가족에게 실질적인 도움을 받고 있는지 여부",
            "병원비나 돌봄 부담처럼 생활비를 줄이는 사유"
          ]
        }
      ],
      faqs: [
        [ "소득인정액은 월급과 같은 뜻인가요?", "아닙니다. 소득과 재산을 제도 기준에 따라 함께 반영한 금액입니다." ],
        [ "자동차가 있으면 무조건 탈락인가요?", "자동차 종류, 사용 목적, 가구 상황에 따라 판단이 달라질 수 있습니다. 상담 때 차량 정보와 사용 이유를 정확히 설명해야 합니다." ],
        [ "모의계산 결과와 실제 판정이 다를 수 있나요?", "가능합니다. 모의계산은 참고용이고 실제 결정은 제출 서류와 조사 결과를 바탕으로 합니다." ]
      ]
    },
    {
      slug: "welfare-application-documents-checklist",
      title: "복지 신청 전 준비할 서류와 상담 메모",
      short_title: "복지 신청 서류",
      meta_description: "행정복지센터 방문 전 준비하면 좋은 신분증, 통장, 임대차계약서, 소득·재산 자료와 상담 메모 작성법을 정리했습니다.",
      keyword: "복지 신청 서류",
      benefit_category: nil,
      benefit_query: "복지 신청",
      threshold_keys: %i[],
      source_keys: %i[thresholds near_poverty],
      quick_answers: [
        [ "기본 준비", "신분증, 통장, 주거·소득 자료" ],
        [ "상담 메모", "소득 감소, 병원비, 돌봄, 채무 사유" ],
        [ "주의", "제도별 추가 서류는 현장 안내 우선" ]
      ],
      sections: [
        {
          heading: "방문 전 기본 준비물",
          paragraphs: [
            "복지 신청은 제도마다 요구 서류가 다르지만, 대부분 본인 확인과 가구 상황 확인이 먼저입니다. 신분증, 계좌, 주거 형태, 소득 변화를 확인할 수 있는 자료를 준비하면 첫 상담에서 빠지는 내용을 줄일 수 있습니다.",
            "온라인 신청이 가능한 제도라도, 상황이 복잡하거나 긴급한 경우에는 주소지 행정복지센터 상담을 함께 진행하는 편이 안전합니다."
          ],
          bullets: [
            "신분증과 본인 명의 통장 정보",
            "전월세 계약서, 고시원 영수증, 무상거주 확인 등 주거 자료",
            "급여명세서, 일용직 소득 메모, 폐업·실직 관련 자료",
            "병원비, 약값, 돌봄비, 채무 상환처럼 생활 곤란을 보여주는 자료"
          ]
        },
        {
          heading: "상담 전에 적어둘 질문",
          paragraphs: [
            "상담 창구에서는 긴장하거나 시간이 부족해 중요한 말을 놓치기 쉽습니다. 어떤 급여를 받을 수 있는지보다 '지금 생활에서 무엇이 가장 어렵고 언제부터 바뀌었는지'를 먼저 적어두면 도움이 됩니다."
          ],
          bullets: [
            "최근 소득이 줄거나 끊긴 날짜",
            "가족과 실제로 도움을 주고받는지 여부",
            "다음 달까지 버티기 어려운 고정지출",
            "신청 후 결과 통보까지 걸리는 예상 기간",
            "긴급복지나 감면 제도를 함께 확인할 수 있는지"
          ]
        },
        {
          heading: "신청 후 확인할 일",
          paragraphs: [
            "서류를 냈다고 끝나는 것이 아니라 추가 자료 요청, 가구 방문, 결과 통보, 이의신청 기간을 확인해야 합니다. 연락처가 바뀌거나 주소가 바뀌면 결과 안내를 놓칠 수 있습니다."
          ],
          bullets: [
            "접수일과 담당 창구 이름",
            "추가로 제출해야 할 서류와 제출 기한",
            "결과 통보 방식과 예상 날짜",
            "탈락 시 이의신청 또는 다른 제도 안내"
          ]
        }
      ],
      faqs: [
        [ "서류가 부족하면 신청을 못 하나요?", "상황에 따라 먼저 상담하고 추가 제출을 안내받을 수 있습니다. 다만 기본 신분 확인과 연락처는 준비하는 것이 좋습니다." ],
        [ "온라인 신청과 방문 신청 중 무엇이 좋나요?", "단순한 신청은 온라인도 가능하지만, 소득 감소나 가족관계가 복잡하면 방문 상담을 함께 하는 편이 안전합니다." ],
        [ "상담 때 개인정보를 많이 말해야 하나요?", "자격 확인에 필요한 범위의 정보가 필요할 수 있습니다. 불필요한 민감 정보는 공개하지 말고 담당자에게 필요한 이유를 확인하세요." ]
      ]
    },
    {
      slug: "recipient-risk-signals",
      title: "수급 자격 변동 전에 확인할 위험 신호",
      short_title: "수급 안전선 위험 신호",
      meta_description: "근로소득 증가, 가구원 변화, 자동차·금융재산 변동, 신고 누락처럼 수급 자격에 영향을 줄 수 있는 신호를 정리했습니다.",
      keyword: "수급 탈락 방지",
      benefit_category: "기초급여",
      benefit_query: "수급",
      threshold_keys: %i[livelihood medical housing education],
      source_keys: %i[thresholds middle_income],
      quick_answers: [
        [ "가장 흔한 변화", "소득·재산·가구원 변동" ],
        [ "안전 행동", "변경 즉시 담당 기관에 확인" ],
        [ "보듬 활용", "수급 안전선과 지출 변화를 함께 기록" ]
      ],
      sections: [
        {
          heading: "소득이 바뀌었을 때",
          paragraphs: [
            "일을 시작하거나 근무 시간이 늘어나면 생활은 나아질 수 있지만, 수급 자격과 급여액에는 영향을 줄 수 있습니다. 반대로 소득이 줄었는데 신고나 상담을 늦추면 필요한 지원을 놓칠 수 있습니다.",
            "소득 변화는 금액뿐 아니라 언제부터, 어떤 형태로, 얼마나 지속될지 함께 설명해야 합니다."
          ],
          bullets: [
            "새 근무 시작, 근무 시간 증가, 일용직 수입 증가",
            "퇴사, 휴직, 근무 시간 감소, 임금 체불",
            "사업소득이나 플랫폼 수입의 월별 변동",
            "일시적 수입인지 반복 수입인지 구분"
          ]
        },
        {
          heading: "재산과 가구원 변화",
          paragraphs: [
            "통장 잔액, 보증금, 자동차, 보험, 부채 변화는 소득인정액에 영향을 줄 수 있습니다. 결혼, 이혼, 출생, 사망, 독립, 합가처럼 가구원 변화가 생기면 기준 금액 자체도 달라질 수 있습니다."
          ],
          bullets: [
            "보증금 증감 또는 이사",
            "자동차 구입, 처분, 공동명의 변경",
            "목돈 입금, 보험 해지, 적금 만기",
            "가구원 전입·전출과 실제 동거 여부 변화"
          ]
        },
        {
          heading: "신고 누락을 줄이는 습관",
          paragraphs: [
            "수급 자격은 숨기기보다 빨리 확인하는 것이 안전합니다. 변경이 생겼을 때 보듬에 메모해 두고 담당 기관에 문의하면, 나중에 기억에 의존해 설명하는 부담을 줄일 수 있습니다."
          ],
          bullets: [
            "변경 발생일과 금액을 바로 기록",
            "관련 서류 사진이나 파일 위치를 메모",
            "행정복지센터 상담일과 답변 요지를 기록",
            "확정되지 않은 정보는 공식 확인 전까지 단정하지 않기"
          ]
        }
      ],
      faqs: [
        [ "일을 시작하면 바로 수급이 끊기나요?", "무조건 그렇지는 않습니다. 소득 수준, 가구원 수, 급여 종류에 따라 달라지므로 변경 사실을 확인하고 상담해야 합니다." ],
        [ "통장에 목돈이 들어오면 문제가 되나요?", "일시적 입금의 성격과 금액, 재산 기준 반영 방식에 따라 달라질 수 있습니다. 출처와 사용 목적을 설명할 자료를 남겨두는 것이 좋습니다." ],
        [ "보듬의 안전선 계산만 믿어도 되나요?", "보듬은 참고용 생활 관리 도구입니다. 실제 자격과 급여액은 공식 기관의 조사와 결정이 우선입니다." ]
      ]
    },
    {
      slug: "official-welfare-source-check",
      title: "복지 정보가 맞는지 공식 출처로 확인하는 법",
      short_title: "공식 출처 확인법",
      meta_description: "블로그나 커뮤니티 복지 정보를 그대로 믿기 전에 보건복지부, 복지로, 법령정보, 지자체 공지를 확인하는 순서를 정리했습니다.",
      keyword: "복지 정보 확인",
      benefit_category: nil,
      benefit_query: "복지",
      threshold_keys: %i[],
      source_keys: %i[thresholds middle_income payment_law housing medical near_poverty asset_building],
      quick_answers: [
        [ "1차 확인", "보건복지부·복지로·법령정보" ],
        [ "지역 차이", "지자체 공고와 행정복지센터 확인" ],
        [ "주의", "오래된 글과 광고성 글은 재확인" ]
      ],
      sections: [
        {
          heading: "먼저 확인할 공식 출처",
          paragraphs: [
            "복지 정보는 연도와 지역에 따라 바뀔 수 있습니다. 검색 결과의 글이 친절하더라도, 실제 신청 전에는 공식 출처에서 기준 연도와 담당 기관을 확인해야 합니다.",
            "보듬은 공식 출처를 사용자가 이해하기 쉬운 순서로 풀어 설명하지만, 최종 자격 판단과 지급 결정은 담당 기관의 안내가 우선입니다."
          ],
          bullets: [
            "기준 중위소득과 선정기준은 보건복지부 자료 확인",
            "온라인 신청 가능 여부는 복지로 안내 확인",
            "법 조문과 지급 원칙은 국가법령정보센터 확인",
            "주거급여 세부 기준은 마이홈 또는 담당 기관 안내 확인"
          ]
        },
        {
          heading: "오래된 정보를 걸러내는 방법",
          paragraphs: [
            "복지 글은 검색에 오래 남아 있어 예전 기준이 최신처럼 보일 수 있습니다. 제목의 연도, 본문 업데이트 날짜, 금액 단위, 링크가 살아 있는지 확인하면 오류를 줄일 수 있습니다."
          ],
          bullets: [
            "본문의 기준 연도가 올해인지 확인",
            "금액표가 기준 중위소득 몇 퍼센트인지 확인",
            "공식 링크가 실제로 열리는지 확인",
            "댓글이나 광고 문구보다 담당 기관 안내를 우선"
          ]
        },
        {
          heading: "보듬에서 공식 출처를 쓰는 방식",
          paragraphs: [
            "보듬의 가이드는 사용자가 바로 판단할 수 있도록 핵심 요약, 기준 금액, 체크리스트, FAQ, 공식 확인처를 한 화면에 둡니다. 단순 복사보다 실제 생활에서 놓치기 쉬운 순서와 메모 항목을 함께 제공합니다."
          ],
          bullets: [
            "가이드마다 공식 확인처 링크 제공",
            "혜택 검색과 생활비 관리 화면으로 연결",
            "정정 요청은 문의 페이지에서 접수",
            "광고보다 본문과 도구 사용을 우선하는 배치 유지"
          ]
        }
      ],
      faqs: [
        [ "보듬 내용과 주민센터 안내가 다르면 무엇을 따라야 하나요?", "실제 자격과 지급 판단은 관할 기관 안내가 우선입니다. 보듬 내용은 참고용으로 사용하세요." ],
        [ "블로그 글의 복지 금액이 다르면 어떻게 하나요?", "해당 글의 기준 연도와 공식 출처 링크를 확인하고, 최신 보건복지부 또는 복지로 자료와 비교해야 합니다." ],
        [ "정보 오류를 발견하면 어디에 알려야 하나요?", "문의 페이지의 이메일로 URL, 문제 문장, 확인한 공식 출처를 함께 보내주면 우선 확인합니다." ]
      ]
    }
  ].freeze

  attr_reader :slug, :title, :short_title, :meta_description, :keyword, :benefit_category,
    :benefit_query, :threshold_keys, :source_keys, :quick_answers, :sections, :faqs

  def initialize(attributes)
    @slug = attributes.fetch(:slug)
    @title = attributes.fetch(:title)
    @short_title = attributes.fetch(:short_title)
    @meta_description = attributes.fetch(:meta_description)
    @keyword = attributes.fetch(:keyword)
    @benefit_category = attributes.fetch(:benefit_category)
    @benefit_query = attributes.fetch(:benefit_query)
    @threshold_keys = attributes.fetch(:threshold_keys)
    @source_keys = attributes.fetch(:source_keys)
    @quick_answers = attributes.fetch(:quick_answers)
    @sections = attributes.fetch(:sections)
    @faqs = attributes.fetch(:faqs)
  end

  def self.all
    @all ||= GUIDE_DEFINITIONS.map { |definition| new(definition) }
  end

  def self.featured
    all.first(4)
  end

  def self.find!(slug)
    all.find { |guide| guide.slug == slug } || raise(ActiveRecord::RecordNotFound)
  end

  def self.threshold_rows_for(keys)
    keys.filter_map { |key| THRESHOLD_ROWS[key] }
  end

  def self.related_to(guide)
    all.reject { |candidate| candidate.slug == guide.slug }
  end

  def to_param
    slug
  end

  def updated_on
    UPDATED_ON
  end

  def threshold_rows
    self.class.threshold_rows_for(threshold_keys)
  end

  def sources
    source_keys.filter_map { |key| SOURCES[key] }
  end

  def benefits_query_params
    {
      category: benefit_category,
      q: benefit_query
    }.compact
  end

  def article_json_ld(url:)
    {
      "@context": "https://schema.org",
      "@type": "Article",
      headline: title,
      description: meta_description,
      inLanguage: "ko-KR",
      datePublished: updated_on.iso8601,
      dateModified: updated_on.iso8601,
      mainEntityOfPage: url,
      author: organization_json_ld,
      publisher: organization_json_ld
    }
  end

  def faq_json_ld
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      mainEntity: faqs.map do |question, answer|
        {
          "@type": "Question",
          name: question,
          acceptedAnswer: {
            "@type": "Answer",
            text: answer
          }
        }
      end
    }
  end

  def breadcrumb_json_ld(root_url:, guides_url:, guide_url:)
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      itemListElement: [
        breadcrumb_item(1, "보듬", root_url),
        breadcrumb_item(2, "복지 가이드", guides_url),
        breadcrumb_item(3, short_title, guide_url)
      ]
    }
  end

  private

  def organization_json_ld
    {
      "@type": "Organization",
      name: "보듬",
      url: "https://bodeum.me"
    }
  end

  def breadcrumb_item(position, name, item)
    {
      "@type": "ListItem",
      position: position,
      name: name,
      item: item
    }
  end
end
