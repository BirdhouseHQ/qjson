class QJSON::CollectionSerializer
  def includes(*hash)
    # you must do the inclusion on the first record, or it won't get performed:
    return unless @current_index == 0

    @collection = @collection.includes(*hash)

    return if @current_index == nil

    puts "CALLING INCLUDES ON A COLLECTION!"
    # magical hot-switcheroo, if we are getting the includes call from the
    # renderer itself, we switch in the object to a new object which already
    # has the desired inclusion.  This way we can specify inclusions from the
    @current_item = @collection[@current_index]
    renderer.object = @current_item
  end

  def renderer
    @renderer ||= QJSON::SerializerCache.find(@current_item,@context,@version).new
  end

  def render_one(index)
    # Copied from the
    @current_index = index
    @current_item = @collection[index]

    renderer.object = @current_item
    renderer.hash = {}
    renderer.collection_serializer = self
    renderer.options = @options.except(:each_options).merge(@options[:each_options] || {})
    renderer.call_to_json

    renderer.hash
  end

  def render(collection,context,version,options={})
    @options = options
    @collection = collection
    @context = context
    @version = version

    # We do a by-index iteration so we can hot-swap items if an inclusion is
    # requested.
    (0..@collection.length-1).map { |i| render_one(i) }
  end
end
