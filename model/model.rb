module ForumDB
    DB_PATH = 'db/forum.sqlite'

    def db_connect
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        return db
    end

    def get_user username
        db = db_connect()
        result = db.execute("SELECT * FROM users WHERE username=?", [username])
        return result.first
    end

    def create_user username, password
        db = db_connect()
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO users(username, password_digest) VALUES (?,?)", [username, password_digest])
    end

    def publish_post username, title, content
        db = db_connect()
        db.execute("INSERT INTO post(creator, title, content) VALUES (?,?,?)", [username, title, content])
    end

    def get_recent
        db = db_connect()
        return db.execute('SELECT * FROM post ORDER BY id DESC LIMIT 5')
    end

    def get_az
        db = db_connect()
		return db.execute('SELECT * FROM post ORDER BY title COLLATE NOCASE LIMIT 5')
    end

    def get_top
        db = db_connect()
		return db.execute('SELECT * FROM post ORDER BY points DESC LIMIT 5')
    end

    def post_info id
        db = db_connect()
        return db.execute('SELECT * FROM post WHERE id IS ?', [id])
    end

    def fetch_comments id
        db = db_connect()
        return db.execute('SELECT * FROM comment WHERE post IS ?', [id])
    end

    def publish_comment username, content, post
        db = db_connect()
        db.execute("INSERT INTO comment(creator, content, post, score) VALUES (?,?,?,?)", [username, content, post, 0])
    end

    def fetch_liked_posts id
        db = db_connect()
        return db.execute("SELECT * FROM post WHERE id IN ("'SELECT post FROM likes WHERE user IS ?', [id]")")
    end

end