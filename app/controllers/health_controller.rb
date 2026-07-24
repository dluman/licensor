class HealthController < ApplicationController
  def show
    render json: { status: "ok", timestamp: Time.now.utc.iso8601 }
  end
end
