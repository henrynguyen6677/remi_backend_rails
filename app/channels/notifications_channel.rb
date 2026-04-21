# frozen_string_literal: true

class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_#{params[:room]}"
  end
  def unsubscribed
  end
end
