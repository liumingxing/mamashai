Mamashai::Application.routes.draw do
  match 'ckeditor/images' => 'ckeditor#images'
  match 'ckeditor/files' => 'ckeditor#files'
  match 'ckeditor/create/:kind' => 'ckeditor#create'
end
