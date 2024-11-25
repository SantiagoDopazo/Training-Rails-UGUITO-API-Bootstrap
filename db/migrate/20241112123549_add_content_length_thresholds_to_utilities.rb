class AddContentLengthThresholdsToUtilities < ActiveRecord::Migration[6.1]
  def change
    add_column :utilities, :content_length_limits, :jsonb, default: {}
  end
end
