require 'qjson/serializer_cache'
require 'qjson/base'

module QJSON
  # the two main entry points to QJSON, `render`, and `parse`
  def self.render(record,context,version)
    serializer = SerializerCache.find(record,context,version)
    serializer.render(record)
  end

  def self.parse(record,json,context,version)
    serializer = SerializerCache.find(record,context,version)
    serializer.parse(record,json)
  end
end
