require 'active_triples'

class Collection
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/collection/', type: 'http://example.org/ns/Collection'

  property :name, predicate: RDF::DC.title
  property :members, predicate: RDF::DC.hasPart
end
