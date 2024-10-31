require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:note) { build(:note, user: user) }
  let(:note_with_attributes) { build(:note, note_type: :review, content: Faker::Lorem.sentence(word_count: number), user: user) }
  let(:utility) { create(%i[north_utility south_utility].sample) }
  let(:user) { create(:user, utility: utility) }

  it { is_expected.to belong_to(:user) }

  it 'has a valid factory' do
    expect(note).to be_valid
  end

  %i[user_id title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  shared_examples 'returns content length' do |length|
    it "returns #{length}" do
      expect(note_with_attributes.content_length).to eq(length)
    end
  end

  describe '#validate_review_word_limit' do
    let(:user) { create(:user, utility: utility) }

    context 'with valid word count' do
      let(:number) { Faker::Number.between(from: 0, to: utility.short_content) }

      it 'does not have errors' do
        note_with_attributes.save
        expect(note_with_attributes.errors.count).to eq(0)
      end
    end

    context 'with invalid word count' do
      let(:number) { Faker::Number.between(from: utility.short_content + 1, to: 999) }

      it 'has errors' do
        note_with_attributes.save
        expect(note_with_attributes.errors.count).to eq(1)
      end
    end
  end

  describe '#word_count' do
    let(:expected_word_count) { note_with_attributes.content.split.size }

    context 'when content is random' do
      let(:number) { Faker::Number.between(from: 0, to: 50) }

      it 'returns the correct word count' do
        expect(note_with_attributes.word_count).to eq(expected_word_count)
      end
    end
  end

  describe '#content_length' do
    context 'with short content' do
      let(:number) { Faker::Number.between(from: 0, to: utility.short_content) }

      it_behaves_like 'returns content length', 'short'
    end

    context 'with medium content' do
      let(:number) { Faker::Number.between(from: utility.short_content + 1, to: utility.medium_content) }

      it_behaves_like 'returns content length', 'medium'
    end

    context 'with long content' do
      let(:number) { Faker::Number.between(from: utility.medium_content + 1, to: 999) }

      it_behaves_like 'returns content length', 'long'
    end
  end
end
