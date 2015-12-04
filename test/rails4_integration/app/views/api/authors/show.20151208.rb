def to_json(object)
  h = object.as_json(only: [:name,:id])
  h[:books] = object.books.limit(5)
end

def from_json(object,json_hash)

end
