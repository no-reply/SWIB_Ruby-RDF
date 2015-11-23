require 'active_triples'

class Agent
  include ActiveTriples::RDFSource
  configure base_uri: 'http://example.org/agent/', type: 'http://example.org/ns/Agent'

  property :name, predicate: RDF::FOAF.name
end
