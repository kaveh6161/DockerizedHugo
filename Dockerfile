# First stage
FROM debian:bullseye-slim AS builder

# Install necessary packages
RUN apt-get update && \
    apt-get install -y wget git gcc libc6-dev

# Download and install the latest stable version of Go
ENV GO_VERSION=1.20.1
RUN wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz && \
    rm go$GO_VERSION.linux-amd64.tar.gz

# Set environment variables for Go
ENV PATH=$PATH:/usr/local/go/bin
# ENV GOPATH=/go

# Clone and compile Hugo
RUN git clone https://github.com/gohugoio/hugo.git && \
    cd hugo && \
    go build

# Second stage
FROM alpine:3.17

# Copy the compiled binary from the first stage
COPY --from=builder /hugo/hugo /usr/local/bin/hugo

# Hugo extended is dynamically linked against glibc, which is not available on Alpine. One solution is to install gcompat compatibility layer.
# This will provide a glibc-compatible layer for musl, which is the default C library on Alpine Linux.
RUN apk add --no-cache gcompat
# RUN apk add --no-cache git go musl-dev gcc

# Add a non-root user for running the container
RUN adduser -S hugo
USER hugo

# Run Hugo version
CMD ["/usr/local/bin/hugo", "version"]
