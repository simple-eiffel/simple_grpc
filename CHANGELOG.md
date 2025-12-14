# Changelog

All notable changes to simple_grpc will be documented in this file.

## [0.1.0] - 2025-12-14

### Added
- Initial release
- **Protocol Buffers support**:
  - SIMPLE_PROTOBUF: Wire format encoder/decoder
  - SIMPLE_PROTOBUF_MESSAGE: Dynamic message container
  - SIMPLE_PROTOBUF_FIELD: Field definitions
  - Varint encoding/decoding
  - ZigZag encoding for signed integers
  - Fixed-width integer encoding (32/64-bit)
  - Length-delimited strings and bytes
  - Field tag encoding

- **HTTP/2 framing**:
  - SIMPLE_HTTP2_FRAME: Frame structure and encoding
  - DATA frames
  - HEADERS frames
  - SETTINGS frames
  - WINDOW_UPDATE frames
  - PING frames
  - GOAWAY frames
  - RST_STREAM frames

- **gRPC protocol**:
  - SIMPLE_GRPC: Main facade
  - SIMPLE_GRPC_CHANNEL: Connection management
  - SIMPLE_GRPC_SERVICE: Service definitions
  - SIMPLE_GRPC_METHOD: Method definitions
  - SIMPLE_GRPC_CALL: RPC invocation
  - SIMPLE_GRPC_STATUS: Status codes (0-16)
  - SIMPLE_GRPC_METADATA: Headers and trailers
  - gRPC message framing (length-prefixed)

- **Method types**:
  - Unary RPC
  - Server streaming RPC
  - Client streaming RPC
  - Bidirectional streaming RPC

- **Test suite**: 46 tests covering all components
