# My First Resource
# ==================

#
# $ mkdir at-tutorial
# $ cd at-tutorial
#
# $ echo "source 'http://rubygems.org'" > Gemfile
# $ echo "gem 'active-triples'" > Gemfile
#
# $ bundle install
#
# $ mkdir -p lib/models
#
# create cho.rb as below in lib/models/

require 'active_triples'

class CHO
 
  property :title, predicate: RDF::DC.title
end

#
# $ bundle console

require './lib/models/cho'

cho = CHO.new('http://example.org/resources/1')
cho.title = 'my cultural heritage object'

cho.dump :ntriples
# => "<http://example.org/resources/1> <http://purl.org/dc/terms/title> \"my cultural heritage object\" .\n"

# your Resource object is a an RDF::Graph scoped specifically to your data. You can operate on it directly,
# adding statements with `<<`, `query`, and `delete`, call other Graph methods, and use `dump` to serialize
# in any RDF format.

require 'linkeddata'
cho.dump :ttl
# => "\n<http://example.org/resources/1> <http://purl.org/dc/terms/title> \"my cultural heritage object\" .\n"

#
# Adding a base_uri
# -----------------

# exit your ruby console and
# edit lib/models/cho.rb as follows:

class CHO
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/resource'

  property :title, predicate: RDF::DC.title
end

# $ bundle console
require './lib/models/cho'

cho = CHO.new('1')
cho.rdf_subject
# => #<RDF::URI:0x3f8326f14224 URI:http://example.org/resource/1>

#
# Adding an RDF::type
# -------------------

# exit your ruby console and
# edit lib/models/cho.rb as follows:

class CHO
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/resource', type: 'http://example.org/ns/CHO'

  property :title, predicate: RDF::DC.title
end

# $ bundle console
require './lib/models/cho'

cho = CHO.new('1')
cho.type
# => [#<RDF::URI:0x3f8326f8ae60 URI:http://example.org/ns/CHO>]

cho.dump :ntriples
# => "<http://example.org/resource/1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/ns/CHO> .\n"

#
# Adding additional properties
# ----------------------------

# exit your ruby console and
# edit lib/models/cho.rb as follows:

class CHO
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/resource/', type: 'http://example.org/ns/CHO'

  property :title, predicate: RDF::DC.title
  property :creator, predicate: RDF::DC.creator
  property :date, predicate: RDF::DC.date
end

# $ bundle console
require './lib/models/cho'

cho = CHO.new('1')
cho.title = 'My Resource'
cho.creator = 'Me'
cho.date = DateTime.now

puts cho.dump :ntriples
# <http://example.org/resource/1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/ns/CHO> .
# <http://example.org/resource/1> <http://purl.org/dc/terms/title> "My Resource" .
# <http://example.org/resource/1> <http://purl.org/dc/terms/creator> "Me" .
# <http://example.org/resource/1> <http://purl.org/dc/terms/date> "2014-09-11T14:34:28-07:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
# => nil

# Note that the `date` property is encoded as a typed literal.
# When typed data is passed to a property, ActiveTriples serialises it correctly
# and returns the appropriate datatype when accessed. This is handled through
# RDF.rb's Literal class.
#
# For more about typed literals in RDF.rb, see: http://rdf.greggkellogg.net/yard/RDF/Literal.html
# For more about data types in RDF in general, see: http://www.w3.org/TR/rdf11-concepts/#section-Graph-Literal

cho.date
# => [Thu, 11 Sep 2014 14:34:28 -0700]


#
# Defining a Domain Model
# =======================

#
# First Relationship
# ------------------

# create models.rb as below in lib/

'linkeddata'

Dir["./lib/models/*.rb"].each {|file| require file }

# create collection.rb as below in lib/models/

class Collection
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/collection/', type: 'http://example.org/ns/Collection'

  property :name, predicate: RDF::DC.title
  property :members, predicate: RDF::DC.hasPart
end

# $ bundle console

require './lib/models'

coll = Collection.new('1')
coll.name = 'SWIB Connect Photos'
coll.members = CHO.new('abc')

puts coll.dump :ttl

# <http://example.org/collection/1> a <http://example.org/ns/Collection>;
#    <http://purl.org/dc/terms/title> "Hydra Connect Photos";
#    <http://purl.org/dc/terms/hasPart> <http://example.org/resource/abc> .
#
# <http://example.org/resource/abc> a <http://example.org/ns/CHO> .
# => nil

coll.members
# => [#<CHO:0x3f9f7120ba84(default)>

coll.members.first.title = 'Rock & Roll Hall of Fame'

puts coll.dump :ttl
# <http://example.org/collection/1> a <http://example.org/ns/Collection>;
#    <http://purl.org/dc/terms/title> "Hydra Connect Photos";
#    <http://purl.org/dc/terms/hasPart> <http://example.org/resource/abc> .

# <http://example.org/resource/abc> a <http://example.org/ns/CHO>;
#    <http://purl.org/dc/terms/title> "Rock & Roll Hall of Fame" .
# => nil

# Resource objects loaded from the graph will build in the class associated with
# their rdf:type. But what happens if no type is given?

coll.members << ActiveTriples::Resource.new('http://example.org/noType/1')

coll.members
# => [#<CHO:0x3f9f7120ba84(default)>, #<ActiveTriples::Resource:0x3f9f710314d4(default)>]

#
# Expanding the Domain Model with Agents and Places
# -------------------------------------------------

# create agent.rb as below in lib/models/

class Agent
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/agent/', type: 'http://example.org/ns/Agent'

  property :name, predicate: RDF::FOAF.name
end

# create place.rb as below in lib/models/

class Place
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/place/', type: 'http://example.org/ns/Place'

  property :name, predicate: RDF::URI('http://www.geonames.org/ontology#name')
  property :lat, predicate: RDF::GEO.lat
  property :long, predicate: RDF::GEO.long
end

# update lib/models/cho.rb as below:

class CHO
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/resource/', type: 'http://example.org/ns/CHO'

  property :title, predicate: RDF::DC.title
  property :creator, predicate: RDF::DC.creator
  property :date, predicate: RDF::DC.date
  property :location, predicate: RDF::DC.spatial
end

#
# Using External Data
# -------------------

# update place.rb as follows

class Place
  include ActiveTriples::RDFSource
  configure base_uri: 'http://sws.geonames.org/', type: 'http://example.org/ns/Place'

  property :name, predicate: RDF::URI('http://www.geonames.org/ontology#name')
  property :lat, predicate: RDF::GEO.lat
  property :long, predicate: RDF::GEO.long
  property :parentFeature, predicate: RDF::URI('http://www.geonames.org/ontology#parentFeature')
  property :parentCountry, predicate: RDF::URI('http://www.geonames.org/ontology#parentCountry')
end

# $ bundle console

require './lib/models'

cw = Place.new('5149374/')
cw.fetch

cw.name
# => ["Case Western Reserve University"]
cw.lat
# => ["41.5045"]
cw.long
# => ["-81.59707"]

cw.parentFeature.first.fetch
cw.parentFeature.first.name
# => ["Cuyahoga County"]
cw.parentFeature.first.parentFeature.first.fetch
# => #<Place:0x3fdfd736ef9c(default)>
cw.parentFeature.first.parentFeature.first.name
# => ["Ohio"]
# ...and so on.]
