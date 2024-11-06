ActiveAdmin.register Book do
  includes :utility, :user

  permit_params %i[utility_id user_id genre author image title publisher year]

  filter :genre
  filter :author
  filter :title
  filter :publisher
  filter :year
  filter :created_at

  index do
    selectable_column
    id_column
    column :user
    column :utility
    column :genre
    column :author
    column :image
    column :title
    column :publisher
    column :year
    actions
  end

  show do
    attributes_table do
      row :utility
      row :user
      row :genre
      row :author
      row :image
      row :title
      row :publisher
      row :year
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :utility
      f.input :user
      f.input :genre
      f.input :author
      f.input :image
      f.input :title
      f.input :publisher
      f.input :year
    end
    f.actions
  end
end
