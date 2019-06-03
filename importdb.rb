require 'sqlite3'

db = SQLite3::Database.new('db.db')

db.execute('DROP TABLE IF EXISTS users')
db.execute('
    CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(40) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(60) NOT NULL,
    karma INTEGER
)')

db.execute('DROP TABLE IF EXISTS questions')
db.execute('
    CREATE TABLE questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title VARCHAR(100) NOT NULL,
    content VARCHAR(500) NOT NULL,
    votes INTEGER NOT NULL
)')

db.execute('DROP TABLE IF EXISTS tags')
db.execute('
    CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(20) NOT NULL
)')

db.execute('DROP TABLE IF EXISTS taggings')
db.execute('
    CREATE TABLE taggings (
    question_id INTEGER,
    tag_id INTEGER
)')
