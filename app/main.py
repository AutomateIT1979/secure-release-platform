from fastapi import FastAPI

app = FastAPI(title="Secure Release Platform")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/version")
def version():
    return {
        "version": "1.0.0",
        "commit": "9d1d7c3",
        "build_date": "2026-02-08"
    }
