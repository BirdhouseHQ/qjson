require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

context "Environment" do
  asserts("Rails exists") { !!Rails }
  asserts("Module is loaded") { !!QJSON }
end

context "file path" do
  asserts("finds correct path") do
    QJSON::SerializerCache.path_for(Book,:show,20151220)
  end.equals("#{Rails.root}/app/views/api/books/show.20151202.qjrb")

  asserts("creates a subclass of QJSON::Base for the QJRB file") do
    QJSON::SerializerCache.class_for(Book,:show,20151220) < QJSON::Base
  end
end
