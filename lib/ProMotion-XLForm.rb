# encoding: utf-8
unless defined?(Motion::Project::Config)
  raise "ProMotion-XLForm must be required within a RubyMotion project."
end
require 'motion-cocoapods'

Motion::Project::App.setup do |app|
  lib_dir_path = File.dirname(File.expand_path(__FILE__))
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/cells/xl_form_image_selector_cell.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/cells/xl_form_color_selector_cell.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/xl_form_class_methods.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/xl_form_module.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/xl_form_view_controller.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/xl_form.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/xl_form_screen.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/xl_sub_form_screen.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/xl_form_patch.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/value_transformer.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/validators/validator.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/validators/url_validator.rb")
  app.files << File.join(lib_dir_path, "ProMotion/XLForm/validators/regex_validator.rb")

  app.pods do
    pod 'XLForm', '~> 3.0.0'
    pod 'RSColorPicker'
  end
end
