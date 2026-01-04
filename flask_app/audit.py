from models import AuditLog


def log_action(db, action: str, actor: str, task_id):
    entry = AuditLog(
        action=action,
        actor=actor,
        task_id=task_id,
    )
    db.add(entry)
    db.commit()
