from flask import Blueprint, request, jsonify
from models import db, User

auth_bp = Blueprint('auth_bp', __name__)

# Register
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    if User.query.filter((User.username == username) | (User.email == email)).first():
        return jsonify({'message': 'Username atau email sudah terdaftar'}), 400

    new_user = User(username=username, email=email)
    new_user.set_password(password)

    db.session.add(new_user)
    db.session.commit()

    return jsonify({'message': 'Register berhasil', 'user_id': new_user.id}), 201

# Login
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    user = User.query.filter_by(email=email).first()
    if user and user.check_password(password):
        return jsonify({'message': 'Login berhasil', 'user_id': user.id}), 200
    else:
        return jsonify({'message': 'Email atau password salah'}), 401
