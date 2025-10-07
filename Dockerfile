# Build Stage:
# Use Python 3.12 base image.
FROM python:3.12 as builder
# Install UV package manager.
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"
# Set working directory.
WORKDIR /app
# Copy pyproject.toml.
COPY pyproject.toml README.md./
# Install Python dependencies using uv into a virtual environment.
RUN uv sync 
# Final Stage:
# Use Python 3.12-slim base image (smaller footprint).
FROM python:3.12-slim
WORKDIR /app
# Copy the virtual environment from build stage
COPY --from=builder /app/.venv /app/.venv
# Copy application source code
COPY --from=builder /app/cc_simple_server ./cc_simple_server
COPY --from=builder /app/tests ./tests
# Create non-root user for security
RUN useradd -m appuser
USER appuser
ENV PATH="/app/.venv/bin:$PATH"
# Expose port 8000
EXPOSE 8000
# Set CMD to run FastAPI server on 0.0.0.0:8000
CMD ["uvicorn","cc_simple_server.server:app","--host","0.0.0.0","--port","8000"]
