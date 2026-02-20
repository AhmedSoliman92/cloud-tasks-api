import threading
import time

from flask import Flask, jsonify, request
from sqlalchemy.exc import OperationalError
from sqlalchemy.orm import Session

from audit import log_action
from db import Base, SessionLocal, engine
from models import Task

app = Flask(__name__)


def setup_database():
    """Ensures all tables exist before the app starts."""
    retries = 5
    while retries > 0:
        try:
            with engine.begin() as connection:
                Base.metadata.create_all(bind=connection)
            print("Database initialization complete.")
            return
        except OperationalError as e:
            retries -= 1
            print(f"Database connection failed: {e}.")
            time.sleep(2)
    raise Exception("Could not connect to the database.")


setup_database()


@app.route("/", methods=["GET"])
def home():
    return jsonify({"Message": "Ahmed, It works!"}), 200


@app.route("/tasks", methods=["POST"])
def create_task():
    db: Session = SessionLocal()
    try:
        payload = request.json
        task = Task(status="pending", payload=payload)
        db.add(task)
        db.commit()
        db.refresh(task)

        log_action(db, "create_task", "api", task.id)

        return jsonify({"id": str(task.id), "status": task.status}), 201
    finally:
        db.close()


@app.route("/tasks/<task_id>", methods=["GET"])
def get_task(task_id):
    db: Session = SessionLocal()
    try:
        task = db.query(Task).filter(Task.id == task_id).first()

        if not task:
            return jsonify({"error": "Not found"}), 404

        return jsonify(
            {
                "id": str(task.id),
                "status": task.status,
                "payload": task.payload,
            }
        )
    finally:
        db.close()


@app.route("/tasks/<task_id>", methods=["PUT"])
def update_task(task_id):
    db: Session = SessionLocal()
    try:
        task = db.query(Task).filter(Task.id == task_id).first()

        if not task:
            return jsonify({"error": "Not found"}), 404

        data = request.json
        if "status" in data:
            task.status = data["status"]
        if "payload" in data:
            task.payload = data["payload"]

        db.commit()
        db.refresh(task)

        log_action(db, "update_task", "api", task.id)

        return jsonify(
            {
                "id": str(task.id),
                "status": task.status,
                "payload": task.payload,
            }
        )
    finally:
        db.close()


@app.route("/tasks/<task_id>", methods=["DELETE"])
def delete_task(task_id):
    db: Session = SessionLocal()
    try:
        task = db.query(Task).filter(Task.id == task_id).first()

        if not task:
            return jsonify({"error": "Not found"}), 404

        log_action(db, "delete_task", "api", task.id)

        db.delete(task)
        db.commit()

        return jsonify({"message": "Task deleted successfully"}), 200
    finally:
        db.close()


@app.route("/tasks", methods=["GET"])
def get_tasks():
    db: Session = SessionLocal()
    try:
        tasks = db.query(Task).all()
        return jsonify(
            [
                {
                    "id": str(task.id),
                    "status": task.status,
                    "payload": task.payload,
                }
                for task in tasks
            ]
        )
    finally:
        db.close()


def process_pending_task():
    """Checks for a pending task and processes it."""
    try:
        db: Session = SessionLocal()
        task = db.query(Task).filter(Task.status == "pending").first()

        if task:
            print(f"Worker picked up task {task.id}")
            task.status = "running"
            db.commit()
            log_action(db, "pickup_task", "worker", task.id)

            # Simulate work
            time.sleep(5)

            task.status = "done"
            db.commit()
            log_action(db, "complete_task", "worker", task.id)
            print(f"Worker completed task {task.id}")

        db.close()
    except Exception as e:
        print(f"Worker error: {e}")


def run_worker():
    """Simulates a worker processing tasks."""
    print("Worker started...")
    while True:
        process_pending_task()
        time.sleep(2)


worker_thread = threading.Thread(target=run_worker, daemon=True)
worker_thread.start()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
