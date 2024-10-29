require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  shared_examples 'successfully response' do
    let(:expected) do
      ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                        serializer: IndexNoteSerializer).to_json
    end
    it 'responds with the expected notes json' do
      expect(response_body.to_json).to eq(expected)
    end

    it 'responds with 200 status' do
      expect(response).to have_http_status(:ok)
    end
  end
  describe 'GET #index' do
    let(:user_notes) { create_list(:note, 3, user: user) }

    context 'when user is logged in' do
      include_context 'with authenticated user'

      context 'when fetching all user notes' do
        let!(:notes_custom) { user_notes }
        let(:notes_expected) { notes_custom }

        before { get :index }

        include_examples 'successfully response'
      end

      context 'when fetching notes with page paramaters' do
        let(:page) { 1 }
        let(:page_size) { 3 }
        let!(:notes_custom) { user_notes.first(3) }
        let(:notes_expected) { notes_custom }

        context 'when fetching notes with page size' do
          before { get :index, params: { page_size: page_size } }

          include_examples 'successfully response'
        end

        context 'when fetching notes with page and page size' do
          before { get :index, params: { page: page, page_size: page_size } }

          include_examples 'successfully response'
        end
      end

      context 'when fetching notes using filters' do
        let(:note_type) { :review }
        let!(:notes_custom) { create_list(:note, 2, user: user, note_type: note_type) }
        let(:notes_expected) { notes_custom }

        before { get :index, params: { note_type: note_type } }

        include_examples 'successfully response'
      end
    end

    context 'when user is not logged in' do
      context 'when fetching all user notes' do
        before { get :index }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #show' do
    context 'when user is logged in' do
      include_context 'with authenticated user'
      let(:expected) { ShowNoteSerializer.new(note).to_json }

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }

        before { get :show, params: { id: note.id } }

        it 'responds with the expected notejson' do
          expect(response_body.to_json).to eq(expected)
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
      context 'when fetching a note' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'POST #create' do
  end
end
