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
      user_id = request.cookies['user_id']
      return [302, {"Location" => "/sign_in.html"}, []] unless user_id

      @journal_entries = @db.execute "SELECT * FROM journal_entries"
      @data = {'journal_entries' => journal_entries_truncated}
      render :index_truncated
    elsif request.get? && request.path == '/show_journal_entry'
      entry = @db.execute("SELECT * FROM journal_entries WHERE id = ?", request.params['id'])
      @data = {'journal_entry' => entry}
      render :show
    elsif request.post? && request.path == '/create_journal_entry'
      time_now = friendly_time(Time.now)
      id = (@db.execute("SELECT MAX(id) AS max FROM journal_entries").first['max'] + 1)
      @db.execute("INSERT INTO journal_entries (id, title, content, created_at) VALUES (?, ?, ?, ?)", [id, request.params['title'], request.params['content'], time_now])
      redirect_to '/'
    elsif request.get? && request.path == '/edit_journal_entry'
      entry = @db.execute("SELECT * FROM journal_entries WHERE id = ?", request.params['id']).first
      @data = {'journal_entry' => entry}
      render :edit
    elsif request.post? && request.path == '/update_journal_entry'
      id, title, content = request.params["id"], request.params["title"], request.params["content"]
      @db.execute "UPDATE journal_entries SET title='#{title}', content='#{content}' WHERE id=#{id}"
      redirect_to "/show_journal_entry?id=#{id}"
    elsif request.post? && request.path == '/delete_journal_entry'
      id = request.params["id"]
      @db.execute "DELETE FROM journal_entries WHERE id=#{id}"
      redirect_to '/'
    elsif request.post? && request.path == '/create_user'
      name, username, password, created_at = request.params['name'], request.params['username'], request.params['password'], friendly_time(Time.now)
      @db.execute("INSERT INTO users (name, username, password, created_at) VALUES (?, ?, ?, ?)", [name, username, password, created_at])
      redirect_to '/'
    elsif request.post? && request.path == '/sign_in'
      username, password = request.params['username'], request.params['password']
      result = @db.execute("SELECT * FROM users WHERE username=? AND password=?", [username, password]).first
      binding.pry
      if result.any?
        [302, {"Set-Cookie" => "user_id=#{result['id']}", "Location" => "/"}, []]
      else
        [401, {}, ['Access Denied']]
      end
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

  def friendly_time(time_obj)
    time_obj.to_s.slice(0...-6)
  end
end

