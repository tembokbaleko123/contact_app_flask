from flask import Blueprint, request, jsonify
from models import db, Person, LogActivity

person_bp = Blueprint('person_routes', __name__)

# Helper to log activity
def log_activity(user_id, action, detail):
    log = LogActivity(
        user_id=user_id,
        action=action,
        detail=detail
    )
    db.session.add(log)
    db.session.commit()

# GET persons by user_id and filter by groups
@person_bp.route('/persons', methods=['GET'])
def get_persons():
    user_id = request.args.get('user_id', type=int)
    group_id = request.args.get('group_id', type=int)

    if not user_id:
        return jsonify({"message": "user_id wajib dikirim"}), 400

    query = Person.query.filter_by(user_id=user_id)

    if group_id is not None:
        query = query.filter_by(group_id=group_id)

    persons = query.all()

    data = [
        {
            "id": p.id,
            "name": p.name,
            "phone": p.phone,
            "image_url": p.image_url,
            "group_id": p.group_id
        }
        for p in persons
    ]
    return jsonify(data), 200


# POST new person
@person_bp.route('/persons', methods=['POST'])
def add_person():
    data = request.get_json()
    user_id = data.get('user_id')
    name = data.get('name')
    phone = data.get('phone')
    image_url = data.get('image_url')
    group_id = data.get('group_id')

    if not user_id or not name:
        return jsonify({"message": "user_id dan name wajib diisi"}), 400

    person = Person(
        name=name,
        phone=phone,
        image_url=image_url,
        group_id=group_id,
        user_id=user_id
    )
    db.session.add(person)
    db.session.commit()

    # Log
    log_activity(user_id, "add_person", f"Menambahkan person: {name}")

    return jsonify({"message": "Person ditambahkan"}), 201

# PUT update person
@person_bp.route('/persons/<int:id>', methods=['PUT'])
def update_person(id):
    data = request.get_json()
    person = Person.query.get(id)

    if not person:
        return jsonify({"message": "Person tidak ditemukan"}), 404

    user_id = data.get('user_id')
    old_name = person.name

    person.name = data.get('name', person.name)
    person.phone = data.get('phone', person.phone)
    person.image_url = data.get('image_url', person.image_url)
    person.group_id = data.get('group_id', person.group_id)
    db.session.commit()

    # Log
    log_activity(user_id, "update_person", f"Mengubah person dari: {old_name} menjadi {person.name}")

    return jsonify({"message": "Person diperbarui"}), 200

# DELETE person
@person_bp.route('/persons/<int:id>', methods=['DELETE'])
def delete_person(id):
    person = Person.query.get(id)
    if not person:
        return jsonify({"message": "Person tidak ditemukan"}), 404

    user_id = person.user_id
    deleted_name = person.name

    db.session.delete(person)
    db.session.commit()

    # Log
    log_activity(user_id, "delete_person", f"Menghapus person: {deleted_name}")

    return jsonify({"message": "Person dihapus"}), 200
