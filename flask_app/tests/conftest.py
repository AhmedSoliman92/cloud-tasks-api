import os
from unittest.mock import MagicMock
import pytest
from app import app

# Set testing environment variable
os.environ["COMPONENT_TESTING"] = "1"


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


@pytest.fixture
def mock_db(mocker):
    mock_session = MagicMock()
    mocker.patch("app.SessionLocal", return_value=mock_session)
    return mock_session


@pytest.fixture
def mock_log_action(mocker):
    return mocker.patch("app.log_action")
