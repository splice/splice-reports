$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "splice_reports/version"


# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "splice_reports"
  s.version     = SpliceReports::VERSION
  s.authors     = ["whayutin"]
  s.email       = ["whayutin@redhat.com"]
  s.homepage    = "https://github.com/splice/splice-reports"
  s.summary     = "Summary of SpliceReports."
  s.description = "Description of SpliceReports."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # s.add_dependency "jquery-rails"
  s.add_dependency "mongo"
  s.add_dependency "bson_ext"
  s.add_dependency "mongo_mapper"

  s.add_development_dependency "sqlite3"

end
