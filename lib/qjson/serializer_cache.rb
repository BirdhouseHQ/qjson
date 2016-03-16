module QJSON
  class SerializerCache
    # View RE: app/views/api/<possibly namespaced model name>/<context>.<version>.<qjrb or rb>


    def self.cache(name,context,version,hash=nil)
      @_cache ||= {}
      @_cache[name] ||= []

    end

    def self.path_for(name,context,version)
      version = version.to_s

      all_options = Dir.glob("#{Rails.root}/app/views/api/#{name}/#{context.to_s}.*")

      file_path = nil
      file_version = nil

      all_options.each do |path|
        m = path.match(QJSON::Base::VIEW_RE)

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
      return Class.new(QJSON::Base) unless path

      if(path.match(/\.rb$/))
        c = Class.new(QJSON::Base)
        c.source_path(path)
        c.class_eval File.read(path), path, 1
        c
      elsif(path.match(/\.qjrb$/))
        c = Class.new(QJSON::Base)
        c.source_path(path)
        c.class_eval "def operate\n"+File.read(path)+"\nend" , path, 1
        c
      else
        raise "Invalid Extension #{File.extname(path)}"
      end
    end

    def self.class_for(name,context,version)
      path = path_for(name,context,version)
      puts "Could not find path for #{name} #{context} #{version}" unless path
      load_path(path)
    end

    def self.find(record,context,version)
      class_for(record.class.name.underscore.pluralize,context,version)
    end
  end
end
