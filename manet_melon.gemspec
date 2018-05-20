Gem::Specification.new do |s|
  s.name = %q{manet_melon}
  s.version = "0.0.1"
  s.authors = ["Justin Collins"]
  s.summary = "Prototype implementation of the MELON communication paradigm."
  s.description = "Prototype implementation of the MELON communication paradigm for MANETs."
  s.homepage = ""
  s.files = ["README.md"] + Dir["lib/**/*.rb"]
  s.license = "MIT"
  s.add_dependency "dumb_numb_set", "~>1.0"
  s.add_dependency "rwlock", "~>1.0"
end
