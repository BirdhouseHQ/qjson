require 'qjson/serializer_cache'
require 'qjson/collection_serializer'
require 'qjson/base'

module QJSON
  # the two main entry points to QJSON, `render`, and `parse`
  def self.render(record,context,version)
    serializer = SerializerCache.find(record,context,version)
    serializer.render(record,version)
  end

  def self.render_collection(collection,context,version,options={})
    collection_serializer = CollectionSerializer.new

    collection_serializer.render(collection,context,version,options)
  end

  def self.parse(record,json,context,version)
    serializer = SerializerCache.find(record,context,version)
    serializer.parse(record,json,version)
  end
end
