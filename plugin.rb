# frozen_string_literal: true

# name: notification_counts
# about: Notification counts
# version: 0.1
# authors: Ahsan

enabled_site_setting :enable_notification_counts

after_initialize do
  module ::NotificationCounts
    PLUGIN_NAME = "notification_counts".freeze

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace NotificationCounts
    end
  end

  require_relative "app/controllers/notification_counts_controller"

  NotificationCounts::Engine.routes.draw do
    get "/count" => "notification_counts#count", :constraints => {format: /(json|rss)/,}
    get "/activity_count" => "notification_counts#activity_count", :constraints => {format: /(json|rss)/,}
  end

  Discourse::Application.routes.append { mount ::NotificationCounts::Engine, at: "/notification_counts" }

end
