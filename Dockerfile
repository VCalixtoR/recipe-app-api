FROM python:3.9-slim
LABEL maintainer="viniciuscalixto.prof@gmail.com"

# Recommended to Python in Docker scenarios to avoid buffering logs, allowing faster printing logs to stdout and stderr
ENV PYTHONUNBUFFERED 1

# Prevents Python from writing bytecode files to disk, reducing disk usage
ENV PYTHONDONTWRITEBYTECODE 1

# This arg is overriden by the local docker-compose, but for production environment the raw container is deploied
ARG DEV=false

# Install PostgreSQL client libraries and development headers
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    python3-dev

# Copy and install dependencies using a virtual environment to avoid conflicts with the base Python image
# The tmp files are deleted and a user for the image is added
# Using a user avoids security risks if an attacker gets access to the Docker container
COPY requirements.txt /tmp/requirements.txt
COPY requirements.dev.txt /tmp/requirements.dev.txt
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Update path environment for the container
ENV PATH="/py/bin:$PATH"

# Use the django user
USER django-user

# Copy the code to container and set the working directory
COPY ./app /app
WORKDIR /app

# Expose the port the Django app runs on
EXPOSE 8000

# The run command is set at the CI CD pipeline