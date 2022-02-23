task :import_trends, [:path] => [:environment] do |_t, args|
  TrendsImporter.run(path: args[:path])
end
