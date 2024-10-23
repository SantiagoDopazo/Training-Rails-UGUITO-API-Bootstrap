require 'rails_helper'

RSpec.describe Note, type: :model do
  subject do
    # build(:note)
    create(:note)
  end

  describe 'validations' do
    context 'when validating presence' do
      %i[user_id title content note_type].each do |value|
        it { is_expected.to validate_presence_of(value) }
      end
    end

    context 'when user has NorthUtility' do
      let(:utility) { create(:north_utility) }
      let(:user) { create(:user, utility: utility) }
      let(:note) { build(:note, note_type: :review, content: Faker::Lorem.words(number: 51), user: user) }

      it 'is valid if review word count is in NorthUtility limit' do
        let(:note) { build(:note, note_type: :review, content: Faker::Lorem.words(number: 50), user: user) }
        expect(note).to be_valid
      end

      it 'is invalid if review word count exceeds NorthUtility limit' do
        expect { note.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  it { is_expected.to belong_to(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
end
