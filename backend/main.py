from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import fastapi.middleware

app = FastAPI(
    title='FITRPG Backend Api',
    description='API aplikacji FITRPG'
)

@app.get('/api/test')
def test_check():
    return {'status':'ok', 'message':'Backend dziala poprawnie'}