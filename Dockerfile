FROM registry.access.redhat.com/ubi9/go-toolset:9.8-1780490420@sha256:d36470d5258da00f618b7aca9bdaab8e05134aa938bd6c42d9bd17d50ed45e76 AS builder
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
