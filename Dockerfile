# Build Stage
# Use Python 3.12 base image. 
FROM python:3.12 as builder
# Install uv package manager.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
# Set working directory.
WORKDIR /app
# Copy pyproject.toml. 
COPY pyproject.toml ./
# Install python dependencies using uv into a virtual environment.
RUN uv sync --no-install-project --no-editable
RUN uv sync --no-editable
# Final Stage 
# Use Python 3.12-slim base image (smaller footprint)
FROM python:3.12-slim
# Copy venv from builder
COPY --from=builder /app/.venv /app/.venv
# Copy application source code.
COPY . /cc_simple_server ./
COPY --from=builder /app/tests ./tests
# Create non-root user for security.
RUN useradd -m appuser
USER appuser
ENV PATH="/app/.venv/bin:$PATH"
# Expose port 8000.
EXPOSE 8000
# Set CMD to run FastAPI server on 0.0.0.0:8000.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
