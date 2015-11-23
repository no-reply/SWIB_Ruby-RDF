require 'active_triples'

class Place
  include ActiveTriples::RDFSource
  configure base_uri: 'http://sws.geonames.org/', type: 'http://example.org/ns/Place'

  property :name, predicate: RDF::URI('http://www.geonames.org/ontology#name')
  property :lat, predicate: RDF::GEO.lat
  property :long, predicate: RDF::GEO.long
  property :parentFeature, predicate: RDF::URI('http://www.geonames.org/ontology#parentFeature')
  property :parentCountry, predicate: RDF::URI('http://www.geonames.org/ontology#parentCountry')
end
