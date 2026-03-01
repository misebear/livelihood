# frozen_string_literal: true

# 중복 혜택 제거 및 데이터 정제 서비스
class BenefitDeduplicationService
  def self.call
    new.deduplicate
  end

  def deduplicate
    Rails.logger.info "[BenefitDedup] 중복 제거 시작..."

    removed = remove_exact_duplicates
    merged = merge_similar_titles
    cleaned = clean_stale_data

    result = { removed: removed, merged: merged, cleaned: cleaned }
    Rails.logger.info "[BenefitDedup] 완료: #{result}"
    result
  end

  private

  # external_id가 같은 중복 레코드 제거
  def remove_exact_duplicates
    count = 0
    Benefit.select(:external_id).group(:external_id).having("COUNT(*) > 1").pluck(:external_id).each do |eid|
      duplicates = Benefit.where(external_id: eid).order(priority: :desc, updated_at: :desc)
      duplicates.offset(1).destroy_all
      count += duplicates.count - 1
    end
    count
  end

  # 제목이 매우 유사한 항목 병합 (API/크롤링 데이터 → 시드에 보충)
  def merge_similar_titles
    count = 0
    seed_benefits = Benefit.where(source: "seed")

    seed_benefits.each do |seed|
      # 같은 제목의 API/크롤링 데이터 찾기
      similar = Benefit.where.not(source: "seed")
                       .where("title LIKE ?", "%#{seed.title}%")

      similar.each do |dup|
        # 시드에 빈 필드가 있으면 보충
        seed.summary = dup.summary if seed.summary.blank? && dup.summary.present?
        seed.target_group = dup.target_group if seed.target_group.blank? && dup.target_group.present?
        seed.support_amount = dup.support_amount if seed.support_amount.blank? && dup.support_amount.present?
        seed.save! if seed.changed?

        dup.destroy!
        count += 1
      end
    end
    count
  end

  # 오래된 크롤링 데이터 정리 (30일 이상 미갱신)
  def clean_stale_data
    stale = Benefit.where(source: ["data.go.kr"])
                   .where.not(source: "seed")
                   .where("last_synced_at < ?", 30.days.ago)

    count = stale.count
    # 삭제하지 않고 priority를 낮춤 (데이터 보존)
    stale.update_all(priority: -1)
    count
  end
end
