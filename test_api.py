from fastapi.testclient import TestClient
from api import app 

client = TestClient(app)

# ==========================================
# TESTES DO ENDPOINT: GET /
# ==========================================

def test_hello_get_no_name():
    """
    Testa o GET / sem passar o parâmetro name (deve retornar Hello World!)
    """
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World!"}

def test_hello_get_with_name():
    """
    Testa o GET / passando um nome
    """
    response = client.get("/?name=Shlomo")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, Shlomo."}

def test_hello_get_empty_string():
    """
    Testa o GET / passando uma string vazia no nome
    """
    response = client.get("/?name=   ")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World!"}


# ==========================================
# TESTES DO ENDPOINT: POST /hello
# ==========================================

def test_hello_post_with_name():
    """
    Testa o POST /hello enviando o JSON correto com nome
    """
    response = client.post("/hello", json={"name": "Chanoch"})
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, Chanoch."}

def test_hello_post_empty_name():
    """
    Testa o POST /hello enviando um nome vazio
    """
    response = client.post("/hello", json={"name": "   "})
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World!"}

def test_hello_post_invalid_payload():
    """
    Testa se o POST /hello valida o payload corretamente 
    (deve dar erro 422 se faltar o campo 'name')
    """
    response = client.post("/hello", json={})
    assert response.status_code == 422


# ==========================================
# TESTES DO ENDPOINT: POST / (Simple)
# ==========================================

def test_hello_post_simple_no_name():
    """
    Testa o POST / simples sem parâmetros
    """
    response = client.post("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World!"}

def test_hello_post_simple_with_name():
    """
    Testa o POST / simples enviando o nome como query parameter
    """
    response = client.post("/?name=FastAPI")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, FastAPI."}