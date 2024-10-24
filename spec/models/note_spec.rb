require 'rails_helper'

RSpec.describe Note, type: :model do
  subject do
    create(:note)
  end

  let(:user) { create(:user, utility: utility) }
  let(:note) { build(:note, note_type: :review, content: Faker::Lorem.words(number: word_count), user: user) }

  describe 'validations' do
    context 'when validating presence' do
      %i[user_id title content note_type].each do |value|
        it { is_expected.to validate_presence_of(value) }
      end
    end

    context 'when user has NorthUtility' do
      let(:utility) { create(:north_utility) }

      context 'with valid word count' do
        let(:word_count) { rand(0..50) }

        it 'is valid if review word count is in NorthUtility limit' do
          expect(note).to be_valid
        end
      end

      context 'with invalid word count' do
        let(:word_count) { rand(51..99) }

        it 'is invalid if review word count exceeds NorthUtility limit' do
          expect { note.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'when user has SouthUtility' do
      let(:utility) { create(:south_utility) }

      context 'with valid word count' do
        let(:word_count) { rand(0..60) }

        it 'is valid if review word count is in SouthUtility limit' do
          expect(note).to be_valid
        end
      end

      context 'with invalid word count' do
        let(:word_count) { rand(61..120) }

        it 'is invalid if review word count exceeds SouthUtility limit' do
          expect { note.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end

  describe '#content_length' do
    context 'when user has NorthUtility' do
      let(:utility) { create(:north_utility) }

      context 'with short content' do
        let(:word_count) { rand(0..utility.short_content) }

        it 'returns "short" if word count is equal to or less than short_content' do
          expect(note.content_length).to eq('short')
        end
      end

      context 'with medium content' do
        let(:word_count) { rand(utility.short_content + 1..utility.medium_content) }

        it 'returns "medium" if word count is greater than short_content and equal to or less than medium_content' do
          expect(note.content_length).to eq('medium')
        end
      end

      context 'with long content' do
        let(:word_count) { rand(utility.medium_content + 1..999) }

        it 'returns "long" if word count is greater than medium_content' do
          expect(note.content_length).to eq('long')
        end
      end
    end

    context 'when user has SouthUtility' do
      let(:utility) { create(:south_utility) }

      context 'with short content' do
        let(:word_count) { rand(0..utility.short_content) }

        it 'returns "short" if word count is equal to or less than short_content' do
          expect(note.content_length).to eq('short')
        end
      end

      context 'with medium content' do
        let(:word_count) { rand(utility.short_content + 1..utility.medium_content) }

        it 'returns "medium" if word count is greater than short_content and equal to or less than medium_content' do
          expect(note.content_length).to eq('medium')
        end
      end

      context 'with long content' do
        let(:word_count) { rand(utility.medium_content + 1..999) }

        it 'returns "long" if word count is greater than medium_content' do
          expect(note.content_length).to eq('long')
        end
      end
    end
  end

  it { is_expected.to belong_to(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
end
