class Notification < ApplicationRecord
  MAX_RSS_ITEMS_PER_USER = 10
  MAX_RSS_ITEMS_PER_GROUP = 10

  belongs_to :subscriber, polymorphic: true
  belongs_to :notifiable, polymorphic: true

  has_many :notified_projects, dependent: :destroy
  has_many :projects, through: :notified_projects

  serialize :event_payload, JSON

  scope :for_web, -> { where(web: true) }
  scope :for_rss, -> { where(rss: true) }

  def event
    @event ||= event_type.constantize.new(event_payload)
  end

  def user_active?
    !subscriber.away?
  end

  def any_user_in_group_active?
    !subscriber.users.recently_seen.empty?
  end

  def template_name
    event_type.gsub('Event::', '').underscore
  end

  def unread?
    !delivered?
  end
end

# == Schema Information
#
# Table name: notifications
#
#  id                         :integer          not null, primary key
#  bs_request_oldstate        :string(255)
#  bs_request_state           :string(255)
#  delivered                  :boolean          default(FALSE)
#  event_payload              :text(65535)      not null
#  event_type                 :string(255)      not null
#  notifiable_type            :string(255)      indexed => [notifiable_id]
#  rss                        :boolean          default(FALSE)
#  subscriber_type            :string(255)      indexed => [subscriber_id]
#  subscription_receiver_role :string(255)      not null
#  title                      :string(255)
#  type                       :string(255)      default(""), not null
#  web                        :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  notifiable_id              :integer          indexed => [notifiable_type]
#  subscriber_id              :integer          indexed => [subscriber_type]
#
# Indexes
#
#  index_notifications_on_notifiable_type_and_notifiable_id  (notifiable_type,notifiable_id)
#  index_notifications_on_subscriber_type_and_subscriber_id  (subscriber_type,subscriber_id)
#
