module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: notes_paginated, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def notes
        current_user.notes
      end

      def notes_filtered
        notes.where(filtering_params)
      end

      def notes_paginated
        notes_filtered.order(ordering_params).page(params[:page]).per(params[:page_size])
      end

      def ordering_params
        { created_at: params[:order] }
      end

      def filtering_params
        params.permit(%i[note_type])
      end

      def show_note
        notes.find(params.require(:id))
      end
    end
  end
end
