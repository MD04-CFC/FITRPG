from fastapi .testclient import TestClient
from app.main import app
import time

client = TestClient(app)

def test_connection_status():
    response = client.get('/api/test')
    assert response.status_code == 200
    assert response.json() == {'status':'ok', 'message':'Backend dziala poprawnie'}

def test_connection_time():
    start_time = time.time()
    client.get('/api/test')
    end_time = time.time()
    response_time = end_time-start_time

    assert response_time < .05, f"Wolna odpowiedz: {response_time}s"