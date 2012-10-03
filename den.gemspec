Gem::Specification.new do |s|
  s.name = 'den'
  s.version = '0.2.0'
  s.summary = 'A really simple static-site generator.'
  s.authors = ["Peter Valdez"]
  s.email = 'peter@someindividual.com'
  s.executables << 'den'
  s.homepage = 'https://github.com/azlyth/den'
  s.files = %w[
    bin/den
    lib/den/examples.rb
    lib/den/page.rb
    lib/den/post.rb
    lib/den/resource.rb
    lib/den/template.rb
    lib/den/utilities.rb
    lib/den.rb
    den.gemspec
  ]
end
