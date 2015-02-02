require 'mustache'
require 'sqlite3'
require 'pry'

class Surfing
  def initialize
    @db = SQLite3::Database.new "data/surfing.sqlite3"
    @db.results_as_hash = true
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.get? && request.path == '/'
      @journal_entries = @db.execute "SELECT * FROM journal_entries"
      binding.pry
      @data = {'journal_entries' => journal_entries_truncated}
      render :index_truncated
    elsif request.get? && request.path == '/show_journal_entry'
      entry =  @journal_entries.select {|entry| entry['id'].to_s == request.params['id']}
      @data = {'journal_entry' => entry}
      render :show
    elsif request.post? && request.path == '/create_journal_entry'
      new_entry = {id: @journal_entries.size + 1, title: request.params['title'], content: request.params['content']}
      @journal_entries.unshift(new_entry)
      redirect_to '/'
    else
      Rack::File.new('documents').call(env)
    end
  end

  def render(template_name)
    content = Mustache.render(File.read("templates/#{template_name}.mustache"), @data)
    [200, {}, [content]]
  end

  def redirect_to(path)
    [302, {"Location" => "#{path}"}, []]
  end

  def journal_entries_truncated
    @journal_entries.map do |entry|
      if entry['content'].size > 200
        content = entry['content'].slice(0..199) + " ..."
      else
        content = entry['content']
      end
      {id: entry['id'], title: entry['title'], content: content}
    end
  end

  def journal_entries
    @journal_entries
  end
end

