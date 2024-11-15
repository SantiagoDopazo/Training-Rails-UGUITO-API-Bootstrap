require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:user_note_count) { Faker::Number.between(from: 3, to: 10) }
    let(:user_notes) { create_list(:note, user_note_count, user: user) }
    let(:expected_keys) { %w[id title note_type content_length] }
    let(:respond_keys) { response_body.sample.keys }

    context 'when user is logged in' do
      include_context 'with authenticated user'

      before do
        user_notes
        get :index, params: params
      end

      context 'when fetching all user notes' do
        let(:params) { nil }

        include_examples 'successful response'

        it 'retrieves all the notes of the user' do
          expect(response_body.size).to eq(user_notes.size)
        end
      end

      context 'when fetching notes with page paramaters' do
        let(:page) { 1 }
        let(:page_size) { Faker::Number.between(from: 1, to: user_note_count) }
        let(:params) { { page: page, page_size: page_size } }
        let(:expected_notes) { user_notes.first(page_size) }

        include_examples 'successful response'

        it 'retrieves the correct number of notes' do
          expect(response_body.size).to eq([page_size, user_notes.size].min)
        end

        it 'retrieves notes corresponding to the first page' do
          expect(response_body.map { |note| note['id'] }).to eq(expected_notes.map(&:id))
        end
      end

      context 'when fetching notes using filters' do
        let(:filtered_notes) { user_notes.select { |note| note.note_type == note_type } }
        let(:params) { { note_type: note_type } }

        context 'when note_type is valid' do
          let(:note_type) { %w[review critique].sample }

          include_examples 'successful response'

          it 'retrieves only the notes of the note_type' do
            expect(response_body.size).to eq(filtered_notes.size)
          end
        end

        context 'when note_type is invalid' do
          let(:note_type) { 'invalid_note_type' }

          it 'returns an unprocessable entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when fetching notes with order' do
        context 'when order is asc' do
          let(:notes_sorted_asc) { user_notes.sort_by(&:created_at) }
          let(:params) { { order: 'asc' } }

          it 'returns notes ordered upward' do
            expect(response_body.first['id']).to eq(notes_sorted_asc.first['id'])
          end
        end

        context 'when order is desc' do
          let(:notes_sorted_desc) { user_notes.sort_by(&:created_at).reverse }
          let(:params) { { order: 'desc' } }

          it 'returns notes ordered descendant' do
            expect(response_body.first['id']).to eq(notes_sorted_desc.first['id'])
          end
        end
      end
    end

    context 'when user is not logged in' do
      before { get :index }

      it_behaves_like 'unauthorized'
    end
  end

  describe 'GET #show' do
    context 'when user is logged in' do
      include_context 'with authenticated user'

      before { get :show, params: params }

      let(:expected_keys) { %w[id title note_type word_count created_at content content_length user] }
      let(:respond_keys) { response_body.keys }

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }
        let(:params) { { id: note.id } }

        include_examples 'successful response'

        it 'returns the desired record' do
          expect(note.class.find(response_body['id'])).to eq(note)
        end
      end

      context 'when fetching an invalid note' do
        let(:params) { { id: Faker::Number.number } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when there is not a user logged in' do
      before { get :show, params: { id: Faker::Number.number } }

      it_behaves_like 'unauthorized'
    end
  end

  describe 'POST #create' do
    subject(:create_note) { post :create, params: { note: note_params } }

    let(:note_params) { attributes_for(:note) }

    context 'when user is logged in' do
      include_context 'with authenticated user'

      context 'when parameters are valid' do
        let(:note) { Note.last }
        let(:attributes) { %i[title content note_type].sample }

        it 'creates a new note' do
          expect { create_note }.to change(Note, :count).by(1)
        end

        it 'creates the note with the correct attributes' do
          create_note
          expect(note[attributes]).to eq(note_params[attributes])
        end

        it 'responds with a success message' do
          create_note
          expect(response_body['message']).to eq(I18n.t('controller.note_create_success'))
        end

        it 'responds with 201 status' do
          create_note
          expect(response).to have_http_status(:created)
        end
      end

      context 'when note_type is invalid' do
        let(:note_params) { attributes_for(:note, note_type: 'invalid_type') }
        let(:message) { I18n.t('controller.note_invalid_type') }

        it_behaves_like 'bad note creation'

        it 'responds with 422 status' do
          create_note
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when a required parameter is missing' do
        let(:obligatory_params) { %i[title note_type content] }
        let(:note_params) { attributes_for(:note).except(obligatory_params.sample) }
        let(:message) { I18n.t('controller.note_parameter_missing') }

        it_behaves_like 'bad note creation'

        it 'responds with 400 status' do
          create_note
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when user is not logged in' do
      before { post :create, params: { note: note_params } }

      it_behaves_like 'unauthorized'
    end
  end
end
