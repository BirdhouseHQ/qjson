require 'test_helper'

context "module basics" do
  asserts('Module has render function') { QJSON.respond_to? :render }
  asserts('Module has parse function') { QJSON.respond_to? :parse }
end
