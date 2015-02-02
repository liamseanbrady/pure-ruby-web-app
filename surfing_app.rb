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
      @data = {'journal_entries' => journal_entries_truncated}
      render :index_truncated
    elsif request.get? && request.path == '/show_journal_entry'
      entry = @db.execute("SELECT * FROM journal_entries WHERE id = ?", request.params['id'])
      @data = {'journal_entry' => entry}
      render :show
    elsif request.get? && request.path == '/edit_journal_entry'
      entry = @db.execute("SELECT * FROM journal_entries WHERE id = ?", request.params['id'])
      @data = {'journal_entry' => entry}
      render :edit
    elsif request.post? && request.path == '/create_journal_entry'
      index = @db.execute("SELECT COUNT(*) AS count FROM journal_entries").first['count'] + 1
      @db.execute("INSERT INTO journal_entries (id, title, content) VALUES (?, ?, ?)", [index, request.params['title'], request.params['content']])
      redirect_to '/'
    elsif request.post? && request.path == '/update_journal_entry'
      index = request.referer.split('=').last
      @db.execute("UPDATE journal_entries SET (title = ?, content = ? WHERE id = ?)", [request.params['title'], request.params['content'], index])
      redirect_to "/show_journal_entry?id=#{index}"
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

