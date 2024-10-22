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

  belongs_to :user
  has_one :utility, through: :user

  def word_count
    content.scan(/\w+/).size
  end
end
