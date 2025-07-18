from models import db, LogActivity

def log_activity(user_id, action, detail=None):
    log = LogActivity(
        user_id=user_id,
        action=action,
        detail=detail
    )
    db.session.add(log)
    db.session.commit()
