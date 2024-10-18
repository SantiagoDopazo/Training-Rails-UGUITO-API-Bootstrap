# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string
#  content    :string
#  note_type  :string
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  validates :user_id, :title, :content, :note_type,
            presence: true
  validates :note_type, inclusion: { in: %w[review critique] }
  belongs_to :user
  has_one :utility, through: :user
end
