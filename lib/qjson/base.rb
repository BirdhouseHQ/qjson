class QJSON::Base
  VIEW_RE = /app\/views\/api\/(.*?)\/([^\.\/]+)\.([^\.\/]+)\.(qjrb|rb)$/

  # ## Public Methods
  #
  # This is how to interface with the class externally.  The external interface
  # creates an instance of the class, so that it can use class variables to
  # store whatever is desired.

  def self.parse(object,hash,requested_version,options={})
    parser = self.new

    parser.object = object
    parser.request_version = requested_version
    parser.options = options

    parser.hash = hash

    parser.call_from_json

    parser.object
  end

  def self.render(object,requested_version,options = {})
    renderer = self.new

    renderer.request_version = requested_version
    renderer.object = object
    renderer.options = options

    renderer.hash = {}

    renderer.call_to_json

    renderer.hash
  end

  # ### Metadata Methods

  attr_accessor :object,:hash,:options,:collection_serializer

  attr_accessor :request_version

  def self.source_path(path=nil)
    if path
      @source_path = path
      @path_match = path.match(VIEW_RE)
    end

    @source_path
  end

  def self.version
    @path_match[3]
  end
  def self.context
    @path_match[2]
  end
  def self.model_name
    @path_match[1].camelize.singularize
  end

  def version
    self.class.version
  end
  def this_version
    version
  end
  def context
    self.class.context
  end
  def model_name
    self.class.model_name
  end


  def call_to_json
    @direction = :to_json
    r = to_json

    if(r.kind_of?(Hash) && r != hash)
      hash.merge! r
    end
  end

  def call_from_json
    @direction = :from_json
    from_json
  end


  # ### Hook Methods
  #
  # to_json and from_json are one place to implement in
  # subclasses, if you want fine-grained control of how data goes in to and out
  # of the hashes.  Never cache the object locally, this prevents us from doing
  # magical things like automatic includes-from-child calculations

  def to_json
    operate
  end

  def from_json
    operate
  end

  def includes(*hash)
    return unless @direction == :to_json

    collection_serializer.includes(*hash) if(collection_serializer)
  end

  # operate overridden in subclasses with code from .qjrb files.  When called by
  # to_json or from_json by default, a @direction is set which allows the
  # functions called by operate to do the correct direction of operation

  def operate
    # by default, copy all attributes and no associations
    attributes_except
  end

  # ## Internal methods, which operate can use:

  def association(name,context,version,options={})
    attribute_name = options[:attribute_name] || name

    if(@direction == :to_json)
      hash[attribute_name] = QJSON.render_collection(@object.send(name),context,version,options)
    elsif(@direction == :from_json)
      # by default, associations are not parsed out - that is a dangerous,
      # unexpected (to me) behavior!
    else
      raise "InvalidDirection"
    end
  end

  def association_count(attribute_name,association_name)
    if(@direction == :to_json)
      hash[attribute_name] = @object.send(name).count
    elsif(@direction == :from_json)
      # Not a lot to be done, here, folks, no way to "set" a count on an
      # association even if that sounded like a good idea!
    else
      raise "InvalidDirection"
    end
  end

  def attributes(*attr_names)
    s_attr_names = attr_names.map { |name| name.to_s }
    if(@direction == :to_json)
      # some 'view' models contain nil keys in their attributes hashes,
      # eliminate these by adding nil to the except clause:
      @hash.merge! object_attributes.except(nil).slice(*s_attr_names)
    elsif(@direction == :from_json)
      @object.assign_attributes(@hash.slice(*s_attr_names))
    else
      raise "InvalidDirection"
    end
  end

  def attributes_except(*attr_names)
    s_attr_names = attr_names.map { |name| name.to_s }

    if(@direction == :to_json)
      # some 'view' models contain nil keys, exclude them with the nil addition
      # to the except clause
      @hash.merge! object_attributes.except(nil,*s_attr_names)
    elsif(@direction == :from_json)
      @object.assign_attributes(@hash.except(*attr_names))
    else
      raise "InvalidDirection"
    end
  end

  def render_as(other_context)
    if(@direction == :to_json)
      @hash = QJSON.render(object,other_context,request_version,options)
    elsif(@direction == :from_json)
      QJSON.parse(object,hash,other_context,request_version,options)
    else
      raise "InvalidDirection"
    end
  end

  def object_attributes
    return { } unless @object
    return @object.attributes if @object.respond_to? :attributes
    @object.as_json
  end
  
end
