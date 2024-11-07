require 'rails_helper'

describe RetrieveNotesWorker do
  describe '#execute' do
    subject(:execute_worker) do
      VCR.use_cassette "retrieve_notes/#{utility_name}/valid_params" do
        described_class.new.execute(user.id, params)
      end
    end

    let(:author) { ' ' }
    let(:params) { { author: author } }
    let(:user) { create(:user, utility: utility) }

    let(:expected_notes_keys) do
      %i[id title note_type content_length]
    end

    context 'with utility service' do
      let_it_be(:utilities) do
        %i[north_utility ]
      end

      include_context 'with utility' do
        let_it_be(:utility) { create(utilities.sample) }
      end

      context 'when the request to the utility succeeds' do
        it 'succeeds' do
          expect(subject.first).to eq 200
        end
      end
    end
  end
end
