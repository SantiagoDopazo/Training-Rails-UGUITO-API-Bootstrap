module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        if params[:note_type].present? && invalid_note_type?
          return render json: { error: 'Invalid note_type' }, status: :unprocessable_entity
        end
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def notes
        current_user.notes
      end

      def invalid_note_type?
        !Note.note_types.keys.include?(params[:note_type])
      end

      def notes_filtered
        notes
          .by_note_type(params[:note_type])
          .ordered_by(params[:order])
          .paginated(params[:page], params[:page_size])
      end

      def filtering_params
        params.permit(%i[note_type]).to_h
      end

      def show_note
        notes.find(params.require(:id))
      end
    end
  end
end
