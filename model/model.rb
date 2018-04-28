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
        return db.execute('SELECT * FROM post ORDER BY id DESC')
    end

    def get_az
        db = db_connect()
		return db.execute('SELECT * FROM post ORDER BY title COLLATE NOCASE')
    end

    def get_fav id
        db = db_connect()
        return db.execute("SELECT * FROM post WHERE id IN (SELECT post FROM favorites WHERE user IS ?)", [id])
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
        db.execute("INSERT INTO comment(creator, content, post) VALUES (?,?,?)", [username, content, post])
    end

    def fetch_liked_posts id
        db = db_connect()
        return db.execute("SELECT * FROM post WHERE id IN (SELECT post FROM likes WHERE user = ?)", [id])
    end

    def check_fav id, post
        db = db_connect()
        return db.execute("SELECT id FROM favorites WHERE user IS ? AND post IS ?", [id, post])
    end

    def favorite id, post
        db = db_connect()
        db.execute("INSERT INTO favorites(user, post) VALUES (?,?)", [id, post])
    end

    def unfav id, post
        db = db_connect()
        db.execute("DELETE FROM favorites WHERE user IS ? AND post IS ?", [id, post])
    end

end