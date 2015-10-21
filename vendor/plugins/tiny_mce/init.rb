require 'tiny_mce'
config.autoload_paths += %W(tiny_mce/app/controllers)
TinyMCE::OptionValidator.load
ActionController::Base.send(:include, TinyMCE)