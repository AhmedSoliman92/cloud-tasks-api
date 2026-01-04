import os

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv

load_dotenv()

DB_USER = os.environ["DB_USER"]
DB_PASS = os.environ["DB_PASS"]
DB_HOST = os.environ["DB_HOST"]
DB_NAME = os.environ["DB_NAME"]

if DB_HOST.startswith("/"):
    DATABASE_URL = (
        f"postgresql://{DB_USER}:{DB_PASS}@/{DB_NAME}?host={DB_HOST}"
    )
else:
    DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"


engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()
