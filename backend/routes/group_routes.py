from flask import Blueprint, request, jsonify
from models import db, Group
from utils.logging import log_activity

group_bp = Blueprint('group', __name__)

@group_bp.route('/groups', methods=['GET'])
def get_groups():
    user_id = request.args.get('user_id', type=int)
    if user_id:
        groups = Group.query.filter_by(user_id=user_id).all()
    else:
        groups = Group.query.all()
    return jsonify([{
        'id': g.id,
        'name': g.name,
        'description': g.description,
    } for g in groups]), 200


@group_bp.route('/groups', methods=['POST'])
def create_group():
    data = request.json
    name = data.get('name')
    description = data.get('description', '')
    user_id = data.get('user_id')

    if not name or not user_id:
        return jsonify({'message': 'Nama dan user_id harus diisi'}), 400

    group = Group(name=name, description=description, user_id=user_id)
    db.session.add(group)
    db.session.commit()

    log_activity(user_id, 'create_group', f'Grup baru: {name}')
    return jsonify({'message': 'Grup berhasil dibuat'}), 201


@group_bp.route('/groups/<int:id>', methods=['PUT'])
def update_group(id):
    group = Group.query.get_or_404(id)
    data = request.json

    group.name = data.get('name', group.name)
    group.description = data.get('description', group.description)
    db.session.commit()

    log_activity(None, 'update_group', f'Update grup ID: {id}')
    return jsonify({'message': 'Grup berhasil diperbarui'}), 200

@group_bp.route('/groups/<int:id>', methods=['DELETE'])
def delete_group(id):
    group = Group.query.get_or_404(id)
    db.session.delete(group)
    db.session.commit()

    log_activity(None, 'delete_group', f'Hapus grup ID: {id}')
    return jsonify({'message': 'Grup berhasil dihapus'}), 200
