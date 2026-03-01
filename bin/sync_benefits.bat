@echo off
REM 매일 새벽 4시 자동 실행 — Windows 작업 스케줄러에서 호출
cd /d C:\development\livelihood
call bundle exec rails sync:benefits >> C:\development\livelihood\log\sync_benefits.log 2>&1
