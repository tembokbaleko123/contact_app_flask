from flask import Blueprint, request, jsonify
from models import db, LogActivity

log_bp = Blueprint('log_bp', __name__)

@log_bp.route('/logs', methods=['GET'])
def get_logs():
    logs = LogActivity.query.order_by(LogActivity.timestamp.desc()).all()
    return jsonify([
        {
            'id': log.id,
            'user_id': log.user_id,
            'action': log.action,
            'timestamp': log.timestamp.isoformat(),
            'detail': log.detail,
        } for log in logs
    ])
