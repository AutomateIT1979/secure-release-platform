from fastapi import FastAPI

app = FastAPI(title="Secure Release Platform")

@app.get("/health")
def health():
    return {"status": "ok"}
