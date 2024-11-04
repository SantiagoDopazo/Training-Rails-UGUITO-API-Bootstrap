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

  shared_examples 'a content_length response' do |length|
    it "returns #{length}" do
      expect(note_with_attributes.content_length).to eq(length)
    end
  end

  describe '#validate_review_word_limit' do
    let(:review_note) { build(:note, note_type: :review, user: user) }

    before do
      allow(review_note).to receive(:content_length).and_return(content_length)
    end

    context 'when content length is short' do
      let(:content_length) { 'short' }

      it 'does not have errors' do
        review_note.save
        expect(review_note.errors.count).to eq(0)
      end
    end

    context 'when content length is not short' do
      let(:content_length) { %w[medium long].sample }

      it 'has errors' do
        review_note.save
        expect(review_note.errors.count).to eq(1)
      end
    end
  end

  describe '#word_count' do
    let(:expected_word_count) { note_with_attributes.content.split.size }

    context 'when content is random' do
      let(:number) { Faker::Number.between(from: 0, to: 999) }

      it 'returns the correct word count' do
        expect(note_with_attributes.word_count).to eq(expected_word_count)
      end
    end
  end

  describe '#content_length' do
    context 'with short content' do
      let(:number) { Faker::Number.between(from: 0, to: utility.short_content) }

      it_behaves_like 'a content_length response', 'short'
    end

    context 'with medium content' do
      let(:number) { Faker::Number.between(from: utility.short_content + 1, to: utility.medium_content) }

      it_behaves_like 'a content_length response', 'medium'
    end

    context 'with long content' do
      let(:number) { Faker::Number.between(from: utility.medium_content + 1, to: 999) }

      it_behaves_like 'a content_length response', 'long'
    end
  end
end
