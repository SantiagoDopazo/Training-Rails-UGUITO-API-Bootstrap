require 'rails_helper'

shared_examples 'a content_length response' do |length|
  it "returns #{length}" do
    byebug
    expect(note_with_attributes.content_length).to eq(length)
  end
end

RSpec.describe Note, type: :model do
  subject(:note) { create(:note) }

  it { is_expected.to belong_to(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  %i[user_id title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  describe '#validate_review_word_limit' do
    let(:utility) { create(%i[north_utility south_utility].sample) }
    let(:user) { create(:user, utility: utility) }
    let(:review_note) { build(:note, note_type: :review, user: user) }

    before do
      allow(review_note).to receive(:content_length).and_return(content_length)
      review_note.save
    end

    context 'when content length is short' do
      let(:content_length) { 'short' }

      it 'does not have errors' do
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
    let(:note_with_attributes) { build(:note, content: Faker::Lorem.sentence(word_count: words_number)) }
    let(:words_number) { Faker::Number.between(from: 0, to: 999) }

    it 'returns the correct word count' do
      expect(note_with_attributes.word_count).to eq(words_number)
    end
  end

  describe '#content_length' do
    let(:utility) { create(%i[north_utility south_utility].sample) }
    let(:user) { create(:user, utility: utility) }
    let(:note_with_attributes) { build(:note, content: Faker::Lorem.sentence(word_count: words_number), user: user) }

    context 'with short content' do
      let(:words_number) { Faker::Number.between(from: 0, to: utility.short_content) }

      it_behaves_like 'a content_length response', 'short'
    end

    context 'with medium content' do
      let(:words_number) { Faker::Number.between(from: utility.short_content + 1, to: utility.medium_content) }

      it_behaves_like 'a content_length response', 'medium'
    end

    context 'with long content' do
      let(:words_number) { Faker::Number.between(from: utility.medium_content + 1, to: 999) }

      it_behaves_like 'a content_length response', 'long'
    end
  end
end
