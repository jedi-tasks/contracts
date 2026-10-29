PROTO := ./proto/*/*.proto
GRPC_SWIFT_PLUGIN ?= /opt/homebrew/opt/protoc-gen-grpc-swift/bin/protoc-gen-grpc-swift-2

# Локальная генерация для проверки. В репозитории go-server-grpc и swift-client-grpc код пушит CI по тегу vX.Y.Z
build: build-go build-swift

build-go:
	if [ ! -d "go-server-grpc-local" ]; then mkdir go-server-grpc-local; fi
	protoc --experimental_allow_proto3_optional -I ./ --go_out=go-server-grpc-local --go-grpc_out=go-server-grpc-local $(PROTO)

build-swift:
	if [ ! -d "swift-grpc-local" ]; then mkdir swift-grpc-local; fi
	protoc \
		-I ./ \
		--swift_out=swift-grpc-local \
		--grpc-swift_out=swift-grpc-local \
		--swift_opt=Visibility=Public \
		--plugin=protoc-gen-grpc-swift=$(GRPC_SWIFT_PLUGIN) \
		--grpc-swift_opt=Visibility=Public,Client=true,Server=false \
		$(PROTO)

build-desc:
	protoc --descriptor_set_out=output.desc --include_imports $(PROTO)
