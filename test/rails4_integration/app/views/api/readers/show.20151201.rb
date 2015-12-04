def to_json
  @hash.merge! @object.as_json(only: :name )
  books = @object.books.includes(:author)
  @hash[:read_titles] = books.map { |b| b.title }
  @hash[:read_authors] = (books.map { |b| b.author.name }).uniq
end
