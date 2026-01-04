import uuid
from sqlalchemy import Column, String, Enum, JSON, TIMESTAMP, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from db import Base


class Task(Base):
    __tablename__ = "tasks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    status = Column(
        Enum("pending", "running", "done", "failed", name="task_status"),
        nullable=False,
    )
    payload = Column(JSON, nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, onupdate=func.now())


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    action = Column(String, nullable=False)
    actor = Column(String, nullable=False)
    task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id"))
    timestamp = Column(TIMESTAMP, server_default=func.now())
