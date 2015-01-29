require 'rack'
require './surfing_app'

surfing_app = Surfing.new
run surfing_app

at_exit do
  data = YAML.dump(surfing_app.journal_entries)
  File.open("data/journal_entries.yaml", 'w') do |file|
    file.write(data)
  end
end