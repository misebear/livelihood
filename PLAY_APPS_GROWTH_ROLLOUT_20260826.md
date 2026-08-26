# JejuBucketList 전체 Play 앱 검색 유입 롤아웃

기준일: 2026-08-26 KST
Play Console 계정: `5047399025850753041`

## 판정

- Play Console 등록 앱: 46개
- 프로덕션 앱: 36개
- 임시·내부 테스트·거부·삭제: 10개
- 검색 유입 적용: 프로덕션 36개만 독립 URL, SoftwareApplication schema, sitemap, RSS, Play referrer 대상으로 포함
- 보류 앱: 지원 정보만 유지하고 설치 SEO 및 sitemap 독립 URL에서는 제외

## 공통 계약

- 즉시 공개 디렉터리: `https://misebear.github.io/jejubucketlist-app-support-site/`
- 즉시 공개 앱별 URL: `https://misebear.github.io/jejubucketlist-app-support-site/apps/{slug}/`
- 즉시 공개 피드: `https://misebear.github.io/jejubucketlist-app-support-site/apps/rss.xml`
- Rails 배포 준비 경로: `https://bodeum.me/app-support`, `https://bodeum.me/apps/{slug}`
- 앱별 페이지: 고유 title/description/canonical/H1, 기능 3개, 대상 사용자, 민감 카테고리 안전 고지
- schema: `SoftwareApplication` + `BreadcrumbList`
- Play CTA: `utm_source=bodeum_app_directory`, `utm_medium=organic`, 앱별 campaign
- sitemap: 프로덕션 앱 36개 URL만 포함
- robots: sitemap과 앱 RSS를 모두 선언

## 프로덕션 앱 36개

| 앱 | Package | Slug |
| --- | --- | --- |
| 1분 사주 | `app.railway.up.app_1min_saju_production.twa` | `one-minute-saju` |
| BodyMagic | `com.bodymagic.app` | `bodymagic` |
| Daily Scene - AI Story Chat | `com.bodeum.haruscene` | `haruscene` |
| DayMint | `com.daymint.routine` | `daymint` |
| DialFocus | `com.dialfocus.app` | `dialfocus` |
| LumaLeaf 식물 조도계 | `com.lumaleaf.app` | `lumaleaf` |
| Mulmi: Car Sickness Aid | `com.mulmi.ridecue` | `mulmi` |
| Neflepedia | `com.kmoltbook.neflepedia` | `neflepedia` |
| NowNote | `com.bodeum.nownote` | `nownote` |
| PitchFlow | `com.pitchflow.vocal` | `pitchflow` |
| PoopBuddy | `com.poopbuddy.app` | `poopbuddy` |
| Quiet Hour | `com.bodeum.quiethour` | `quiet-hour` |
| Rush Pass Party | `com.bodeum.party.rushpass` | `rush-pass` |
| Selah One | `app.selahone.mobile` | `selah-one` |
| SimpleRec | `com.hyunj.simplerecstudio` | `simplerec` |
| Smart Running | `com.smartrunning.app` | `smart-running` |
| TypeNovel | `com.typenovel.app` | `typenovel` |
| 기름주의보 | `me.bodeum.oilwidget` | `oil-widget` |
| 난독캐치 | `com.dyscatch.app` | `dyscatch` |
| 맑냥 | `com.aether.airflow` | `malgnyang` |
| 머니수첩 | `com.bodeum.moneynotebook` | `money-notebook` |
| 식객로드 | `com.jejubucketlist.sikgaekroad` | `sikgaek-road` |
| 아이돌 마스터 | `com.mybias.my_bias_arcade` | `idol-master` |
| 안냥 | `com.jejubucketlist.annyang` | `annyang` |
| 어남선생 | `com.unamrecipe.app` | `unam-teacher` |
| 오늘 운동 캘린더 | `com.byjwstudio.fittocalandroid` | `healthday` |
| 유튜브 레시피 | `com.yeobo.recipe` | `video-recipe` |
| 젠볼 | `com.zenbowl.app` | `zenbowl` |
| 찍으면 중국어 | `com.bodeum.chinesestudyhelper` | `picchina` |
| 뜰사이트 상품 AI 진단 | `com.koreanmatrix.tteulsite` | `tteulsite` |
| 타임 트레이더 | `com.koreanmatrix.timetrader` | `time-trader` |
| 텔레프롬프터 | `com.bodeum.telegraph` | `telegraph` |
| 토닥로그 | `com.dogcat.carehandoff` | `todaklog` |
| 톡픽 | `com.tokpick.alert` | `tokpick` |
| 해적룰렛 STAB! | `com.stab.pirate` | `stab` |
| 헬스스택 | `com.cleanstack.cleanstack` | `healthstack` |

## 보류 앱 10개

| 앱 | Package | 현재 상태 |
| --- | --- | --- |
| Secret Signal Party | `com.bodeum.party.secretsignal` | 내부 테스트 |
| Tap Arena 4 | `com.bodeum.party.taparena4` | 내부 테스트 |
| 도담케어 | `com.dodamcare.app` | 앱 거부됨 |
| 미세베어 | `kr.co.jejuzone.misebear` | Google에서 삭제 |
| 바탕 이슈 | `com.issueon.app` | 앱 거부됨 |
| 보듬 | `me.bodeum.app` | 앱 거부됨 |
| 비트코인토크 | `kr.co.bitcointalk` | Google에서 삭제 |
| 비트코인토크 | `kr.co.bittalk` | Google에서 삭제 |
| 점메추 플러스 | `com.koreanmatrix.eatplus` | 앱 거부됨 |
| 카드프루프 | `com.misebear.cardproof` | 내부 테스트 검토 중 |

## 검증

- 전체 Rails: `89 runs`, `1,088 assertions`, 실패 0
- 앱 디렉터리/페이지 전용: 36개 페이지 전수 canonical/H1/schema/Play CTA 확인
- RuboCop: 7개 대상 파일, offense 0
- Brakeman: warning 0
- 모바일 390px: 디렉터리와 개별 앱 페이지 document overflow 0
- RSS item: 36
- 디렉터리 카드: production 36 + hold 10 = 46
- GitHub Pages 배포: commit `982d703`, build `1175524778`, status `built`
- 공개 URL 전수 검사: sitemap URL 37개, HTTP 200/H1/canonical/schema/Play CTA 실패 0
- 공개 브라우저 검사: H1 1개, Play 링크 36개, console error 0, horizontal overflow 0
- IndexNow: 최초 `202 Accepted` 후 key 검증 완료 재제출 `200 OK`, 37개 URL 접수
- Play contactWebsite: 불완전한 기존 링크 21개만 commit, API readback `21/21 match`
- 기존 전용 HTTPS 사이트·지원 이메일: 변경하지 않음
- Play 보류: PitchFlow(검토 전 변경), HealthDay(기존 업데이트 거부), 유튜브 레시피(동시 작업 충돌), Mulmi(전용 SEO 사이트 유지)
- CI: `aad8d06` run `32922295704` 성공; Brakeman/Bundle Audit/Importmap Audit/RuboCop/Test 전부 통과

## CI 실패 원인과 해결

- 최초 실패 `b7bd025` / run `32919401831`: `bin/brakeman`이 lockfile 버전과 무관하게 원격 최신 버전을 요구해 code 5로 종료.
- 1차 수정: `--ensure-latest` 제거하고 lockfile 기반 재현 가능한 보안 검사를 유지.
- 2차 실패 `2b324db` / run `32920697229`: 최신 advisories가 Rails 및 간접 의존성 취약점을 실제로 탐지.
- 2차 수정: Rails `8.1.3.1`, `concurrent-ruby 1.3.8`, `nokogiri 1.19.4` 등 취약 의존성을 안전한 버전으로 갱신.
- 최종: `54c3f11`, `ba80ebd`, `aad8d06` CI 연속 성공.

## 배포 제약

- `bodeum.me`가 가리키는 Railway 서비스는 현재 로그인된 workspace에 없고, 해당 workspace는 `subscription unpaid` / `trial maxed out` 상태다.
- 결제·DNS·계정 변경은 수행하지 않았다.
- 검색 유입을 막지 않기 위해 기존 무료 GitHub Pages 저장소로 동일 정적 결과물을 배포했다.

## 다음 단계

1. Play Console의 `검토 중`, `검토 전 변경`, `승인`, 공개 등록정보 반영을 앱별로 분리 추적한다.
2. PitchFlow·HealthDay·유튜브 레시피는 기존 변경 상태가 끝난 뒤 contactWebsite를 별도 적용한다.
3. Google Search Console에는 GitHub Pages URL-prefix 소유권 확인 후 sitemap을 추가한다.
4. 각 앱 Android Install Referrer 수신 코드는 다음 앱 릴리스에 맞춰 저장소별로 추가한다.
