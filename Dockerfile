# Test stage
FROM python:3.7-alpine AS test
LABEL application=todobackend

# Install basic utilities
RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf && \
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf && \
    apk add --no-cache bash git

# Install build dependencies
RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf && \
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf && \
    apk add --no-cache gcc python3-dev libffi-dev musl-dev linux-headers mariadb-dev
RUN pip3 install wheel

# Copy requirements
COPY /src/requirements* /build/
WORKDIR /build

# Build and install requirements
RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf && \
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf && \
    pip3 wheel -r requirements_test.txt --no-cache-dir --no-input
RUN pip3 install -r requirements_test.txt -f /build --no-index --no-cache-dir

# Copy source code
COPY /src /app
WORKDIR /app

# Test entrypoint
CMD ["python3", "manage.py", "test", "--noinput", "--settings=todobackend.settings_test"]
