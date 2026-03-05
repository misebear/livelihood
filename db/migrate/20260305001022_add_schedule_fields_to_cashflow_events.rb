class AddScheduleFieldsToCashflowEvents < ActiveRecord::Migration[8.1]
  def change
    # 일정 유형: 0=현금흐름(기존), 1=자격갱신, 2=서류제출, 3=상담예약
    add_column :cashflow_events, :schedule_type, :integer, default: 0, null: false
    # 놓치면 수급 탈락 위험한 중요 일정 여부
    add_column :cashflow_events, :is_critical, :boolean, default: false, null: false
    # 메모
    add_column :cashflow_events, :memo, :text
  end
end
