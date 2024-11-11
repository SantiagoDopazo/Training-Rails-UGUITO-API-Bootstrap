require 'rails_helper'

shared_examples 'successful response' do
  it 'responds with the correct keys' do
    expect(response_body.sample.keys).to eq(expected_keys)
  end

  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:user_note_count) { Faker::Number.between(from: 3, to: 10) }
    let(:user_notes) { create_list(:note, user_note_count, user: user) }
    let(:expected_keys) { %w[id title note_type content_length] }

    context 'when user is logged in' do
      include_context 'with authenticated user'

      context 'when fetching all user notes' do
        before do
          user_notes
          get :index
        end

        include_examples 'successful response'
      end

      context 'when fetching notes with page paramaters' do
        let(:page) { 1 }
        let(:page_size) { Faker::Number.between(from: 1, to: user_note_count) }

        context 'when fetching notes with page size' do
          before do
            user_notes
            get :index, params: { page: page, page_size: page_size }
          end

          include_examples 'successful response'

          it 'retrieves the correct number of notes' do
            expect(response_body.size).to eq(page_size)
          end
        end
      end

      context 'when fetching notes using filters' do
        let(:note_type) { %w[review critique].sample }
        let(:filtered_notes) { user_notes.select { |note| note.note_type == note_type } }

        context 'when note_type is valid' do
          before do
            user_notes
            get :index, params: { note_type: note_type }
          end

          include_examples 'successful response'

          it 'retrieves only the notes of the note_type' do
            expect(response_body.size).to eq(filtered_notes.size)
          end
        end

        context 'when note_type is invalid' do
          let(:invalid_note_type) { 'invalid' }

          before do
            get :index, params: { note_type: invalid_note_type }
          end

          it 'returns an unprocessable entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when fetching notes with order' do
        context 'when order is asc' do
          let(:notes_sorted_asc) { user_notes.sort_by(&:created_at) }

          before do
            user_notes
            get :index, params: { order: 'asc' }
          end

          it 'returns notes ordered upward' do
            expect(response_body.first['id']).to eq(notes_sorted_asc.first['id'])
          end
        end

        context 'when order is desc' do
          let(:notes_sorted_desc) { user_notes.sort_by(&:created_at).reverse }

          before do
            user_notes
            get :index, params: { order: 'desc' }
          end

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
      let(:expected) { ShowNoteSerializer.new(note).to_json }

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }

        before { get :show, params: { id: note.id } }

        it 'responds with the correct number of items' do
          expect(response_body.to_json.size).to eq(expected.size)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching a invalid note' do
        before { get :show, params: { id: Faker::Number.number } }

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
end
