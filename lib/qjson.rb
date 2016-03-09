require 'qjson/serializer_cache'
require 'qjson/collection_serializer'
require 'qjson/base'

module QJSON
  class << self 
    # the two main entry points to QJSON, `render`, and `parse`
    def render(record,context,version,options={})
      serializer = SerializerCache.find(record,context,version)
      serializer.render(record,version,options)
    end

    def render_collection(collection,context,version,options={})
      collection_serializer = CollectionSerializer.new

      collection_serializer.render(collection,context,version,options)
    end

    def parse(record,json,context,version)
      serializer = SerializerCache.find(record,context,version)
      serializer.parse(record,json,version)
    end
  end
end
