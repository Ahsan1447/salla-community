# frozen_string_literal: true

class NotificationCounts::NotificationCountsController < ::ApplicationController
  requires_plugin NotificationCounts::PLUGIN_NAME

  def count
    user_id = params[:user_id]
    notification_types = {
      replied: 1,
      mentioned: 2,
      liked: 5,
      reaction: 25
    }

    notifications = Notification
                      .where(user_id: user_id, read: false, notification_type: notification_types.values)
                      .group(:notification_type)
                      .count
    notification_counts = notification_types.transform_values { |type| notifications[type] || 0 }

    render json: {
      all: notification_counts.values.sum,
      replies: notification_counts[:replied],
      mentions: notification_counts[:mentioned],
      likes_and_reactions: notification_counts[:liked] + notification_counts[:reaction]
    }
  end

  def activity_count
    user = User.find_by(id: params[:user_id])

    return render json: { error: 'User not found' }, status: :not_found unless user

    counts = {
      topics: user.topics.count,
      posts: user.posts.count,
      likes: user.topics.sum(:like_count) + user.posts.sum(:like_count),
      answers: user.topics.where(has_answered: true).count,
      bookmarks: user.bookmarks.count
    }

    render json: {
      all: counts[:topics] + counts[:posts],
      topics: counts[:topics],
      posts: counts[:posts],
      likes: counts[:likes],
      answers: counts[:answers],
      bookmarks: counts[:bookmarks]
    }
  end

end
