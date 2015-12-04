class QJSON::Base
  def self.source_path(path=nil)
    @source_path = path if path
    @source_path
  end
end
