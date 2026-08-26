class AppSupportController < ApplicationController
  def index
    @apps = PlayAppCatalog.active
    @held_apps = PlayAppCatalog.held
  end

  def show
    @app = PlayAppCatalog.find(params[:slug])
    raise ActiveRecord::RecordNotFound unless @app
  end

  def feed
    @apps = PlayAppCatalog.active
    response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
  end

  def haruscene_privacy
  end

  def haruscene_support
  end

  def batang_issue_privacy
  end

  def batang_issue_support
  end

  def rush_pass_privacy
  end

  def rush_pass_support
  end

  def secret_signal_privacy
  end

  def secret_signal_support
  end

  def tap_arena_privacy
  end

  def tap_arena_support
  end
end
