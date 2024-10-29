module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      rescue_from ActiveRecord::RecordInvalid, with: :respond_invalid_record
      rescue_from ArgumentError, with: :invalid_type

      def index
        render json: notes_paginated, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      def create
        current_user.notes.create!(note_params)
        render json: 'message: Nota creada con exito.', status: :created
      end

      private

      def notes
        current_user.notes
        byebug
      end

      def notes_filtered
        notes.where(filtering_params)
      end

      def notes_paginated
        notes_filtered.order(ordering_params).page(params[:page]).per(params[:page_size])
      end

      def ordering_params
        { created_at: params[:order] || 'asc' }
      end

      def filtering_params
        params.permit(%i[note_type])
      end

      def show_note
        notes.find(params.require(:id))
      end

      def note_params
        params.require(:note).permit(:title, :note_type, :content)
      end

      def respond_invalid_record(error)
        render json: error, status: :bad_request
      end

      def invalid_type(error)
        render json: error, status: :unprocessable_entity
      end
    end
  end
end
