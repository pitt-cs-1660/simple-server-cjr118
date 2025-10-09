# Build Stage
# Use Python 3.12 base image. 
FROM python:3.12 as builder
# Install uv package manager.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV VIRTUAL_ENV=/app/.venv
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
# Set working directory.
WORKDIR /app
ENV PYTHONPATH=/app
# Copy pyproject.toml. 
COPY pyproject.toml ./
COPY . .
# Install python dependencies using uv into a virtual environment.
RUN uv sync --no-install-project --no-editable
# Final Stage 
# Use Python 3.12-slim base image (smaller footprint)
FROM python:3.12-slim
# Copy venv from builder
COPY --from=builder /app/.venv /app/.venv
# Copy application source code. 
COPY . /app
COPY --from=builder /app/tests ./tests
ENV PATH="/app/.venv/bin:${PATH}"
ENV PYTHONPATH=/app
# Create non-root user for security.
RUN useradd -m appuser && touch /app/tasks.db && chown -R appuser:appuser /app
WORKDIR /app
ENV PATH="/app/.venv/bin:$PATH"
# Expose port 8000.
EXPOSE 8000
# Set CMD to run FastAPI server on 0.0.0.0:8000.
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
