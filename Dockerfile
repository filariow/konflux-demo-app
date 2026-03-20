FROM registry.access.redhat.com/ubi9/go-toolset:1.25.7-1773851748@sha256:8b211cc8793d8013140844e8070aa584a8eb3e4e6e842ea4b03dd9914b1a5dc6 AS builder
ARG TARGETOS
ARG TARGETARCH

# Copy the Go Modules manifests
COPY go.mod ./
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source (relies on .dockerignore to filter)
COPY . .

RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH} go build -a -o /tmp/app main.go

FROM registry.access.redhat.com/ubi9/ubi-micro@sha256:093a704be0eaef9bb52d9bc0219c67ee9db13c2e797da400ddb5d5ae6849fa10
WORKDIR /
COPY --from=builder /tmp/app .
USER 65532:65532

ENTRYPOINT ["/app"]
