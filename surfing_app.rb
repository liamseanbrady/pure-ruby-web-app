require 'mustache'
require 'yaml'

class Surfing
  def initialize
    persisted_data = File.open('data/journal_entries.yaml') { |f| f.read }
    @journal_entries = YAML.load(persisted_data)
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.get? && request.path == '/'
      render("index_truncated", {'journal_entries' => journal_entries_truncated})
    elsif request.get? && request.path == '/show_journal_entry'
      entry =  @journal_entries.select {|entry| entry[:id].to_s == request.params['id']}
      render("show", {'journal_entry' => entry})
    elsif request.post? && request.path == '/create_journal_entry'
      new_entry = {id: @journal_entries.size + 1, title: request.params['title'], content: request.params['content']}
      @journal_entries.unshift(new_entry)
      redirect_to '/'
    else
      Rack::File.new('documents').call(env)
    end
  end

  def render(template_name, data)
    content = Mustache.render(File.read("templates/#{template_name}.mustache"), data)
    [200, {}, [content]]
  end

  def redirect_to(path)
    [302, {"Location" => "#{path}"}, []]
  end

  def journal_entries_truncated
    @journal_entries.map do |entry|
      if entry[:content].size > 200
        content = entry[:content].slice(0..199) + " ..."
      else
        content = entry[:content]
      end
      {id: entry[:id], title: entry[:title], content: content}
    end
  end

  def journal_entries
    @journal_entries
  end
end

