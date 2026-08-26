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

- 디렉터리: `https://bodeum.me/app-support`
- 앱별 URL: `https://bodeum.me/apps/{slug}`
- 최신 앱 피드: `https://bodeum.me/apps/rss.xml`
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

- 전체 Rails: `87 runs`, `1,071 assertions`, 실패 0
- 앱 디렉터리/페이지 전용: 36개 페이지 전수 canonical/H1/schema/Play CTA 확인
- RuboCop: 7개 대상 파일, offense 0
- Brakeman: warning 0
- 모바일 390px: 디렉터리와 개별 앱 페이지 document overflow 0
- RSS item: 36
- 디렉터리 카드: production 36 + hold 10 = 46

## 다음 단계

1. 프로덕션 배포 후 36개 URL, RSS, sitemap live readback.
2. 변경 URL만 IndexNow 제출하고 기존 `bodeum.me` Search Console sitemap의 재수집을 확인.
3. Play Console contactWebsite를 앱별 URL로 바꾸는 작업은 API dry-run과 사용자 확인 뒤 별도 commit.
4. 각 앱 Android Install Referrer 수신 코드는 다음 앱 릴리스에 맞춰 저장소별로 추가한다.
