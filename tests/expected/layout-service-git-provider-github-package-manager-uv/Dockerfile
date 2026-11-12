# Build stage: resolve and install dependencies against a full toolchain.
FROM python:3.14-slim AS build

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# git, because the version is read from the SCM tags and the build backend shells out to it.
# This is the build stage, which is discarded, so git never reaches the final image.
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv

# The whole context, including .git, since the version is read from the SCM tags. This stage
# is discarded, so nothing here reaches the final image; .dockerignore keeps the context lean.
COPY . .

RUN uv build --wheel && pip install --no-cache-dir --target=/install dist/*.whl

# Runtime stage: carry the installed package and nothing that built it.
FROM python:3.14-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/install

WORKDIR /app

COPY --from=build /install /install

# Runs as an unprivileged user: a container that does not need root should not have it.
RUN useradd --create-home --uid 1000 app
USER app

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "test_repo.app:app", "--host", "0.0.0.0", "--port", "8000"]
