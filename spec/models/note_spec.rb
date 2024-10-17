require 'rails_helper'

RSpec.describe Note, type: :model do
  it 'is invalid without a title' do
    note = described_class.new(content: 'nota', note_type: 'review', user_id: 1)
    expect(note).not_to be_valid
  end

  it 'is invalid without content' do
    note = described_class.new(title: 'hola', note_type: 'review', user_id: 1)
    expect(note).not_to be_valid
  end

  it 'is invalid without content title and note_type' do
    note = described_class.new(user_id: 1)
    expect(note).not_to be_valid
  end

  it 'is invalid without an existing user' do
    non_user_id = 999
    note = described_class.new(title: 'hola', content: 'nota', note_type: 'review', user_id: non_user_id)
    expect(note).not_to be_valid
  end

  it 'is invalid with other note_type than review or critique' do
    note = described_class.new(title: 'hola', content: 'nota', note_type: 'invalido', user_id: 1)
    expect(note).not_to be_valid
  end
end
