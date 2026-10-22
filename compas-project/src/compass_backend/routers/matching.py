from fastapi import APIRouter

router = APIRouter(prefix="/matching", tags=["Matching Engine"])

@router.post("/run")
def run_matching():
    return {"message": "Matching algorithm endpoint ready"}