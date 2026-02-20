from app import process_pending_task
from models import Task


def test_process_pending_task(mock_db, mock_log_action, mocker):
    # Mock sleep to avoid waiting
    mocker.patch("time.sleep")

    # Mock pending task
    mck_tsk = Task(id="123", status="pending", payload={})
    mock_db.query.return_value.filter.return_value.first.return_value = mck_tsk

    # Run worker logic
    process_pending_task()

    # Verify interactions
    assert mck_tsk.status == "done"

    # Verify log calls (pickup and complete)
    assert mock_log_action.call_count == 2
    mock_log_action.assert_any_call(
        mock_db, "pickup_task", "worker", mck_tsk.id
    )
    mock_log_action.assert_any_call(
        mock_db, "complete_task", "worker", mck_tsk.id
    )

    # Verify commit calls
    assert mock_db.commit.call_count == 2


def test_no_pending_task(mock_db):
    mock_db.query.return_value.filter.return_value.first.return_value = None

    process_pending_task()

    mock_db.commit.assert_not_called()
