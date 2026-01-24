# S03 - Contracts

**Library:** simple_grpc
**Status:** BACKWASH (reverse-engineered from implementation)
**Generated:** 2026-01-23

## SIMPLE_GRPC Contracts (Facade)

### Channel Factory Contracts

#### new_channel (a_host, a_port): SIMPLE_GRPC_CHANNEL
```eiffel
require
    host_not_empty: not a_host.is_empty
    valid_port: a_port > 0 and a_port <= 65535
ensure
    result_created: Result /= Void
```

#### new_plaintext_channel (a_host, a_port): SIMPLE_GRPC_CHANNEL
```eiffel
require
    host_not_empty: not a_host.is_empty
    valid_port: a_port > 0 and a_port <= 65535
ensure
    result_created: Result /= Void
    is_plaintext: Result.is_plaintext
```

### Service Factory Contracts

#### new_service (a_name): SIMPLE_GRPC_SERVICE
```eiffel
require
    name_not_empty: not a_name.is_empty
ensure
    result_created: Result /= Void
```

### Method Factory Contracts

#### new_unary_method (a_name, a_request_type, a_response_type): SIMPLE_GRPC_METHOD
```eiffel
require
    name_not_empty: not a_name.is_empty
ensure
    result_created: Result /= Void
    is_unary: Result.is_unary
```

#### new_server_streaming_method (...): SIMPLE_GRPC_METHOD
```eiffel
require
    name_not_empty: not a_name.is_empty
ensure
    result_created: Result /= Void
    is_server_streaming: Result.is_server_streaming
```

#### new_client_streaming_method (...): SIMPLE_GRPC_METHOD
```eiffel
require
    name_not_empty: not a_name.is_empty
ensure
    result_created: Result /= Void
    is_client_streaming: Result.is_client_streaming
```

#### new_bidirectional_method (...): SIMPLE_GRPC_METHOD
```eiffel
require
    name_not_empty: not a_name.is_empty
ensure
    result_created: Result /= Void
    is_bidirectional: Result.is_bidirectional
```

### Message Factory Contracts

#### new_message: SIMPLE_PROTOBUF_MESSAGE
```eiffel
ensure
    result_created: Result /= Void
```

#### new_message_with_name (a_name): SIMPLE_PROTOBUF_MESSAGE
```eiffel
require
    name_not_empty: not a_name.is_empty
ensure
    result_created: Result /= Void
```

### Protobuf Field Contracts

#### new_protobuf_field_int32 (a_number, a_value): SIMPLE_PROTOBUF_FIELD
```eiffel
require
    valid_number: a_number >= 1
ensure
    result_created: Result /= Void
```

#### new_protobuf_field_string (a_number, a_value): SIMPLE_PROTOBUF_FIELD
```eiffel
require
    valid_number: a_number >= 1
ensure
    result_created: Result /= Void
```

#### new_protobuf_field_bool (a_number, a_value): SIMPLE_PROTOBUF_FIELD
```eiffel
require
    valid_number: a_number >= 1
ensure
    result_created: Result /= Void
```

### Status Factory Contracts

#### new_status_ok: SIMPLE_GRPC_STATUS
```eiffel
ensure
    result_created: Result /= Void
    is_ok: Result.is_ok
```

#### new_status (a_code, a_message): SIMPLE_GRPC_STATUS
```eiffel
require
    valid_code: a_code >= 0 and a_code <= 16
ensure
    result_created: Result /= Void
```

#### new_status_error (a_code, a_message): SIMPLE_GRPC_STATUS
```eiffel
require
    is_error_code: a_code > 0 and a_code <= 16
ensure
    result_created: Result /= Void
    is_error: Result.is_error
```

### HTTP/2 Frame Contracts

#### new_http2_data_frame (a_stream_id, a_data, a_end_stream): SIMPLE_HTTP2_FRAME
```eiffel
require
    valid_stream_id: a_stream_id > 0
ensure
    result_created: Result /= Void
    is_data: Result.is_data
```

#### new_http2_headers_frame (a_stream_id, a_headers, a_end_stream): SIMPLE_HTTP2_FRAME
```eiffel
require
    valid_stream_id: a_stream_id > 0
ensure
    result_created: Result /= Void
    is_headers: Result.is_headers
```

#### new_http2_settings_ack: SIMPLE_HTTP2_FRAME
```eiffel
ensure
    result_created: Result /= Void
    is_settings: Result.is_settings
    is_ack: Result.is_ack
```

---

## SIMPLE_GRPC_CHANNEL Contracts

### Creation Contracts

#### make (a_host, a_port)
```eiffel
require
    host_not_empty: not a_host.is_empty
    valid_port: a_port > 0 and a_port <= 65535
ensure
    host_set: host.same_string (a_host)
    port_set: port = a_port
    state_idle: state = state_idle
```

### Configuration Contracts

#### set_plaintext
```eiffel
require
    not_connected: state = state_idle
ensure
    is_plaintext: is_plaintext
```

#### set_tls
```eiffel
require
    not_connected: state = state_idle
ensure
    not_plaintext: not is_plaintext
```

#### set_default_timeout (a_timeout_ms)
```eiffel
require
    valid_timeout: a_timeout_ms >= 0
ensure
    timeout_set: default_timeout_ms = a_timeout_ms
```

### Service Registration Contracts

#### register_service (a_service)
```eiffel
require
    service_not_void: a_service /= Void
ensure
    service_registered: services.has (a_service.name)
```

### Connection Contracts

#### connect
```eiffel
require
    not_connected: state = state_idle
ensure
    is_ready: is_ready
```

#### shutdown
```eiffel
ensure
    is_shutdown: is_shutdown
```

### Call Creation Contracts

#### new_call (a_service, a_method_name): detachable SIMPLE_GRPC_CALL
```eiffel
require
    service_not_void: a_service /= Void
    method_exists: a_service.has_method (a_method_name)
```

---

## SIMPLE_GRPC_SERVICE Contracts

#### make (a_name)
```eiffel
require
    name_not_empty: not a_name.is_empty
ensure
    name_set: name.same_string (a_name)
```

#### add_method (a_method)
```eiffel
require
    method_not_void: a_method /= Void
ensure
    method_added: methods.has (a_method.name)
```

#### add_unary_method (a_name, a_request_type, a_response_type)
```eiffel
require
    name_not_empty: not a_name.is_empty
```

---

## SIMPLE_PROTOBUF Contracts

### Encoding Contracts

#### encode_tag (a_field_number, a_wire_type)
```eiffel
require
    valid_field: a_field_number >= 1
    valid_wire_type: a_wire_type >= 0 and a_wire_type <= 5
```

### Decoding Contracts

#### decode_tag: TUPLE [field_number: INTEGER; wire_type: INTEGER]
```eiffel
require
    has_more: has_more
```

#### decode_varint_32: INTEGER
```eiffel
require
    has_more: has_more
```

#### decode_fixed32: NATURAL_32
```eiffel
require
    has_enough_fixed32: size >= 4
```

#### decode_fixed64: NATURAL_64
```eiffel
require
    has_enough_fixed64: size >= 8
```

---

## Class Invariants

### SIMPLE_GRPC_CHANNEL
```eiffel
invariant
    host_not_empty: not host.is_empty
    valid_port: port > 0 and port <= 65535
    valid_state: state >= state_idle and state <= state_shutdown
    services_attached: services /= Void
    default_metadata_attached: default_metadata /= Void
    odd_stream_id: next_stream_id \\ 2 = 1
```

### SIMPLE_GRPC_SERVICE
```eiffel
invariant
    name_not_empty: not name.is_empty
    methods_attached: methods /= Void
```

### SIMPLE_PROTOBUF
```eiffel
invariant
    buffer_attached: buffer /= Void
```

### SIMPLE_GRAPH_EDGE (referenced in graph)
```eiffel
invariant
    valid_to_node: to_node > 0
```
