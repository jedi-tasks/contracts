PROTO := ./proto/*/*.proto
GRPC_SWIFT_PLUGIN ?= /opt/homebrew/opt/protoc-gen-grpc-swift/bin/protoc-gen-grpc-swift-2

build: build-go build-swift

build-go:
	rm -rf gen/go && mkdir -p gen/go
	protoc --experimental_allow_proto3_optional -I ./ --go_out=gen/go --go-grpc_out=gen/go $(PROTO)

build-swift:
	rm -rf gen/swift && mkdir -p gen/swift
	protoc \
		-I ./ \
		--swift_out=gen/swift \
		--grpc-swift_out=gen/swift \
		--swift_opt=Visibility=Public \
		--plugin=protoc-gen-grpc-swift=$(GRPC_SWIFT_PLUGIN) \
		--grpc-swift_opt=Visibility=Public,Client=true,Server=false \
		$(PROTO)

build-desc:
	protoc --descriptor_set_out=output.desc --include_imports $(PROTO)
