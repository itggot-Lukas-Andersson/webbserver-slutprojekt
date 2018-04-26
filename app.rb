require 'sinatra'
require 'sqlite3'

get('/') do
	db = SQLite3::Database.new("./db/forum.db")
    all = db.execute('SELECT * FROM post ORDER BY id DESC LIMIT 5')
	erb(:index, locals:{posts:all})
end

get('/view/:id') do
	db = SQLite3::Database.new("./db/forum.db")
	id = params[:id]
    post = db.execute('SELECT * FROM post WHERE id IS ' + id)
    comments = db.execute('SELECT * FROM comment WHERE post IS ' + id)
	erb(:view, locals:{posts:post, comments:comments})
end

get('/hot') do
	db = SQLite3::Database.new("./db/forum.db")
	all = db.execute('SELECT * FROM post ORDER BY points DESC LIMIT 5')
	erb(:index, locals:{posts:all})
end

get('/title') do
	db = SQLite3::Database.new("./db/forum.db")
	all = db.execute('SELECT * FROM post ORDER BY title COLLATE NOCASE LIMIT 5')
	erb(:index, locals:{posts:all})	
end

get('/login') do
    erb(:login)
end

get('/create') do
    erb(:create)
end
