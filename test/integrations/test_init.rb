require 'rack/test'
require 'riot'
require 'riot/rr'

Riot.pretty_dots

class Riot::Situation
  include Rack::Test::Methods

  def create_data!
    Book.delete_all
    Author.delete_all
    Reader.delete_all

    a1 = Author.create(name: 'Author 1')
    a2 = Author.create(name: 'Author 2')

    b1_1 = a1.books.create(title: "Book 1-1")
    b1_2 = a1.books.create(title: "Book 1-2")
    b1_3 = a1.books.create(title: "Book 1-3")

    b2_1 = a2.books.create(title: "Book 2-1")
    b2_2 = a2.books.create(title: "Book 2-2")

    r = Reader.create(name: 'Reader')
    r.books.push b1_1
    r.books.push b1_3
    r.books.push b2_2
  end
end

class Riot::Context
  def app(app=nil,&block)
    setup { @app = (app | block.call) }
  end
end
