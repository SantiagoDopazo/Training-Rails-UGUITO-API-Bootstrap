module Api
  module V1
    class NotesController < ApplicationController
      def index
        return render_invalid_note_type unless valid_note_type?
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def notes
        Note.all
      end

      def valid_note_type?
        note_type_present? && note_type_ok?
      end

      def note_type_present?
        params[:note_type].present?
      end

      def note_type_ok?
        Note.note_types.keys.include?(params[:note_type])
      end

      def notes_filtered
        notes
          .by_note_type(params[:note_type])
          .ordered_by(params[:order])
          .paginated(params[:page], params[:page_size])
      end

      def show_note
        notes.find(params.require(:id))
      end

      def render_invalid_note_type
        render json: { error: I18n.t(:error_note_type_invalid) }
      end
    end
  end
end
