from flask import Flask
from flask_cors import CORS
from models import db
from routes.user_routes import user_bp
from routes.person_routes import person_bp
from routes.group_routes import group_bp
from routes.log_routes import log_bp
from routes.auth_routes import auth_bp

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)
CORS(app)

with app.app_context():
    db.create_all()

app.register_blueprint(auth_bp)
app.register_blueprint(user_bp)
app.register_blueprint(person_bp)
app.register_blueprint(group_bp)
app.register_blueprint(log_bp)

if __name__ == '__main__':
    app.run(debug=True)
