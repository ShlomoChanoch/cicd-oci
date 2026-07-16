from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Hello API", description="API que retorna saudações personalizadas")

class HelloRequest(BaseModel):
    name: str

@app.get("/")
def hello_get(name: str = ""):
    """
    Endpoint GET que retorna uma saudação.
    Se o nome for vazio, retorna "Hello World!"
    """
    if not name.strip():
        return {"message": "Hello World!"}
    return {"message": f"Hello, {name}."}

@app.post("/hello")
def hello_post(request: HelloRequest):
    """
    Endpoint POST que retorna uma saudação.
    Se o nome for vazio, retorna "Hello World!"
    """
    if not request.name.strip():
        return {"message": "Hello World!"}
    return {"message": f"Hello, {request.name}."}

@app.post("/")
def hello_post_simple(name: str = ""):
    """
    Endpoint POST simples que retorna uma saudação.
    Se o nome for vazio, retorna "Hello World!"
    """
    if not name.strip():
        return {"message": "Hello World!"}
    return {"message": f"Hello, {name}."}