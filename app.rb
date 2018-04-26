require 'sinatra'
require 'sqlite3'

get('/') do
	db = SQLite3::Database.new("./db/forum.db")
	all = db.execute('SELECT * FROM posts ORDER BY id DESC LIMIT 5')
	erb(:index, locals:{posts:all})
end

get('/view/:id') do
	db = SQLite3::Database.new("./db/forum.db")
	id = params[:id]
	post = db.execute('SELECT * FROM posts WHERE id IS ' + id)
	erb(:view, locals:{posts:post})
end

get('/hot') do
	db = SQLite3::Database.new("./db/forum.db")
	all = db.execute('SELECT * FROM posts ORDER BY points DESC LIMIT 5')
	erb(:index, locals:{posts:all})
end

get('/title') do
	db = SQLite3::Database.new("./db/forum.db")
	all = db.execute('SELECT * FROM posts ORDER BY title COLLATE NOCASE LIMIT 5')
	erb(:index, locals:{posts:all})	
end



