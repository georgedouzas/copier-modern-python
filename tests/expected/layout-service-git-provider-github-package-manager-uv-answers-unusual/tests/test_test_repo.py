"""Test the `test_repo` module."""

from fastapi.testclient import TestClient

from test_repo.app import app

OK = 200


def test_health():
    """The health endpoint answers."""
    response = TestClient(app).get('/health')
    assert response.status_code == OK
    assert response.json() == {'status': 'ok'}
