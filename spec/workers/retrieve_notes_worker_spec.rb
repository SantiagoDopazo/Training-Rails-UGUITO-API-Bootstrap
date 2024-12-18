require 'rails_helper'

describe RetrieveNotesWorker do
  describe '#execute' do
    subject(:execute_worker) do
      VCR.use_cassette "retrieve_notes/#{utility_name}/valid_params" do
        described_class.new.execute(user.id, params)
      end
    end

    let(:author) { 'J.K. Rowling' }
    let(:params) { { author: author } }
    let(:user) { create(:user, utility: utility) }

    context 'with utility service' do
      let_it_be(:utilities) do
        %i[south_utility]
      end

      include_context 'with utility' do
        let_it_be(:utility) { create(utilities.sample) }
      end

      context 'when the request to the utility succeeds' do
        let(:expected_note_keys) { %i[id title type created_at content user book] }
        let(:expected_user_keys) { %i[email first_name last_name] }
        let(:expected_book_keys) { %i[title author genre] }

        it 'succeeds' do
          expect(execute_worker.first).to eq 200
        end

        it 'returns the expected note keys' do
          expect(execute_worker.second[:notes].sample.keys).to contain_exactly(*expected_note_keys)
        end

        it 'returns the expected user keys' do
          expect(execute_worker.second[:notes].sample[:user].keys).to contain_exactly(*expected_user_keys)
        end

        it 'returns the expected book keys' do
          expect(execute_worker.second[:notes].sample[:book].keys).to contain_exactly(*expected_book_keys)
        end
      end

      context 'when the request to the utility fails' do
        subject(:execute_worker) do
          described_class.new.execute(user.id, params)
        end

        let(:expected_status_code) { 500 }
        let(:expected_response_body) { { error: 'message' } }
        let(:utility_service_method) { :retrieve_notes }

        before do
          allow(utility_service_class).to receive(:new).and_return(utility_service_instance)
          allow(utility_service_instance).to receive(utility_service_method)
            .and_return(instance_double(utility_service_response_class,
                                        code: expected_status_code, body: expected_response_body))
          allow(utility_service_instance).to receive(:utility).and_return(utility)
        end

        it 'returns status code obtained from the utility service' do
          expect(execute_worker.first).to eq(expected_status_code)
        end

        it 'returns the body obtained from the utility service' do
          expect(execute_worker.second).to eq(expected_response_body)
        end
      end
    end
  end
end
