"""The web API for `test_repo`.

Run it locally with `uvicorn test_repo.app:app --reload`. No broker,
database or other service is required to start it.
"""

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title='test-repo', description='Kedro\'s "data" tool, Données')


class Health(BaseModel):
    """The response returned by the health endpoint."""

    status: str


@app.get('/health')
def health() -> Health:
    """Report that the service is up.

    Returns:
        The service status.
    """
    return Health(status='ok')
