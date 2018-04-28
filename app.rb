require_relative './module/module'

class App < Sinatra::Base

	enable :sessions
	include ForumDB

	def set_error(error_message)
		session[:error] = error_message
	end

	def get_error()
		error = session[:error]
		session[:error] = nil
		return error
	end

	get('/') do
		erb(:index)
	end

	get('/create') do
		erb(:create)
	end

	get('/view/:id') do
		db = db_connect()
		id = params[:id]
		post = db.execute('SELECT * FROM post WHERE id IS ' + id)
		comments = db.execute('SELECT * FROM comment WHERE post IS ' + id)
		erb(:view, locals:{posts:post, comments:comments})
	end

	get('/hot') do
		user_id = session[:user_id] 
		if user_id
			db = db_connect()
			all = db.execute('SELECT * FROM post ORDER BY points DESC LIMIT 5')
			erb(:home, locals:{posts:all})
		else
			redirect('/')
		end
	end

	get('/title') do
		user_id = session[:user_id] 
		if user_id
			db = db_connect()
		all = db.execute('SELECT * FROM post ORDER BY title COLLATE NOCASE LIMIT 5')
		erb(:home, locals:{posts:all})	
		else
			redirect('/')
		end
	end

	get('/home') do
		user_id = session[:user_id] 
		if user_id
			db = db_connect()
			all = db.execute('SELECT * FROM post ORDER BY id DESC LIMIT 5')
			erb(:home, locals:{posts:all})
		else
			redirect('/')
		end
	end

	get('/notes') do
		user_id = session[:user_id] 
		if user_id
			notes = list_notes(user_id)
			slim(:list_notes, locals:{notes:notes})
		else
			redirect('/')
		end
	end

	post('/create') do
		username = params["username"]
		password = params["password"]
		password_confirmation = params["confirm_password"]

		userid = get_user(username)

		if userid.nil?
			if password == password_confirmation
				create_user(username, password)
				redirect('/')
			else
				set_error("Passwords not matching")
				redirect('/error')
			end
		else
			set_error("Username taken")
			redirect('/error')
		end	
	end


	get('/error') do
		erb(:error)
	end

	post('/login') do
		username = params["username"]
		password = params["password"]
		
		user = get_user(username)

		if user.nil?
			set_error("Not matching")
			redirect('/error')
		end
		user_id = user["id"]
		password_digest = user["password_digest"]
		
		if BCrypt::Password.new(password_digest) == password
			session[:user_id] = user_id
			redirect('/home')
		else
			set_error("Not matching")
			redirect('/error')
		end
	end

	post('/logout') do
		session.destroy
		redirect('/')
	end
	
end