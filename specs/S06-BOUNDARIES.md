# S06 - Boundaries

**Library:** simple_grpc
**Status:** BACKWASH (reverse-engineered from implementation)
**Generated:** 2026-01-23

## Scope Boundaries

### In Scope

1. **gRPC Protocol Layer**
   - Channel management (state machine)
   - Service and method definitions
   - Call creation and configuration
   - Metadata handling
   - Status codes

2. **Protocol Buffers Encoding**
   - All scalar types (int32, int64, uint32, uint64, sint32, sint64)
   - Fixed-width types (fixed32, fixed64, sfixed32, sfixed64)
   - Boolean, string, bytes
   - Varint encoding/decoding
   - ZigZag encoding for signed integers
   - Tag and wire type handling
   - Length-delimited encoding

3. **HTTP/2 Frame Handling**
   - DATA frames
   - HEADERS frames
   - SETTINGS frames (including ACK)
   - Frame parsing and generation

4. **Streaming Support**
   - Unary RPC
   - Server streaming RPC
   - Client streaming RPC
   - Bidirectional streaming RPC

### Out of Scope

1. **Network I/O**
   - TCP socket connections
   - TLS/SSL handshakes
   - Connection pooling
   - Keep-alive handling

2. **.proto File Processing**
   - .proto file parsing
   - Schema compilation
   - Code generation
   - Schema validation

3. **Advanced HTTP/2 Features**
   - HPACK header compression
   - Flow control
   - PUSH_PROMISE frames
   - Priority handling

4. **Server Implementation**
   - gRPC server hosting
   - Service implementation
   - Request routing
   - Load balancing

5. **Advanced Features**
   - Retry policies
   - Interceptors
   - Compression (gzip, etc.)
   - Deadlines propagation
   - Cancellation propagation

6. **Security**
   - TLS implementation
   - Certificate validation
   - OAuth/JWT authentication
   - mTLS

## API Boundaries

### Public API

All features in all 11 classes are public.

### Internal API (feature {NONE})

| Class | Feature | Purpose |
|-------|---------|---------|
| SIMPLE_GRPC_CHANNEL | next_stream_id | Stream ID generator |
| SIMPLE_GRPC_CHANNEL | allocate_stream_id | Allocate next ID |
| SIMPLE_PROTOBUF | decode_position | Buffer position |

### Extension Points

1. **SIMPLE_GRPC**
   - Facade can be extended with custom factories
   - New frame types via inheritance

2. **SIMPLE_GRPC_CHANNEL**
   - Override connect for custom transport
   - Override build_request_headers for custom headers

3. **SIMPLE_PROTOBUF**
   - Add custom encoding methods
   - Support additional wire types

4. **SIMPLE_HTTP2_FRAME**
   - Add new frame types
   - Custom flag handling

## Dependency Boundaries

### Required Dependencies
- EiffelStudio base library only

### No Dependencies On
- Network libraries
- TLS libraries
- JSON libraries
- File I/O libraries
- Other simple_* libraries

### Integration Requirements
External code must provide:
- TCP socket operations
- TLS operations (for encrypted channels)
- Async I/O (for streaming)

## Data Boundaries

### Input Boundaries
- Host: STRING (ASCII hostname or IP)
- Port: INTEGER (1-65535)
- Service name: STRING (package.ServiceName)
- Method name: STRING
- Message fields: INTEGER, INTEGER_64, STRING, ARRAY [NATURAL_8]
- Metadata: STRING key-value pairs

### Output Boundaries
- HTTP/2 frames: ARRAY [NATURAL_8]
- Encoded messages: ARRAY [NATURAL_8]
- Status: INTEGER code + STRING message
- Metadata: HASH_TABLE [STRING, STRING]

### Size Limits
- Varint: 10 bytes maximum
- HTTP/2 frame: 16KB default (SETTINGS configurable)
- gRPC message: Limited by HTTP/2 frame size
- Service name: No explicit limit
- Metadata: No explicit limit

## Error Boundaries

### Protocol Errors
- Status codes 1-16 indicate specific errors
- Status 2 (UNKNOWN) for unclassified errors
- Message string provides details

### Encoding Errors
- Incomplete varint
- Invalid wire type
- Insufficient bytes for fixed-width

### Not Handled
- Network errors (out of scope)
- TLS errors (out of scope)
- Resource exhaustion

## Integration Boundaries

### Socket Integration
```eiffel
-- Example: Send frame to server
channel.connect
headers := channel.build_request_headers (call)
socket.write (headers.to_bytes)

-- Send data
data := channel.build_data_frame (stream_id, message.to_bytes, True)
socket.write (data.to_bytes)
```

### TLS Integration
```eiffel
-- Channel configured for TLS
channel.set_tls

-- External TLS library wraps socket
tls_socket := create_tls_connection (channel.host, channel.port)
```

### Streaming Integration
```eiffel
-- Server streaming requires read loop
from
until
    end_of_stream
loop
    raw := socket.read
    frame := parse_http2_frame (raw)
    if frame.is_data then
        response := parse_protobuf (frame.payload)
        process_response (response)
    end
end
```
