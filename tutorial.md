RDF.rb Tutorial
================

Install Ruby
------------

See the official Ruby [install instructions](https://www.ruby-lang.org/en/documentation/installation/).

You'll want to install the Ruby language,
[RubyGems](https://rubygems.org/pages/download), and [Bundler](http://bundler.io).
Once you have RubyGems, you can install Bundler with `gem install bundler`.

### Try a Console Session

```sh
$ irb
irb(main):001:0> puts 'Hello World!'
Hello World!
=> nil
```

Getting Started
---------------

Create a directory for the tutorial (`mkdir swib-ruby`), and create a `Gemfile` there.

```ruby
# ./Gemfile
source 'https://rubygems.org'

gem 'rdf'
```

A [Gemfile](http://bundler.io/gemfile.html) is a Ruby source file specifying a
set of dependencies. Once we have a Gemfile, we can do `bundle install` to install
them. Now we can do `bundle console` to get a REPL (IRB) session with our
dependencies available. In an application, use `require 'bundler/setup'`.

```ruby
# examples/hello.rb
require 'rdf'
# => true

graph = RDF::Graph.new

graph << RDF::Statement(RDF::Node('hello'),
                        RDF::URI('http://example.org/message'),
                        "Hello World!")
puts graph.dump(:ntriples)
# _:hello <http://example.org/message> "Hello World!" .
# => nil
```

What is going on here? Let's take it line-by-line.

`require 'rdf'` loads the core of RDF.rb from the `rdf` gem. Note that `require`
is a method on the `Kernel` module (try `Kernel.methods` and
`Kernel.methods.include?(:require)`); like (__almost__) everything in Ruby, it
returns a value (`true` on success). Also try `Kernel.class` and
`Kernel.class.class`.

`graph = RDF::Graph.new` declares a variable `graph`, and sets it to a value.
`RDF::Graph` is a class in the `RDF` module, and its __class method__ `.new`
creates an instance. If we do `graph.class` we should get `# => RDF::Graph`. (See _Aside About Classes_, below).

`graph << RDF::Statement(RDF::Node('hello'),`; there is a lot to say about this
line! First we call an __instance method__ `RDF::Graph#<<` on `graph`, and pass
it a value. The value we pass is an instance of `RDF::Statement`, but we're
playing a trick here because `RDF.Statement` is an alias for
`RDF::Statement.new`, which [takes three arguments](http://rdf.greggkellogg.net/yard/RDF/Statement.html#initialize-instance_method),
for subject, predicate, and object. So `RDF::Statement(s,p,o)` is the same as
`RDF::Statement.new(s,p,o)`. `RDF::Node('hello')` defines a blank node with an
`#id` of "hello" (we'll say more about blank nodes later). A `Symbol` like
`:hello` could also be used to represent a blank node, with the same results.

`RDF::URI('http://example.org/message'),` is really a continuation of the
previous line. It creates an instance of `RDF::URI` with the `#value` of the
URI string passed in.

`"Hello World!")` continues with a `String` and closes the arguments for
`Statement`. `RDF::Statement.new` will interpret the `String` as an
`RDF::Literal`; try also:

```ruby
  st = RDF::Statement(:node, RDF.type, 'moomin')
  st.subject # => #<RDF::Node:0x2afdf04bd9e4(_:node)>
  st.predicate # => #<RDF::Vocabulary::Term:0x2afdf046bd88 URI:http://www.w3.org/1999/02/22-rdf-syntax-ns#type>
  st.object # => #<RDF::Literal:0x2afdeff836cc("moomin")>
```

### Hello Turtle

```ruby
require 'rdf/turtle'

puts graph.dump :ttl

graph.insert(RDF::Statement(:hello, RDF.type, RDF::URI('http://example.org/Message')),
             RDF::Statement(:hello, RDF::URI('http://example.org/next'), :goodbye))

puts graph.dump :ttl
```

### An Aside About Classes
Try creating your own class with:

```ruby
class HelloSayer
  def say
    'Hello World!'
  end
end
# => :say
# yes, that's `Kernel.class` returning a value (naming the last method defined)!

sayer = HelloSayer.new
sayer.say # => "Hello World!"
```

Classes are open for modification! Continuing from above:

```ruby
class HelloSayer
  def initialize(target = 'world')
    @target = target
  end

  def say
    "Hello #{@target.capitalize}!"
  end
end

# `sayer` is still using the original code.
sayer # => #<HelloSayer:0x0055b672d97208>
sayer.say # => "Hello World!"
HelloSayer.new('SWIB').say # => "Hello Swib!"

HelloSayer.new('SWIB') # => #<HelloSayer:0x0055b672a5c4f8 @target="SWIB">
```

*Note*: documentation written for Ruby usually uses `.method_name` and
`::method_name` to reference __class methods__, and `#method_name` to reference
__instance methods__. `#say` and `#initialize` are __instance methods__`, while
`.new` is a __class method__.

RDF.rb Overview
---------------

### [RDF Object Model](http://blog.datagraph.org/2010/03/rdf-for-ruby)

* [RDF::Value](http://rdf.greggkellogg.net/yard/RDF/Value.html)
  * [RDF::Graph](http://rdf.greggkellogg.net/yard/RDF/Graph.html)
  * [RDF::Statement](http://rdf.greggkellogg.net/yard/RDF/Statement.html)
  * [RDF::Term](http://rdf.greggkellogg.net/yard/RDF/Term.html)
    * [RDF::Resource](http://rdf.greggkellogg.net/yard/RDF/Resource.html)
      * [RDF::URI](http://rdf.greggkellogg.net/yard/RDF/URI.html)
      * [RDF::Node](http://rdf.greggkellogg.net/yard/RDF/Node.html)
    * [RDF::Literal](http://rdf.greggkellogg.net/yard/RDF/Literal.html)
      * [RDF::Literal::Boolean](http://rdf.greggkellogg.net/yard/RDF/Literal/Boolean.html)
      * [RDF::Literal::Date](http://rdf.greggkellogg.net/yard/RDF/Literal/Date.html)
      * [RDF::Literal::DateTime](http://rdf.greggkellogg.net/yard/RDF/Literal/DateTime.html)
      * [RDF::Literal::Decimal](http://rdf.greggkellogg.net/yard/RDF/Literal/Decimal.html)
      * [RDF::Literal::Double](http://rdf.greggkellogg.net/yard/RDF/Literal/Double.html)
      * [RDF::Literal::Integer](http://rdf.greggkellogg.net/yard/RDF/Literal/Integer.html)
      * [RDF::Literal::Time](http://rdf.greggkellogg.net/yard/RDF/Literal/Time.html)
  * [RDF::List](http://rdf.greggkellogg.net/yard/RDF/List.html)

### Mixins

* [RDF::Countable](http://rdf.greggkellogg.net/yard/RDF/Countable.html)
* [RDF::Enumerable](http://rdf.greggkellogg.net/yard/RDF/Enumerable.html)
* [RDF::Durable](http://rdf.greggkellogg.net/yard/RDF/Durable.html)
* [RDF::Mutable](http://rdf.greggkellogg.net/yard/RDF/Mutable.html)
* [RDF::Queryable](http://rdf.greggkellogg.net/yard/RDF/Queryable.html)
* [RDF::Readable](http://rdf.greggkellogg.net/yard/RDF/Readable.html)
* [RDF::Writable](http://rdf.greggkellogg.net/yard/RDF/Writable.html)

`RDF::Graph` includes Countable, Durable, Enumerable, Mutable, & Queryable.

RDF Term Equality
-----------------



Beyond Hello World
------------------

### Formats

The base `rdf` library supports NTriples & NQuads. The `linkeddata` gem packages
support a wide range of other formats (along with some other features like SPARQL
and graph isomorphism). You can get an enumerable of supported formats in your
current environment with `RDF::Format.each`, e.g.:

```ruby
require 'linkeddata'

RDF::Format.each { |klass| puts "#{klass} => #{klass.content_type}" }
# RDF::NTriples::Format => ["application/n-triples", "text/plain"]
# RDF::NQuads::Format => ["application/n-quads", "text/x-nquads"]
# JSON::LD::Format => ["application/ld+json", "application/x-ld+json"]
# RDF::JSON::Format => ["application/rdf+json"]
# RDF::RDFa::Format => ["text/html"]
# RDF::RDFa::Lite => ["text/html"]
# RDF::RDFa::HTML => ["text/html"]
# RDF::RDFa::XHTML => ["application/xhtml+xml"]
# RDF::RDFa::SVG => ["image/svg+xml"]
# RDF::Microdata::Format => []
# RDF::N3::Format => ["text/n3", "text/rdf+n3", "application/rdf+n3"]
# RDF::N3::Notation3 => ["text/n3"]
# RDF::RDFXML::Format => ["application/rdf+xml"]
# RDF::RDFXML::RDFFormat => ["application/rdf+xml"]
# RDF::Tabular::Format => ["text/csv", "text/tab-separated-values", "application/csvm+json"]
# RDF::Turtle::Format => ["text/turtle", "text/rdf+turtle", "application/turtle", "application/x-turtle"]
# RDF::Turtle::TTL => ["text/turtle"]
# RDF::TriG::Format => ["application/trig", "application/x-trig"]
# RDF::TriX::Format => ["application/trix"]
# RDF::YodaTriples::Format => ["application/y-triples", "text/plain", "application/prs.yoda-triples", "application/prs.y-triples"]

# These have similar utility
RDF::Format.content_types # => {"application/n-triples"=>[RDF::NTriples::Format], ... }
RDF::Format.file_extensions # => {:nt=>[RDF::NTriples::Format], ... }
```

Formats come with a `Reader` and a `Writer`. Let's parse some data.

```ruby
hamburg = RDF::Graph.new << RDF::Reader.open('./examples/hamburg.ttl')
hamburg.count # => 4964
```

That was easy. We can also stream readers into a block; this is a common Ruby IO
interface.

```ruby
ham = RDF::Graph.new

RDF::Reader.open('./examples/hamburg.ttl') do |reader|
  reader.each_statement do |st|
    ham << st unless st.predicate == RDF::URI('http://www.w3.org/2002/07/owl#sameAs')
  end
end

ham.count # => 4940
ham.has_predicate? RDF::URI('http://www.w3.org/2002/07/owl#sameAs')
# => false
```

Writers work similarly.

```ruby
RDF::Writer.open('./examples/hamburg.yt') { |writer| writer << hamburg }

trix = RDF::Writer.for(:trix) do |writer|
  hamburg.each_statement { |st| writer << st }
end
```

We can load graphs from a source with:

```ruby
from_file = RDF::Graph.new
from_file.load('./examples/hamburg.ttl')
from_file.count # => 4964

from_url = RDF::Graph.new
from_url.load('http://dbpedia.org/resource/Hamburg')
from_url.count # => 4964
```

### Vocabularies

Vocabularies provide convenient access to commonly used URIs, as an
`RDF::Vocabulary::Term` (which implements the `RDF::URI` interface). They can
be defined based on `Vocabulary` or `StrictVocabulary`. If a vocabulary is
defined strictly it enforces membership of its terms, protecting from simple
mistakes.

```ruby
RDF.type
# => #<RDF::Vocabulary::Term:0x2abb64fb1450 URI:http://www.w3.org/1999/02/22-rdf-syntax-ns#type>

RDF.type == RDF::URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
# => true
RDF.type == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
# => true

RDF::Vocab::DC.title
# => #<RDF::Vocabulary::Term:0x2abb670ea7c0 URI:http://purl.org/dc/terms/title>
RDF::Vocab::DC.description
# => #<RDF::Vocabulary::Term:0x2abb670ea7c0 URI:http://purl.org/dc/terms/description>

 RDF::Vocab::DC.moomin
 # NoMethodError: undefined method `moomin' for RDF::StrictVocabulary(http://purl.org/dc/terms/):Class

RDF::Vocab::DC.properties # => [#<RDF::Vocabulary::Term:0x2abb64fe8f04 URI:http://www.w3.org/1999/02/22-rdf-syntax-ns#Alt>, ... ]
```

Vocabularies are useful for easily and safely using URIs.

```ruby
g = RDF::Graph.new
g << [:moomin, RDF::Vocab::DC.title, 'moomin']
```

The following vocabularies are pre-defined in the core library; other
vocabularies are defined in the `rdf-vocab` gem:

  * `RDF` - Resource Description Framework (RDF)
  * `RDF::OWL` - Web Ontology Language (OWL)
  * `RDF::RDFS` - RDF Schema (RDFS)
  * `RDF::XSD` - XML Schema (XSD)

You can define an ad-hoc vocabulary with, e.g.:

```ruby
foaf = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
foaf.knows    #=> RDF::URI("http://xmlns.com/foaf/0.1/knows")
foaf[:name]   #=> RDF::URI("http://xmlns.com/foaf/0.1/name")
foaf['mbox']  #=> RDF::URI("http://xmlns.com/foaf/0.1/mbox")
```

[`RDF::Vocabulary::Term`](http://rdf.greggkellogg.net/yard/RDF/Vocabulary/Term.html) captures some additional information about the term which is used by the `rdf-reasoner` gem, and can be handy in other cases, as well.

```ruby
RDF::Vocab::DC.title.range
# => [#<RDF::Vocabulary::Term:0x2abb6621b988 URI:http://www.w3.org/2000/01/rdf-schema#Literal>]

RDF::Vocab::DC.title.subPropertyOf
# => [#<RDF::Vocabulary::Term:0x2abb67296c04 URI:http://purl.org/dc/elements/1.1/title>]
```

### Basic Graph Patterns

The core library implements Basic Graph Pattern queries:

```ruby
query = RDF::Query.new do
  pattern [:city, RDF.type, RDF::Vocab::SCHEMA.City]
  pattern [:city, RDF::Vocab::FOAF.name, :name]
end

hamburg = RDF::Graph.load('./examples/hamburg.ttl')

query.execute(hamburg)
# => [#<RDF::Query::Solution:0x2aaedb9cc214({:city=>#<RDF::URI:0x2aaedd6480a0 URI:http://dbpedia.org/resource/Hamburg>, :name=>#<RDF::Literal:0x2aaedd15ddec("Freie und Hansestadt Hamburg"@en)>})>]

query.solutions.count # => 1

query.solutions.first.name
# => #<RDF::Literal:0x2aaedd15ddec("Freie und Hansestadt Hamburg"@en)>

query.solutions.map(&:city)
# => [#<RDF::URI:0x2aaedd6480a0 URI:http://dbpedia.org/resource/Hamburg>]

query.solutions.map(&:name)
# => [#<RDF::Literal:0x2aaedd15ddec("Freie und Hansestadt Hamburg"@en)>]
```

To construct and run a query all at once, do:

```ruby
solutions = RDF::Query.execute(hamburg) do
  pattern [:thing, RDF.type, :type]
end

solutions.each { |solution| puts "#{solution.thing} -- #{solution.type}" }
```

You can also run simple statement queries directly on any `RDF::Queryable`
object to return a list of matching statements:

```ruby
hamburg = RDF::Graph.load('./examples/hamburg.ttl')

statements = hamburg.query([RDF::URI('http://dbpedia.org/resource/Hamburg'),
                            RDF.type,
                            :type])

statements.subjects
statements.predicates
statements.objects
```

Repository/Dataset
------------------

`RDF::Graph` is secretly powered by an in-memory datastore called
`RDF::Repository`. This is both a fast, transient store for any data that fits
in memory, and a generic interface for persistent repositories. You can access
the underlying repository directly with `Graph#data`

```ruby
repo = hamburg.data
# => #<RDF::Repository:0x2aaedd4ef834()>

repo.persistent? # => false
```

Repositories, like `Graphs` are `RDF::Enumerable`, `RDF::Writable`,
`RDF::Readable`, and `RDF::Queryable`, so they share much of the same interface.
You can interact with a repository directly with

```ruby
repo = RDF::Repository.new

```

### Named Graphs

Some Repository implementations support named graphs; you can check support for
with `RDF::Repository.new.supports?(:graph_name)`.

```ruby
repo = RDF::Repository.new
repo.persistent? # => false

moomin = RDF::Graph.new('http://ex.org/moomin', data: repo)
snork  = RDF::Graph.new('http://ex.org/snork',  data: repo)

moomin.load 'http://dbpedia.org/resource/Moomin'
snork.load  'http://dbpedia.org/resource/Snork'

repo.graph_names
# => [#<RDF::URI:0x2abdd739a804 URI:http://ex.org/moomin>,
#     #<RDF::URI:0x2abdd73b48f8 URI:http://ex.org/snork>]

repo.dump :nquads
```

SPARQL
------

The `sparql` gem comes with a full implementation of the SPARQL 1.1 Query
and UPDATE standards. It also ships a set of `Rack` middleware for embedding
SPARQL servers in other applications.

### Setting up a Server

You can stand up a SPARQL server from the command line with `sparql server`.

```sh
bundle exec sparql server --dataset examples/hamburg.ttl
```

The server should now be running on `http://localhost:8080`

### SPARQL Query Client

`sparql-client` implements a client and query DSL. Let's use it to query our
server.

```ruby
sparql = SPARQL::Client.new('http://localhost:8080')
q = sparql.select.where([:s, :p, :o]).limit(100)

q.execute
```

You can also use a `SPARQL::Client` to query a `Repository`.

```ruby
sparql = SPARQL::Client.new(repository)
# ...
```

ActiveTriples
-------------

See [active_triples.md](active_triples.md).

Extras
------

* `Rack::LinkedData`
* `Rack::SPARQL`
* `RDF::Isomorphic`
* `RDF::Reasoner`
* `RDF::LDP`
* ???
