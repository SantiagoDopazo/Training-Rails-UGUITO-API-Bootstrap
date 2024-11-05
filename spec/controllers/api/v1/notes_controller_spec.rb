require 'rails_helper'

shared_examples 'successfully response' do
  let(:expected_keys) { %w[id title note_type content_length] }
  let(:expected) do
    ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                      serializer: IndexNoteSerializer).to_json
  end

  it 'responds with the correct number of items' do
    expect(response_body.size).to eq(notes_expected.size)
  end

  it 'responds with the correct keys' do
    expect(response_body.first.keys).to eq(expected_keys)
  end

  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:user_notes) { create_list(:note, 3, user: user) }

    context 'when user is logged in' do
      include_context 'with authenticated user'

      context 'when fetching all user notes' do
        let(:notes_expected) { user_notes }

        before do
          user_notes
          get :index
        end

        include_examples 'successfully response'
      end

      context 'when fetching notes with page paramaters' do
        let(:page) { 1 }
        let(:page_size) { 3 }
        let(:notes_expected) { user_notes }

        context 'when fetching notes with page size' do
          before do
            user_notes
            get :index, params: { page_size: page_size }
          end

          include_examples 'successfully response'
        end

        context 'when fetching notes with page and page size' do
          before do
            user_notes
            get :index, params: { page: page, page_size: page_size }
          end

          include_examples 'successfully response'
        end
      end

      context 'when fetching notes using filters' do
        let(:note_type) { :review }
        let(:notes_custom) { create_list(:note, 2, user: user, note_type: note_type) }
        let(:notes_expected) { notes_custom }

        context 'when note_type is valid' do
          before do
            notes_custom
            get :index, params: { note_type: note_type }
          end

          include_examples 'successfully response'
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
