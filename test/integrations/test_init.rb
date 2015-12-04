require 'rack/test'
require 'riot'
require 'riot/rr'

Riot.pretty_dots

class Riot::Situation
  include Rack::Test::Methods

  def create_data!
    Book.delete_all!
    Author.delete_all!


  end
end

class Riot::Context
  def app(app=nil,&block)
    setup { @app = (app | block.call) }
  end
end
