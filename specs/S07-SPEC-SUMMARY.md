# S07 - Specification Summary

**Library:** simple_grpc
**Status:** BACKWASH (reverse-engineered from implementation)
**Generated:** 2026-01-23

## Executive Summary

simple_grpc is a pure-Eiffel implementation of the gRPC protocol. It provides the complete protocol layer for gRPC communication without requiring external libraries for the core functionality. Network I/O must be provided by integrating with socket libraries.

The library consists of 11 classes organized into three layers:
1. **gRPC Layer**: Channel, Service, Method, Call, Status, Metadata
2. **Protocol Buffers Layer**: Encoder/Decoder, Message, Field
3. **HTTP/2 Layer**: Frame handling

## Key Design Decisions

### 1. Protocol-Only Implementation
No network I/O is included. This:
- Maximizes portability
- Allows integration with any socket library
- Simplifies testing
- Enables deterministic behavior

### 2. Facade Pattern
SIMPLE_GRPC provides a single entry point:
- All factories in one place
- Simplified API discovery
- Consistent object creation

### 3. Full Protobuf Wire Format
Complete Protocol Buffers encoding/decoding:
- All scalar types supported
- ZigZag encoding for signed integers
- Length-delimited for strings/bytes/messages
- No .proto parsing (wire format only)

### 4. All Streaming Types
Full gRPC streaming support:
- Unary: Request -> Response
- Server streaming: Request -> Response*
- Client streaming: Request* -> Response
- Bidirectional: Request* -> Response*

### 5. gRPC Status Codes
All 17 standard status codes:
- OK through UNAUTHENTICATED
- Constants on facade for convenience
- Status objects with code and message

## API Surface Summary

| Class | Purpose | Feature Count |
|-------|---------|---------------|
| SIMPLE_GRPC | Facade/Factory | ~25 |
| SIMPLE_GRPC_CHANNEL | Server connection | ~20 |
| SIMPLE_GRPC_SERVICE | Service definition | ~12 |
| SIMPLE_GRPC_METHOD | Method definition | ~8 |
| SIMPLE_GRPC_CALL | RPC invocation | ~15 |
| SIMPLE_GRPC_STATUS | Status codes | ~10 |
| SIMPLE_GRPC_METADATA | Key-value pairs | ~8 |
| SIMPLE_PROTOBUF | Wire encoding | ~45 |
| SIMPLE_PROTOBUF_MESSAGE | Dynamic message | ~15 |
| SIMPLE_PROTOBUF_FIELD | Field definition | ~10 |
| SIMPLE_HTTP2_FRAME | Frame handling | ~20 |

## Usage Patterns

### Creating a Channel
```eiffel
grpc: SIMPLE_GRPC
channel: SIMPLE_GRPC_CHANNEL

create grpc.make
channel := grpc.new_channel ("localhost", 50051)
channel.set_plaintext
channel.connect
```

### Defining a Service
```eiffel
service: SIMPLE_GRPC_SERVICE

service := grpc.new_service ("helloworld.Greeter")
service.add_unary_method ("SayHello", "HelloRequest", "HelloReply")
channel.register_service (service)
```

### Making a Call
```eiffel
call: SIMPLE_GRPC_CALL
request: SIMPLE_PROTOBUF_MESSAGE

call := channel.new_call (service, "SayHello")
request := grpc.new_message
request.set_string (1, "World")
call.set_request (request)

-- Send via socket integration
headers := channel.build_request_headers (call)
data := channel.build_data_frame (1, request.to_bytes, True)
socket.write (headers.to_bytes)
socket.write (data.to_bytes)
```

### Encoding Protobuf
```eiffel
pb: SIMPLE_PROTOBUF

create pb.make
pb.encode_string_field (1, "Hello")
pb.encode_int32_field (2, 42)
bytes := pb.to_bytes
```

### Decoding Protobuf
```eiffel
pb.decode_from_bytes (received_bytes)
from until not pb.has_more loop
    tag := pb.decode_tag
    inspect tag.wire_type
    when 0 then value := pb.decode_varint_32
    when 2 then str := pb.decode_string
    else pb.skip_field (tag.wire_type)
    end
end
```

## Testing Strategy

1. **Unit Tests**: Individual encoding/decoding operations
2. **Protocol Tests**: Frame generation correctness
3. **Roundtrip Tests**: Encode-decode consistency
4. **Integration Tests**: With mock socket

## Known Limitations

1. No actual network I/O
2. No HPACK header compression
3. No .proto file parsing
4. No TLS implementation
5. No flow control
6. No automatic retries

## Future Enhancements (Proposed)

1. HPACK header compression
2. HTTP/2 flow control
3. gRPC-Web support
4. .proto file parser
5. Code generation from .proto
6. Compression support (gzip)
7. Server implementation
8. Integration with simple_socket
