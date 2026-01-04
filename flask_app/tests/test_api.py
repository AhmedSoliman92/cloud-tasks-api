from models import Task


def test_create_task(client, mock_db, mock_log_action):
    # Test POST
    payload = {'foo': 'bar'}
    response = client.post('/tasks', json=payload)

    assert response.status_code == 201
    mock_db.add.assert_called_once()
    mock_db.commit.assert_called_once()
    mock_log_action.assert_called_once()


def test_get_task(client, mock_db):
    mck_tsk = Task(id='123', status='pending', payload={'a': 1})
    mock_db.query.return_value.filter.return_value.first.return_value = mck_tsk

    response = client.get('/tasks/123')
    assert response.status_code == 200
    data = response.json
    assert data['id'] == '123'


def test_update_task(client, mock_db, mock_log_action):
    mck_tsk = Task(id='123', status='pending', payload={})
    mock_db.query.return_value.filter.return_value.first.return_value = mck_tsk

    response = client.put(
        '/tasks/123', json={'status': 'done', 'payload': {'foo': 'bar'}}
    )

    assert response.status_code == 200
    assert mck_tsk.status == 'done'
    assert mck_tsk.payload == {'foo': 'bar'}
    mock_db.commit.assert_called_once()
    mock_log_action.assert_called_once()


def test_delete_task(client, mock_db, mock_log_action):
    mck_tsk = Task(id='123', status='pending', payload={})
    mock_db.query.return_value.filter.return_value.first.return_value = mck_tsk

    response = client.delete('/tasks/123')

    assert response.status_code == 200
    mock_db.delete.assert_called_once_with(mck_tsk)
    mock_db.commit.assert_called_once()
    mock_log_action.assert_called_once()


def test_update_task_not_found(client, mock_db):
    mock_db.query.return_value.filter.return_value.first.return_value = None

    response = client.put('/tasks/999', json={'status': 'done'})
    assert response.status_code == 404


def test_delete_task_not_found(client, mock_db):
    mock_db.query.return_value.filter.return_value.first.return_value = None

    response = client.delete('/tasks/999')
    assert response.status_code == 404
