require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:note) { build(:note, user: user) }
  let(:note_with_attributes) { build(:note, note_type: :review, content: Faker::Lorem.words(number: content), user: user) }
  let(:utility) { create(:north_utility) }
  let(:user) { create(:user, utility: utility) }

  it { is_expected.to belong_to(:user) }

  it 'has a valid factory' do
    expect(note).to be_valid
  end

  %i[user_id title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  describe '#save!' do
    context 'when user has NorthUtility' do
      let(:utility) { create(:north_utility) }

      context 'with valid word count' do
        let(:content) { rand(0..50) }

        it 'create note succesfully' do
          expect(note_with_attributes.save!).to be_truthy
        end
      end

      context 'with invalid word count' do
        let(:content) { rand(51..99) }

        it 'returns ActiveRecord::RecordInvalid' do
          expect { note_with_attributes.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'when user has SouthUtility' do
      let(:utility) { create(:south_utility) }

      context 'with valid word count' do
        let(:content) { rand(0..60) }

        it 'create note succesfully' do
          expect(note_with_attributes.save!).to be_truthy
        end
      end

      context 'with invalid word count' do
        let(:content) { rand(61..120) }

        it 'returns ActiveRecord::RecordInvalid' do
          expect { note_with_attributes.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end

  describe '#word_count' do
    let(:note) { build(:note, content: content) }

    context 'when content is nil' do
      let(:content) { nil }

      it 'returns 0' do
        expect(note.word_count).to eq(0)
      end
    end

    context 'when content contains one word' do
      let(:content) { 'Hello' }

      it 'returns the correct word count' do
        expect(note.word_count).to eq(1)
      end
    end

    context 'when content contains multiple words' do
      let(:content) { 'Hello world! im doing test in ruby.' }

      it 'returns the correct word count' do
        expect(note.word_count).to eq(7)
      end
    end

    context 'when content contains multiple spaces' do
      let(:content) { 'Hello    world' }

      it 'returns the correct word count' do
        expect(note.word_count).to eq(2)
      end
    end
  end

  describe '#content_length' do
    context 'when user has NorthUtility' do
      let(:utility) { create(:north_utility) }

      context 'with short content' do
        let(:content) { rand(0..utility.short_content) }

        it 'returns "short"' do
          expect(note_with_attributes.content_length).to eq('short')
        end
      end

      context 'with medium content' do
        let(:content) { rand(utility.short_content + 1..utility.medium_content) }

        it 'returns "medium"' do
          expect(note_with_attributes.content_length).to eq('medium')
        end
      end

      context 'with long content' do
        let(:content) { rand(utility.medium_content + 1..999) }

        it 'returns "long"' do
          expect(note_with_attributes.content_length).to eq('long')
        end
      end
    end

    context 'when user has SouthUtility' do
      let(:utility) { create(:south_utility) }

      context 'with short content' do
        let(:content) { rand(0..utility.short_content) }

        it 'returns "short"' do
          expect(note_with_attributes.content_length).to eq('short')
        end
      end

      context 'with medium content' do
        let(:content) { rand(utility.short_content + 1..utility.medium_content) }

        it 'returns "medium"' do
          expect(note_with_attributes.content_length).to eq('medium')
        end
      end

      context 'with long content' do
        let(:content) { rand(utility.medium_content + 1..999) }

        it 'returns "long"' do
          expect(note_with_attributes.content_length).to eq('long')
        end
      end
    end
  end
end
