# frozen_string_literal: true

# name: salla-community
# about: Plugin for custom APIs For Salla Community
# version: 0.1
# authors: Ahsan
# url: https://github.com/Ahsan1447/salla-community.git

enabled_site_setting :enable_salla_community

after_initialize do
  module ::SallaCommunity
    PLUGIN_NAME = "salla-community".freeze

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace SallaCommunity
    end
  end

  require_relative "app/controllers/notification_counts_controller"

  ::SallaCommunity::Engine.routes.draw do
    get "/count" => "notification_counts#count", :constraints => {format: /(json|rss)/,}
    get "/activity_count" => "notification_counts#activity_count", :constraints => {format: /(json|rss)/,}
  end

  Discourse::Application.routes.append { mount ::SallaCommunity::Engine, at: "/notification_counts" }

end
