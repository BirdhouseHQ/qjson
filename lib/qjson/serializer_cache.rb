class QJSON::SerializerCache
  # View RE: app/views/api/<possibly namespaced model name>/<context>.<version>.<qjrb or rb>
  VIEW_RE = /app\/views\/api\/(.*?)\/([^\.\/]+)\.([^\.\/]+)\.(qjrb|rb)$/

  def self.cache(name,context,version,hash=nil)
    @_cache ||= {}
    @_cache[name] ||= []

  end

  def self.path_for(klass,context,version)
    version = version.to_s
    name = klass.name.underscore.pluralize

    all_options = Dir.glob("#{Rails.root}/app/views/api/#{name}/#{context.to_s}.*")

    file_path = nil
    file_version = nil

    all_options.each do |path|
      m = path.match(VIEW_RE)

      # extension not qjrb or rb is most common reason to skip
      next unless m

      f_model_name = m[1]
      f_context = m[2]
      f_version = m[3]
      f_ext = m[4]

      next unless f_context == context.to_s
      next unless f_model_name == name

      if(!file_version || ( file_version < f_version && f_version <= version ) )
        file_path = path
        file_version = f_version
      end
    end

    file_path
  end

  def self.load_path(path)
    if(path.match(/\.rb$/))
      require path
    elsif(path.match(/\.qjrb$/))
      c = Class.new(QJSON::Base)
      c.source_path(path)
      c.class_eval "def operate\n"+File.read(path)+"\nend"
      c
    else
      raise "Invalid Extension #{File.extname(path)}"
    end
  end

  def self.class_for(klass,context,version)
    path = path_for(klass,context,version)
    load_path(path)

    # we have now picked the path

  end

  def self.find(record,context,version)

    load_class_for(record.class,context,version)
  end
end
