FROM golang:alpine AS builder
RUN go install github.com/microsoft/ethr@v1.0.0

FROM alpine
COPY --from=builder /go/bin/ethr /usr/local/bin/ethr