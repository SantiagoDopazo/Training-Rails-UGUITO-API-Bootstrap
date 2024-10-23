FactoryBot.define do
  factory :note do
    user
    title { Faker::Book.title }
    content { Faker::Lorem.paragraph }
    note_type { Note.note_types.keys.sample }
  end
end
