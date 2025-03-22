import base64
import psycopg2
from flask import Flask, request, jsonify
from flask_restful import Resource, Api
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
from DB_CONFIG import DB

def get_db_connection():
    return psycopg2.connect(**DB)

app = Flask(__name__)
api = Api(app)
app.config['SECRET_KEY'] = 'supersecretkey'

def basic_auth_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.headers.get('Authorization')
        if not auth:
            return {'message': 'Отсутствуют учетные данные'}, 401
        try:
            auth_type, credentials = auth.split(" ")
            if auth_type.lower() != "basic":
                return {'message': 'Неверный тип авторизации'}, 401
            decoded = base64.b64decode(credentials).decode('utf-8')
            username, password = decoded.split(":", 1)
        except Exception:
            return {'message': 'Неверный формат авторизации'}, 401
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, password FROM users WHERE login = %s", (username,))
        user = cur.fetchone()
        cur.close()
        conn.close()
        if not user or not check_password_hash(user[1], password):
            return {'message': 'Неверные учетные данные'}, 401
        request.user_id = user[0]
        return f(*args, **kwargs)
    return decorated

class Register(Resource):
    def post(self):
        data = request.get_json()
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id FROM users WHERE login = %s", (data['login'],))
        if cur.fetchone():
            cur.close()
            conn.close()
            return {'message': 'Пользователь уже существует'}, 400
        hashed_password = generate_password_hash(data['password'])
        cur.execute("INSERT INTO users (login, password) VALUES (%s, %s) RETURNING id", (data['login'], hashed_password))
        conn.commit()
        cur.close()
        conn.close()
        return {'message': 'Пользователь зарегистрирован'}, 200

class Login(Resource):
    def post(self):
        data = request.get_json()
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, password FROM users WHERE login = %s", (data['login'],))
        user = cur.fetchone()
        cur.close()
        conn.close()
        if user and check_password_hash(user[1], data['password']):
            return {'message': 'Авторизация успешна', 'user_id': user[0]}, 200
        else:
            return {'message': 'Неверный логин или пароль'}, 401

class Notes(Resource):
    @basic_auth_required
    def get(self):
        user_id = request.user_id
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, note FROM notes WHERE user_id = %s", (user_id,))
        notes = [{'id': row[0], 'note': row[1]} for row in cur.fetchall()]
        cur.close()
        conn.close()
        return notes, 200

    @basic_auth_required
    def post(self):
        user_id = request.user_id
        data = request.get_json()
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO notes (user_id, note) VALUES (%s, %s)", (user_id, data['note']))
        conn.commit()
        cur.close()
        conn.close()
        return {'message': 'Заметка создана'}, 201

class DeleteNote(Resource):
    @basic_auth_required
    def delete(self, note_id):
        user_id = request.user_id
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id FROM notes WHERE id = %s AND user_id = %s", (note_id, user_id))
        if not cur.fetchone():
            cur.close()
            conn.close()
            return {'message': 'Заметка не найдена'}, 404
        cur.execute("DELETE FROM notes WHERE id = %s", (note_id,))
        conn.commit()
        cur.close()
        conn.close()
        return {'message': 'Заметка удалена'}, 200

api.add_resource(Register, '/register')
api.add_resource(Login, '/login')
api.add_resource(Notes, '/notes')
api.add_resource(DeleteNote, '/notes/<int:note_id>')

if __name__ == '__main__':
    app.run(host='172.17.8.181', port=5000)

