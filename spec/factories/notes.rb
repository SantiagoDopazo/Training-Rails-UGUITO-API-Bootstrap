FactoryBot.define do
  factory :note do
    title { Faker::Book.title }
    content { Faker::Lorem.paragraph }
    note_type { Note.note_types.keys.sample }
    user { association :user }
  end
end
