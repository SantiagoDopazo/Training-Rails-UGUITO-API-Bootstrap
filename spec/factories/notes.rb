FactoryBot.define do
  factory :note do
    title { 'MyString' }
    content { 'MyString' }
    note_type { 'MyString' }
    user { nil }
  end
end
