require 'active_triples'

class CHO
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/resource', type: 'http://example.org/ns/CHO'

  property :title, predicate: RDF::Vocab::DC.title
  property :creator, predicate: RDF::DC.creator
  property :date, predicate: RDF::DC.date
end
