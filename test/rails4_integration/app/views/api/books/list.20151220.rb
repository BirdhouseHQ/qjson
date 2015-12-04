def to_json
  includes(:author)
  @hash[:author_name] = @object.author.name
  attributes_except
end
