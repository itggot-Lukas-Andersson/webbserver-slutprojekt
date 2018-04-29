require_relative './model/model'

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
		user_id = session[:user_id] 
		if user_id
			all = get_recent()
			erb(:home, locals:{posts:all})
		else
			erb(:index)
		end
	end

	get('/create') do
		erb(:create)
	end

	get('/view/:id') do
		user_id = session[:user_id] 
		if user_id
			id = params[:id]
			post = post_info(id)
			comments = fetch_comments(id)
			fav = check_fav(user_id, id)
			erb(:view, locals:{posts:post, comments:comments, id:id, favo:fav})
		else
			redirect('/')
		end
	end

	post('/view/:id/comment') do
		user_id = session[:user_id] 
		if user_id
			content = params["content"]
			username = session[:username]
			id = params[:id]
			publish_comment(username, content, id)
			redirect('/view/' + id)

		else
			redirect('/')
		end
	end

	get('/favorites') do
		user_id = session[:user_id] 
		if user_id
			all = get_fav(user_id)
			erb(:home, locals:{posts:all})	
		else
			redirect('/')
		end
	end

	get('/title') do
		user_id = session[:user_id] 
		if user_id
			all = get_az()
			erb(:home, locals:{posts:all})	
		else
			redirect('/')
		end
	end

	get('/home') do
		user_id = session[:user_id] 
		if user_id
			all = get_recent()
			erb(:home, locals:{posts:all})
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
			session[:username] = username
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

	get('/post') do
		user_id = session[:user_id]
		if user_id
			erb(:post)
		else
			redirect('/')
		end
	end

	post('/post/publish') do
		user_id = session[:user_id]
		if user_id
			title = params["title"]
			content = params["content"]
			if content.length>10 && title.length>5
				username = session[:username]
				publish_post(username, title, content)
				redirect('/home')
			else
				set_error("Too short content or title!")
				redirect('/error')
			end
		else
			redirect('/')
		end
	end

	post('/view/:id/favorite') do
		user_id = session[:user_id] 
		if user_id
			id = params[:id]
			favorited = check_fav(user_id, id)
			if favorited[0]
				unfav(user_id, id)
				redirect('/view/' + id)
			else
				favorite(user_id, id)
				redirect('/view/' + id)
			end
		else
			redirect('/')
		end
	end

end