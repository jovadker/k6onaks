FROM golang:1.17-alpine as builder
WORKDIR $GOPATH/src/go.k6.io/k6
ADD . .
RUN apk --no-cache add git
RUN go install go.k6.io/xk6/cmd/xk6@latest
RUN xk6 build --with github.com/grafana/xk6-output-influxdb@v0.2.1=. --output /tmp/k6

# Use the operator's base image and override the k6 binary
FROM loadimpact/k6:latest
COPY --from=builder /tmp/k6 /usr/bin/k6
