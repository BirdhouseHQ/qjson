require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

context "Environment" do
  asserts("Rails exists") { !!Rails }
  asserts("Module is loaded") { !!QJSON }
end

context "file path" do
  asserts("finds correct path") do
    QJSON::SerializerCache.path_for('books',:show,20151220)
  end.equals("#{Rails.root}/app/views/api/books/show.20151202.qjrb")

  asserts("creates a subclass of QJSON::Base for the QJRB file") do
    QJSON::SerializerCache.class_for('books',:show,20151220) < QJSON::Base
  end
end

context "serializer objects" do
  setup { QJSON::SerializerCache.class_for('books',:show,20151220) }

  # note that it's the found version, not the requested version.
  asserts("serializer object knows about its version") { topic.version }.equals('20151202')
  asserts("serializer object knows about its context") { topic.context }.equals('show')
  asserts("serializer object knows about its model") { topic.model_name }.equals('Book')
end

context "rendering objects" do
  setup do
    create_data!
  end

  asserts("we have books") { Book.count > 2 }
  asserts("we render a readers collection correctly") do
    res = QJSON.render(Reader.first,:show,'20151203')
    res['name'] == 'Reader' && res[:read_titles] == ['Book 1-1','Book 1-3','Book 2-2']
  end

  asserts("render something with a collection correctly includes stuff") do
    res = QJSON.render(Reader.first,:show,'20151221')
    res[:books][0][:author_name] != nil && res['name'] == 'Reader'
  end

end
