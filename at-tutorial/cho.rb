
class CHO
  include ActiveTriples::RDFSource

  property :title, predicate: RDF::Vocab::DC.title
end
