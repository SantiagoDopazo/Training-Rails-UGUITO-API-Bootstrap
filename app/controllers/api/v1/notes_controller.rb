module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordInvalid, with: :respond_invalid_record
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      before_action :validate_note_type, only: :create

      def index
        render json: notes_paginated, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      def create
        current_user.notes.create!(note_params)
        render json: { message: I18n.t('controller.note_create_success') }, status: :created
      end

      def index_async
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
        { created_at: params[:order] || 'asc' }
      end

      def filtering_params
        params.permit(%i[note_type])
      end

      def show_note
        notes.find(params.require(:id))
      end

      def note_params
        params.require(:note).require(%i[title note_type content])
        params.permit(note: %i[title note_type content])[:note].to_h
      end

      def respond_invalid_record
        render json: error_review_length, status: :bad_request
      end

      def parameter_missing
        render json: { error: I18n.t('controller.note_parameter_missing') }, status: :bad_request
      end

      def validate_note_type
        render_invalid_note_type unless correct_note_type?
      end

      def error_review_length
        { error: I18n.t('model.error_review_length',
                        { limit: current_user.utility.short_content }) }
      end

      def render_invalid_note_type
        render json:
          { error: I18n.t('controller.note_invalid_type') }, status: :unprocessable_entity
      end

      def correct_note_type?
        Note.note_types.keys.include?(params[:note][:note_type])
      end
    end
  end
end
