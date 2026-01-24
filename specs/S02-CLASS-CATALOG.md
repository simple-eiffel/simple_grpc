# S02 - Class Catalog

**Library:** simple_grpc
**Status:** BACKWASH (reverse-engineered from implementation)
**Generated:** 2026-01-23

## Class Hierarchy

```
ANY
 +-- SIMPLE_GRPC                  [Main facade/factory]
 +-- SIMPLE_GRPC_CHANNEL          [Server connection]
 +-- SIMPLE_GRPC_SERVICE          [Service definition]
 +-- SIMPLE_GRPC_METHOD           [RPC method definition]
 +-- SIMPLE_GRPC_CALL             [Active RPC invocation]
 +-- SIMPLE_GRPC_STATUS           [Status codes]
 +-- SIMPLE_GRPC_METADATA         [Key-value pairs]
 +-- SIMPLE_PROTOBUF              [Wire format encoder/decoder]
 +-- SIMPLE_PROTOBUF_MESSAGE      [Dynamic message container]
 +-- SIMPLE_PROTOBUF_FIELD        [Field definition]
 +-- SIMPLE_HTTP2_FRAME           [HTTP/2 frame handling]
```

## Class Details

### SIMPLE_GRPC (Facade)

**Purpose:** Central factory and entry point for gRPC operations.

**Responsibilities:**
- Create channels, services, methods
- Create messages and status objects
- Provide protobuf factories
- Expose status code constants

**Creation Procedures:**
- `make` - Create gRPC facade

**Factory Methods:**
- Channel: `new_channel`, `new_plaintext_channel`
- Service: `new_service`
- Method: `new_unary_method`, `new_server_streaming_method`, etc.
- Message: `new_message`, `new_message_with_name`
- Protobuf: `new_protobuf`, `new_protobuf_field_*`
- Status: `new_status_ok`, `new_status`, `new_status_error`
- Metadata: `new_metadata`
- HTTP/2: `new_http2_data_frame`, `new_http2_headers_frame`, etc.

---

### SIMPLE_GRPC_CHANNEL

**Purpose:** Represents a connection to a gRPC server.

**Responsibilities:**
- Manage connection state (idle, connecting, ready, shutdown)
- Register services
- Create RPC calls
- Build HTTP/2 request headers
- Manage default metadata and timeout

**Creation Procedures:**
- `make (a_host, a_port)` - Create channel to server

**State Constants:**
- `state_idle` (0), `state_connecting` (1), `state_ready` (2)
- `state_transient_failure` (3), `state_shutdown` (4)

**Invariants:**
```eiffel
host_not_empty: not host.is_empty
valid_port: port > 0 and port <= 65535
valid_state: state >= state_idle and state <= state_shutdown
odd_stream_id: next_stream_id \\ 2 = 1  -- Client streams are odd
```

---

### SIMPLE_GRPC_SERVICE

**Purpose:** Defines a gRPC service with its methods.

**Responsibilities:**
- Store service name (package.ServiceName)
- Manage method definitions
- Build method paths

**Creation Procedures:**
- `make (a_name)` - Create service

**Invariants:**
```eiffel
name_not_empty: not name.is_empty
methods_attached: methods /= Void
```

---

### SIMPLE_GRPC_METHOD

**Purpose:** Defines an RPC method with its streaming characteristics.

**Responsibilities:**
- Store method name and type names
- Track streaming type (unary, server, client, bidirectional)

**Creation Procedures:**
- `make_unary (a_name, a_request_type, a_response_type)`
- `make_server_streaming (a_name, a_request_type, a_response_type)`
- `make_client_streaming (a_name, a_request_type, a_response_type)`
- `make_bidirectional (a_name, a_request_type, a_response_type)`

---

### SIMPLE_GRPC_CALL

**Purpose:** Represents an active RPC invocation.

**Responsibilities:**
- Store request/response messages
- Manage call metadata
- Track call state and timeout
- Store result status

**Collaborators:**
- SIMPLE_GRPC_METHOD (call definition)
- SIMPLE_PROTOBUF_MESSAGE (request/response)
- SIMPLE_GRPC_STATUS (result)
- SIMPLE_GRPC_METADATA (headers/trailers)

---

### SIMPLE_GRPC_STATUS

**Purpose:** Represents gRPC status codes and messages.

**Status Codes (0-16):**
- OK (0), CANCELLED (1), UNKNOWN (2)
- INVALID_ARGUMENT (3), DEADLINE_EXCEEDED (4), NOT_FOUND (5)
- ALREADY_EXISTS (6), PERMISSION_DENIED (7), RESOURCE_EXHAUSTED (8)
- FAILED_PRECONDITION (9), ABORTED (10), OUT_OF_RANGE (11)
- UNIMPLEMENTED (12), INTERNAL (13), UNAVAILABLE (14)
- DATA_LOSS (15), UNAUTHENTICATED (16)

---

### SIMPLE_GRPC_METADATA

**Purpose:** Key-value pairs for gRPC headers and trailers.

**Responsibilities:**
- Store string key-value pairs
- Support iteration
- Binary metadata (keys ending in "-bin")

---

### SIMPLE_PROTOBUF

**Purpose:** Protocol Buffers wire format encoding and decoding.

**Wire Types:**
- 0: VARINT (int32, int64, bool, enum)
- 1: I64 (fixed64, double)
- 2: LEN (string, bytes, messages)
- 5: I32 (fixed32, float)

**Responsibilities:**
- Encode/decode varints (32/64-bit)
- Encode/decode ZigZag signed integers
- Encode/decode fixed-width integers
- Encode/decode length-delimited fields
- Tag encoding (field number + wire type)

**Invariants:**
```eiffel
buffer_attached: buffer /= Void
```

---

### SIMPLE_PROTOBUF_MESSAGE

**Purpose:** Dynamic protocol buffers message container.

**Responsibilities:**
- Store fields by number
- Serialize to wire format
- Parse from wire format
- Access fields by number or name

---

### SIMPLE_PROTOBUF_FIELD

**Purpose:** Represents a single field in a protobuf message.

**Field Types:**
- Scalar: int32, int64, uint32, uint64, sint32, sint64
- Scalar: bool, string, bytes
- Fixed: fixed32, fixed64, sfixed32, sfixed64

---

### SIMPLE_HTTP2_FRAME

**Purpose:** HTTP/2 frame generation and parsing.

**Frame Types:**
- DATA (0), HEADERS (1), PRIORITY (2), RST_STREAM (3)
- SETTINGS (4), PUSH_PROMISE (5), PING (6), GOAWAY (7)
- WINDOW_UPDATE (8), CONTINUATION (9)

## Design Patterns

### Facade Pattern
SIMPLE_GRPC provides a unified entry point hiding the complexity of channels, services, and encoding.

### Factory Pattern
Factory methods in SIMPLE_GRPC create all component types.

### State Pattern
SIMPLE_GRPC_CHANNEL manages connection state machine.

### Builder Pattern
HTTP/2 frame building uses builder-style methods.
