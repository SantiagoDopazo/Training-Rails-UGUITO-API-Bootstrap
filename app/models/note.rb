# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  content    :string           not null
#  note_type  :integer          not null
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  validates :user_id, :title, :content, :note_type,
            presence: true
  enum note_type: { review: 0, critique: 1 }

  validate :validate_review_word_limit, if: -> { user.present? && content.present? }

  belongs_to :user
  has_one :utility, through: :user

  def word_count
    content.split.size
  end

  def content_length
    return 'short' if word_count <= utility.short_content
    return 'medium' if word_count <= utility.medium_content
    'long'
  end

  private

  def validate_review_word_limit
    return unless review? && content_length != 'short'
    errors.add(:length, I18n.t(:error_review_lenght, { limit: utility.short_content }))
  end
end
