Gem::Specification.new do |s|
  s.name        = 'mvndownload'
  s.version     = '0.0.1'
  s.date        = '2014-10-07'
  s.summary     = "Gem to download files from maven type repositories"
  s.description = "This gem allows you to download a file.  However, it will also check to see if a MD5 file exists at the source and compare against the destination for validation"
  s.authors     = ["Nigel Foucha", "Agustin Caraballo"]
  s.email       = 'nigel.foucha@gmail.com'
  s.files       = ["lib/mvndownload.rb"]
  s.homepage    = 'http://rubygems.org/gems/mvndownload'
  s.license     = 'MIT'
end