
require 'rdf'

graph = RDF::Graph.new

graph << RDF::Statement.new(RDF::Node.new('hello'),
                            RDF::URI('http://example.org/message'),
                            "Hello World!")
puts graph.dump(:ntriples)

require 'rdf/turtle'

puts graph.dump(:ttl)
