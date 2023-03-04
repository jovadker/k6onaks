# Build the k6 binary with the extension
FROM golang:1.17-alpine as builder

RUN go install go.k6.io/xk6/cmd/xk6@latest
# RUN xk6 build --output /k6 --with github.com/szkiba/xk6-prometheus@latest

RUN xk6 build --with github.com/grafana/xk6-output-prometheus-remote@latest --output /k6

# Use the operator's base image and override the k6 binary
FROM loadimpact/k6:latest
COPY --from=builder /k6 /usr/bin/k6