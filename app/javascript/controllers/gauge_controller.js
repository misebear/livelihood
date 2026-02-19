import { Controller } from "@hotwired/stimulus"

// ────────────────────────────────────────────────────────
// Gauge Controller
// ────────────────────────────────────────────────────────
// 안전 자산 게이지 바의 애니메이션을 담당합니다.
// 페이지 로드 시 0% → 실제 퍼센트까지 부드럽게 채워집니다.
//
// 사용법:
//   data-controller="gauge"
//   data-gauge-percentage-value="72.5"
//   data-gauge-target="bar"
// ────────────────────────────────────────────────────────
export default class extends Controller {
  static targets = ["bar"]
  static values  = { percentage: { type: Number, default: 0 } }

  connect() {
    // 약간의 딜레이 후 애니메이션 시작 (페이지 렌더링 후 자연스럽게)
    requestAnimationFrame(() => {
      setTimeout(() => this.animate(), 300)
    })
  }

  animate() {
    if (!this.hasBarTarget) return

    const pct = Math.min(Math.max(this.percentageValue, 0), 100)
    this.barTarget.style.width = `${pct}%`

    // 숫자 카운트업 애니메이션
    this.countUp(0, pct, 1000)
  }

  countUp(start, end, duration) {
    if (!this.hasBarTarget) return

    const range = end - start
    const startTime = performance.now()
    const numberEl = this.barTarget.querySelector("span")
    if (!numberEl) return

    const step = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      // easeOutQuart for smooth deceleration
      const eased = 1 - Math.pow(1 - progress, 4)
      const current = start + (range * eased)

      numberEl.textContent = `${current.toFixed(1)}%`

      if (progress < 1) {
        requestAnimationFrame(step)
      }
    }

    requestAnimationFrame(step)
  }
}
