# S05 - Constraints

**Library:** simple_grpc
**Status:** BACKWASH (reverse-engineered from implementation)
**Generated:** 2026-01-23

## Protocol Constraints

### gRPC Protocol
- Implements gRPC 1.0 specification
- HTTP/2 transport layer
- Protocol Buffers 3 wire format
- No HTTP/1.1 fallback

### HTTP/2 Constraints
- Client-initiated streams use odd IDs (1, 3, 5, ...)
- Server-initiated streams use even IDs (not implemented)
- Stream 0 reserved for connection-level frames
- Frame size limit: 16KB default (configurable via SETTINGS)

### Protocol Buffers Constraints
- Wire format encoding/decoding only
- No .proto file parsing
- No schema validation
- Field numbers must be >= 1
- Supports all proto3 scalar types

## Type Constraints

### String Constraints
- Strings use READABLE_STRING_8 (ASCII/UTF-8)
- Service names: package.ServiceName format
- Method paths: /package.Service/Method format

### Numeric Constraints
- Port numbers: 1-65535
- Status codes: 0-16
- Field numbers: >= 1
- Stream IDs: >= 1, odd for client

### Binary Constraints
- Binary data as ARRAY [NATURAL_8]
- Metadata keys ending in "-bin" are binary
- All other metadata values are text

## Operational Constraints

### Channel State Machine
```
IDLE -> CONNECTING -> READY -> SHUTDOWN
         |
         v
    TRANSIENT_FAILURE -> READY
```

- TLS can only be configured before connect
- Shutdown is terminal (no reconnect)

### Method Types
- Unary: Single request, single response
- Server streaming: Single request, stream of responses
- Client streaming: Stream of requests, single response
- Bidirectional: Stream of requests, stream of responses

### Timeout Handling
- Timeout in milliseconds
- Default: 30000ms (30 seconds)
- Encoded as grpc-timeout header
- Format: `{value}m` for milliseconds

## Network Constraints

### Protocol-Only Implementation
- **No actual network I/O**
- Generates HTTP/2 frames for external transport
- Parses received frames
- Requires integration with socket library

### Integration Requirements
- Socket library for TCP connections
- TLS library for encrypted connections
- Async I/O for streaming

## Encoding Constraints

### Varint Encoding
- Maximum 10 bytes for 64-bit values
- MSB indicates continuation
- Little-endian byte order

### ZigZag Encoding
- Maps signed to unsigned for efficient varint
- (n << 1) ^ (n >> 31) for 32-bit
- (n << 1) ^ (n >> 63) for 64-bit

### Fixed-Width Encoding
- Little-endian byte order
- 4 bytes for fixed32/sfixed32/float
- 8 bytes for fixed64/sfixed64/double

### Length-Delimited
- Varint length prefix
- Followed by raw bytes
- Used for strings, bytes, embedded messages

## HTTP/2 Frame Constraints

### Frame Header (9 bytes)
- Length: 3 bytes (max 16MB)
- Type: 1 byte
- Flags: 1 byte
- Reserved: 1 bit
- Stream ID: 31 bits

### gRPC Message Framing
- 1 byte compression flag
- 4 bytes message length (big-endian)
- Message bytes

## Error Handling Constraints

### Status Codes
- 0 (OK) is success
- 1-16 are error codes
- Error messages are UTF-8 strings
- Transmitted via grpc-status and grpc-message trailers

### No Exceptions
- Status objects for error handling
- is_ok/is_error queries
- No Eiffel exceptions for protocol errors

## Performance Constraints

### Memory Usage
- Buffers stored in ARRAYED_LIST [NATURAL_8]
- No streaming for large messages
- Entire message loaded into memory

### Time Complexity

| Operation | Time |
|-----------|------|
| Varint encode | O(1) amortized |
| Varint decode | O(length) |
| String encode | O(length) |
| String decode | O(length) |
| Tag encode | O(1) |
| Tag decode | O(1) |

## Security Constraints

### TLS Support
- set_tls configuration available
- Actual TLS requires external library
- No certificate validation in library

### Metadata Security
- No credential handling
- Authentication via external metadata
- Binary metadata for sensitive data

## Thread Safety Constraints

### No Internal Synchronization
- Channels not thread-safe
- Calls not thread-safe
- Buffers not thread-safe
- Client responsible for synchronization

### SCOOP Compatibility
- No separate regions used
- Can be wrapped in SCOOP processor
