# Test stage
FROM python:3.7-alpine AS test
LABEL application=todobackend

# Install basic utilities
# RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf && \
#   echo "nameserver 8.8.8.8" >> /etc/resolv.conf && \
RUN apk add --no-cache bash git

# Install build dependencies
# RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf && \
#    echo "nameserver 8.8.8.8" >> /etc/resolv.conf && \
RUN apk add --no-cache gcc python3-dev libffi-dev musl-dev linux-headers mariadb-dev
RUN pip3 install wheel

# Copy requirements
COPY /src/requirements* /build/
WORKDIR /build

# Build and install requirements
# RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf && \
#    echo "nameserver 8.8.8.8" >> /etc/resolv.conf && \
RUN pip3 wheel -r requirements_test.txt --no-cache-dir --no-input
RUN pip3 install -r requirements_test.txt -f /build --no-index --no-cache-dir

# Copy source code
COPY /src /app
WORKDIR /app

# Test entrypoint
CMD ["python3", "manage.py", "test", "--noinput", "--settings=todobackend.settings_test"]

# Release stage
FROM python:3.7-alpine
LABEL application=todobackend

# Install operating system dependencies
# RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf && \
#   echo "nameserver 8.8.8.8" >> /etc/resolv.conf && \
RUN apk add --no-cache mariadb-client bash curl bats jq && \
    pip3 --no-cache-dir install awscli

# Create app user
RUN addgroup -g 1000 app && \
    adduser -u 1000 -G app -D app

# Copy and install application source and pre-built dependencies
COPY --from=test --chown=app:app /build /build
COPY --from=test --chown=app:app /app /app
RUN pip3 install -r /build/requirements.txt -f /build --no-index --no-cache-dir && \
    rm -rf /build

# Create public volume
RUN mkdir /public && \
    chown app:app /public
VOLUME /public

# Entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint
ENTRYPOINT ["/usr/bin/entrypoint"]

# Set working directory and application user
WORKDIR /app
USER app


