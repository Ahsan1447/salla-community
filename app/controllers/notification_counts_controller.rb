# frozen_string_literal: true

class SallaCommunity::NotificationCountsController < ::ApplicationController
  requires_plugin SallaCommunity::PLUGIN_NAME

  def count
    user_id = params[:user_id]
    notification_types = {
      replied: 1,
      mentioned: 2,
      liked: 5,
      reaction: 25
    }

    notifications = Notification
                      .where(user_id: user_id, notification_type: notification_types.values)
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
      all: user.user_actions.where(action_type: [5,4]).select { |a| a.target_topic.closed == false && a.target_topic.deleted_at.nil? }.count,
      topics: user.topics.select { |t| t.closed == false && t.deleted_at.nil? }.count,
      posts: user.user_actions.where(action_type: 5).select { |a| a.target_topic.closed == false && a.target_topic.deleted_at.nil? }.count,
      likes: DiscourseReactions::ReactionUser.where(user_id: user.id).count,
      answers: user.topics.select {  |t| t.closed == false && t.deleted_at.nil? && t.custom_fields[::DiscourseSolved::ACCEPTED_ANSWER_POST_ID_CUSTOM_FIELD].present? }.count,
      bookmarks: user.bookmarks.count
    }

    render json: {
      all: counts[:all],
      topics: counts[:topics],
      posts: counts[:posts],
      likes: counts[:likes],
      answers: counts[:answers],
      bookmarks: counts[:bookmarks]
    }
  end

end
