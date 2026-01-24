# S04 - Feature Specifications

**Library:** simple_grpc
**Status:** BACKWASH (reverse-engineered from implementation)
**Generated:** 2026-01-23

## SIMPLE_GRPC Features (Facade)

### Initialization

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | () | Create gRPC facade |

### Channel Factory

| Feature | Returns | Description |
|---------|---------|-------------|
| new_channel (a_host, a_port) | SIMPLE_GRPC_CHANNEL | Create channel |
| new_plaintext_channel (a_host, a_port) | SIMPLE_GRPC_CHANNEL | Create plaintext channel |

### Service Factory

| Feature | Returns | Description |
|---------|---------|-------------|
| new_service (a_name) | SIMPLE_GRPC_SERVICE | Create service definition |

### Method Factory

| Feature | Returns | Description |
|---------|---------|-------------|
| new_unary_method (...) | SIMPLE_GRPC_METHOD | Create unary method |
| new_server_streaming_method (...) | SIMPLE_GRPC_METHOD | Create server streaming method |
| new_client_streaming_method (...) | SIMPLE_GRPC_METHOD | Create client streaming method |
| new_bidirectional_method (...) | SIMPLE_GRPC_METHOD | Create bidirectional method |

### Message Factory

| Feature | Returns | Description |
|---------|---------|-------------|
| new_message | SIMPLE_PROTOBUF_MESSAGE | Create empty message |
| new_message_with_name (a_name) | SIMPLE_PROTOBUF_MESSAGE | Create named message |

### Protobuf Factory

| Feature | Returns | Description |
|---------|---------|-------------|
| new_protobuf | SIMPLE_PROTOBUF | Create encoder/decoder |
| new_protobuf_field_int32 (n, v) | SIMPLE_PROTOBUF_FIELD | Create int32 field |
| new_protobuf_field_string (n, v) | SIMPLE_PROTOBUF_FIELD | Create string field |
| new_protobuf_field_bool (n, v) | SIMPLE_PROTOBUF_FIELD | Create bool field |

### Status Factory

| Feature | Returns | Description |
|---------|---------|-------------|
| new_status_ok | SIMPLE_GRPC_STATUS | Create OK status |
| new_status (code, msg) | SIMPLE_GRPC_STATUS | Create status with code |
| new_status_error (code, msg) | SIMPLE_GRPC_STATUS | Create error status |

### Metadata Factory

| Feature | Returns | Description |
|---------|---------|-------------|
| new_metadata | SIMPLE_GRPC_METADATA | Create empty metadata |

### HTTP/2 Frame Factory

| Feature | Returns | Description |
|---------|---------|-------------|
| new_http2_data_frame (stream, data, end) | SIMPLE_HTTP2_FRAME | Create DATA frame |
| new_http2_headers_frame (stream, hdrs, end) | SIMPLE_HTTP2_FRAME | Create HEADERS frame |
| new_http2_settings_frame (settings) | SIMPLE_HTTP2_FRAME | Create SETTINGS frame |
| new_http2_settings_ack | SIMPLE_HTTP2_FRAME | Create SETTINGS ACK |

### Status Code Constants

| Constant | Value | Description |
|----------|-------|-------------|
| status_ok | 0 | Success |
| status_cancelled | 1 | Cancelled by client |
| status_unknown | 2 | Unknown error |
| status_invalid_argument | 3 | Invalid argument |
| status_deadline_exceeded | 4 | Timeout |
| status_not_found | 5 | Resource not found |
| status_already_exists | 6 | Resource already exists |
| status_permission_denied | 7 | Permission denied |
| status_resource_exhausted | 8 | Resource exhausted |
| status_failed_precondition | 9 | Precondition failed |
| status_aborted | 10 | Operation aborted |
| status_out_of_range | 11 | Value out of range |
| status_unimplemented | 12 | Not implemented |
| status_internal | 13 | Internal error |
| status_unavailable | 14 | Service unavailable |
| status_data_loss | 15 | Data loss |
| status_unauthenticated | 16 | Not authenticated |

---

## SIMPLE_GRPC_CHANNEL Features

### Initialization

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | (a_host, a_port) | Create channel |

### Access

| Feature | Returns | Description |
|---------|---------|-------------|
| host | STRING | Server hostname |
| port | INTEGER | Server port |
| state | INTEGER | Current state |
| services | HASH_TABLE [...] | Registered services |
| default_metadata | SIMPLE_GRPC_METADATA | Default metadata |
| default_timeout_ms | INTEGER | Default timeout |
| authority | STRING | HTTP/2 :authority value |

### Status Queries

| Feature | Returns | Description |
|---------|---------|-------------|
| is_plaintext | BOOLEAN | Using plaintext? |
| is_ready | BOOLEAN | Ready for calls? |
| is_connected | BOOLEAN | Connected? |
| is_shutdown | BOOLEAN | Shut down? |

### Configuration

| Feature | Signature | Description |
|---------|-----------|-------------|
| set_plaintext | () | Use plaintext (no TLS) |
| set_tls | () | Use TLS |
| set_default_timeout | (a_timeout_ms) | Set default timeout |
| add_default_metadata | (a_key, a_value) | Add default metadata |

### Service Registration

| Feature | Signature | Description |
|---------|-----------|-------------|
| register_service | (a_service) | Register service |
| service | (a_name): detachable SIMPLE_GRPC_SERVICE | Get service by name |

### Connection

| Feature | Signature | Description |
|---------|-----------|-------------|
| connect | () | Connect to server |
| shutdown | () | Shut down channel |

### Call Creation

| Feature | Signature | Returns | Description |
|---------|-----------|---------|-------------|
| new_call | (a_service, a_method_name) | detachable SIMPLE_GRPC_CALL | Create call |
| new_unary_call | (a_service_name, a_method_name) | SIMPLE_GRPC_CALL | Create unary call |

### HTTP/2 Frame Generation

| Feature | Signature | Returns | Description |
|---------|-----------|---------|-------------|
| build_request_headers | (a_call) | SIMPLE_HTTP2_FRAME | Build HEADERS frame |
| build_data_frame | (stream, data, end) | SIMPLE_HTTP2_FRAME | Build DATA frame |

---

## SIMPLE_GRPC_SERVICE Features

### Initialization

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | (a_name) | Create service |

### Access

| Feature | Returns | Description |
|---------|---------|-------------|
| name | STRING | Service name (package.Service) |
| methods | HASH_TABLE [...] | Methods by name |
| method (a_name) | detachable SIMPLE_GRPC_METHOD | Get method |
| method_count | INTEGER | Number of methods |

### Element Change

| Feature | Signature | Description |
|---------|-----------|-------------|
| add_method | (a_method) | Add method |
| add_unary_method | (name, req, resp) | Add unary method |
| add_server_streaming_method | (name, req, resp) | Add server streaming |
| add_client_streaming_method | (name, req, resp) | Add client streaming |
| add_bidirectional_method | (name, req, resp) | Add bidirectional |
| remove_method | (a_name) | Remove method |

### Status

| Feature | Returns | Description |
|---------|---------|-------------|
| has_method (a_name) | BOOLEAN | Has method? |

### Conversion

| Feature | Returns | Description |
|---------|---------|-------------|
| method_path (a_method_name) | STRING | Full path /package.Service/Method |
| package_name | STRING | Package part of name |
| simple_name | STRING | Service name without package |

### Iteration

| Feature | Signature | Description |
|---------|-----------|-------------|
| do_all_methods | (a_action) | Execute for each method |

---

## SIMPLE_PROTOBUF Features

### Initialization

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | () | Create encoder/decoder |

### Wire Type Constants

| Constant | Value | Description |
|----------|-------|-------------|
| wire_type_varint | 0 | Variable-length integer |
| wire_type_i64 | 1 | 64-bit fixed |
| wire_type_len | 2 | Length-delimited |
| wire_type_i32 | 5 | 32-bit fixed |

### Buffer Access

| Feature | Returns | Description |
|---------|---------|-------------|
| buffer | ARRAYED_LIST [NATURAL_8] | Encoding buffer |
| to_bytes | ARRAY [NATURAL_8] | Get encoded bytes |
| to_string | STRING | Get as string |
| size | INTEGER | Current buffer size |
| has_more | BOOLEAN | More bytes to decode? |

### Buffer Operations

| Feature | Signature | Description |
|---------|-----------|-------------|
| clear | () | Clear buffer |

### Encoding: Tags

| Feature | Signature | Description |
|---------|-----------|-------------|
| encode_tag | (field_number, wire_type) | Encode field tag |

### Encoding: Varint

| Feature | Signature | Description |
|---------|-----------|-------------|
| encode_varint_32 | (a_value) | Encode 32-bit varint |
| encode_varint_64 | (a_value) | Encode 64-bit varint |
| encode_uint32 | (a_value) | Encode unsigned 32-bit |
| encode_uint64 | (a_value) | Encode unsigned 64-bit |

### Encoding: ZigZag

| Feature | Signature | Description |
|---------|-----------|-------------|
| encode_sint32 | (a_value) | Encode signed 32-bit (ZigZag) |
| encode_sint64 | (a_value) | Encode signed 64-bit (ZigZag) |

### Encoding: Fixed

| Feature | Signature | Description |
|---------|-----------|-------------|
| encode_fixed32 | (a_value) | Encode 32-bit fixed |
| encode_fixed64 | (a_value) | Encode 64-bit fixed |
| encode_sfixed32 | (a_value) | Encode signed 32-bit fixed |
| encode_sfixed64 | (a_value) | Encode signed 64-bit fixed |

### Encoding: Length-Delimited

| Feature | Signature | Description |
|---------|-----------|-------------|
| encode_bytes | (a_bytes) | Encode byte array |
| encode_string | (a_string) | Encode UTF-8 string |
| encode_bool | (a_value) | Encode boolean |

### Encoding: Fields (Tag + Value)

| Feature | Signature | Description |
|---------|-----------|-------------|
| encode_int32_field | (field, value) | Encode int32 with tag |
| encode_int64_field | (field, value) | Encode int64 with tag |
| encode_uint32_field | (field, value) | Encode uint32 with tag |
| encode_uint64_field | (field, value) | Encode uint64 with tag |
| encode_sint32_field | (field, value) | Encode sint32 with tag |
| encode_sint64_field | (field, value) | Encode sint64 with tag |
| encode_bool_field | (field, value) | Encode bool with tag |
| encode_string_field | (field, value) | Encode string with tag |
| encode_bytes_field | (field, value) | Encode bytes with tag |
| encode_fixed32_field | (field, value) | Encode fixed32 with tag |
| encode_fixed64_field | (field, value) | Encode fixed64 with tag |

### Decoding: Setup

| Feature | Signature | Description |
|---------|-----------|-------------|
| decode_from_bytes | (a_bytes) | Load bytes for decoding |
| decode_from_string | (a_string) | Load string for decoding |

### Decoding: Tags

| Feature | Returns | Description |
|---------|---------|-------------|
| decode_tag | TUPLE [field_number, wire_type] | Decode next tag |

### Decoding: Varint

| Feature | Returns | Description |
|---------|---------|-------------|
| decode_varint_32 | INTEGER | Decode as signed 32-bit |
| decode_varint_32_unsigned | NATURAL_32 | Decode as unsigned 32-bit |
| decode_varint_64 | INTEGER_64 | Decode as signed 64-bit |
| decode_varint_64_unsigned | NATURAL_64 | Decode as unsigned 64-bit |

### Decoding: ZigZag

| Feature | Returns | Description |
|---------|---------|-------------|
| decode_sint32 | INTEGER | Decode ZigZag 32-bit |
| decode_sint64 | INTEGER_64 | Decode ZigZag 64-bit |

### Decoding: Fixed

| Feature | Returns | Description |
|---------|---------|-------------|
| decode_fixed32 | NATURAL_32 | Decode 32-bit fixed |
| decode_fixed64 | NATURAL_64 | Decode 64-bit fixed |
| decode_sfixed32 | INTEGER | Decode signed 32-bit fixed |
| decode_sfixed64 | INTEGER_64 | Decode signed 64-bit fixed |

### Decoding: Length-Delimited

| Feature | Returns | Description |
|---------|---------|-------------|
| decode_string | STRING | Decode string |
| decode_bytes | ARRAY [NATURAL_8] | Decode bytes |
| decode_bool | BOOLEAN | Decode boolean |

### Decoding: Skip

| Feature | Signature | Description |
|---------|-----------|-------------|
| skip_field | (a_wire_type) | Skip unknown field |
