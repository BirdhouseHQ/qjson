qJSON
==========
## WIP!
Note: qJSON is under active development, and is not ready for use in production.
Specifically, there is currently no caching of serializers and the structure is
likely to change due to feedback.

### Introduction

A quick JSON serialization gem with versioning baked in deep.

Another JSON-ifying gem?  Really?  Yep, and here's why.  There are a few extremely
important things when it comes to creating an API, most of which aren't correctly
handled 'in the wild' right now.

### Versioning

Versioned APIs need two versions, semantic versions and syntactic versions.

**Semantic versions**, (say v0, v1, v2), refer to different _meanings_ behind
each call - they find differently, sort differently, update differently, etc.
This might happen when you introduce a new "browse" page, or make a new version
of an account page that allows for more complex interactions.

**Syntactic versions** (say 20150323) refer to the JSON structure of a given
model or record.  This will change more frequently, as the needs of the
application change.  Depending on the internal workings of your application,
your understanding of given objects may be uniform across your application
(ideal case), or the exact structure of each object depends on the time in which
you wrote the thing that parses out that object (actual case).  We want a
JSON-serialization scheme that allows for both of these eventualities, without
forcing either way.

Takeaway: you shouldn't add/remove fields from a versioned serialization
mechanism, doing so breaks your ability to support multiple versions of your
code in the wild.  Just copy the old one, update the version number and
add/remove fields to your hearts content.

### Speed & Interface

Most serialization gems sacrifice speed for semantic beauty.  This is a false
choice, and so this has frustrated me no end.  The basics:

- In my experience, the Rails render pipeline is unacceptably slow
- Locating JSON serializers in their own directory is a little silly,
  serializers are views, just not immediately to humans, so they belong in the
  `app/views` directory.
- Changing code in `development` mode should render the most recent file
- ENV=`production` should cache all methods for rendering JSON
- Ruby/rails hash manipulation functions are rich and well-understood way of
  interacting with data, why not just use normal ruby/rails code to manipulate
  normal ruby/rails hashes?  (I use ruby/rails here because rails provides some
  handy extensions to hash manipulation).

So, we need a gem that takes over from the templating/rendering engine and finds
the right location for the objects in question, and the view code should be
reasonable, readable ruby code (without unnecessary boilerplate) that just
renders the damn object.  The gem should handle caching these things in a way
that makes accessing them trivial and lickedy-splickety.

### Conclusion

So we need a new JSON serializer.  Damn.  So here it is.

## Usage?

It's just a gem, add `gem qjson` to your Gemfile, and `bundle install` it.

Rendering with QJson is easy:

`QJSON::render(item,context,version)`

Where `item` is the thing you want rendered, `context` is the context within
which it should be rendered, and `version` is the desired version.  QJSON will
always pick the highest version that is less than or equal to the incoming
`version`.  **versions** in qJSON can be any string, but are preferred to be
a date stamp (e.g. `20151223`), so that they look different from traditional
semantic versions like `v1`, `v2`, `v3` etc.

This is cool, because any request from the client has a semantic version and a
syntactic version.  As you improve different parts of the client, you can
increment these values separately.

You add versioned serializers in `app/views/api/<model>s/<context>.<version>.qjrb`

The `context` is the named context within which you are rendering the thing, in
general, there are two contexts, `show` (where you're looking at a comprehensive
view of the object) and `_item` (where you are looking at the item in a list of
items).  You are in charge of the naming conventions here, just make sure they
fit with normal Rails naming conventions in a way that makes sense.  An example
of a third context would be if you have two ways in which items get shown in a
list, namely list view and cover-flow view or some such, where in cover-flow view
you only need an image and a title, but in list view you need more stuff.  Each
context is individually versioned, so you don't have to worry about that!

A QJRB file looks like this, in this case a playlist object:

```ruby
association(:tracks,:list_item,this_version,{ limit: 10 })
association(:watchers,:names_and_ids,request_version,{ limit: 4 })
association_count(:watchers_count,:watchers);
# either:
attributes(:asdf,:one)
# or:
attributes_except(:tweedle_dee)
```

They are extremely simplistic, aiming to solve 80% of the cases easily.  There
is NO support for accessing derivative or model-related fields.  There is a reason
for this!  Should the model change logically, the JSON rendering will change!
In a future version of qJSON, this whole part might be written in some other
language entirely, making it so that simple API calls never touch the rails stack
at all.  Keep it simple, stupid!  Obviously, more complexity is going to be
warranted in many cases, which is why there is an "advanced mode", which
sacrifices optimizability for complexity.

## Advanced Usage

You can also create more advanced renderers that encode serialization and
deserialization.  These files have the extension `.rb` since they are just normal
ruby files.  They are evaluated in the context of a subclass of QJSON::Base.

```ruby
def to_json
  # call includes first!  This will prepare the object if necessary, saving you
  # N+1 DB hits.
  includes(:associated_record)
  h = object.as_json(only: [:field1,:field2])
  h[:other] = render(object.associated_record,:subobject,request_version)
  h    
end

# here, object is the object to assign attributes to - DO NOT SAVE!!!
# it could be a "new" object (without ID), or an existing object.  Do not
# perform validations, authorization, or anything else.  Just set values
# on the object (and associated if necessary objects), exactly the inverse of
# to_json
def from_json
  object.assign_attributes(h.slice(:field1,:field2))
  parse(object.other,h[:other],:subobject,request_version)
end
```

This project rocks and uses MIT-LICENSE.
