# simple_grpc

gRPC protocol implementation for Eiffel with Protocol Buffers, HTTP/2 framing, and streaming RPC support.

## Features

- **Protocol Buffers**: Wire format encoding/decoding (varint, fixed, length-delimited, ZigZag)
- **HTTP/2 Framing**: DATA, HEADERS, SETTINGS, WINDOW_UPDATE, PING, GOAWAY frames
- **gRPC Protocol**: Service definitions, method types, status codes, metadata
- **Streaming Support**: Unary, server streaming, client streaming, bidirectional

## Installation

Add to your ECF:

```xml
<library name="simple_grpc" location="$SIMPLE_GRPC\simple_grpc.ecf"/>
```

## Quick Start

```eiffel
local
    grpc: SIMPLE_GRPC
    channel: SIMPLE_GRPC_CHANNEL
    service: SIMPLE_GRPC_SERVICE
    call: SIMPLE_GRPC_CALL
    request: SIMPLE_PROTOBUF_MESSAGE
do
    create grpc.make

    -- Create channel
    channel := grpc.new_channel ("localhost", 50051)
    channel.set_plaintext
    channel.connect

    -- Define service
    service := grpc.new_service ("helloworld.Greeter")
    service.add_unary_method ("SayHello", "HelloRequest", "HelloReply")

    -- Create request message
    request := grpc.new_message
    request.set_string (1, "World")  -- name field

    -- Make call
    if attached channel.new_call (service, "SayHello") as c then
        c.set_request (request)
        c.start
        -- In real use, send/receive via socket
    end
end
```

## Protocol Buffers

Encode and decode Protocol Buffers messages:

```eiffel
local
    pb: SIMPLE_PROTOBUF
    msg: SIMPLE_PROTOBUF_MESSAGE
do
    -- Low-level encoding
    create pb.make
    pb.encode_int32_field (1, 42)
    pb.encode_string_field (2, "Hello")

    -- High-level message
    create msg.make_with_name ("MyMessage")
    msg.set_int32 (1, 42)
    msg.set_string (2, "Hello")
    msg.set_bool (3, True)

    -- Encode to bytes
    bytes := msg.encode
end
```

## HTTP/2 Frames

Create HTTP/2 frames for transport:

```eiffel
local
    frame: SIMPLE_HTTP2_FRAME
do
    -- DATA frame
    create frame.make_data (stream_id, payload, end_stream)

    -- HEADERS frame
    create frame.make_headers (stream_id, headers, end_stream, end_headers)

    -- SETTINGS frame
    create frame.make_settings (<<[1, 4096], [3, 100]>>, ack)
end
```

## gRPC Status Codes

```eiffel
status_ok: INTEGER = 0
status_cancelled: INTEGER = 1
status_unknown: INTEGER = 2
status_invalid_argument: INTEGER = 3
status_deadline_exceeded: INTEGER = 4
status_not_found: INTEGER = 5
status_already_exists: INTEGER = 6
status_permission_denied: INTEGER = 7
status_resource_exhausted: INTEGER = 8
status_failed_precondition: INTEGER = 9
status_aborted: INTEGER = 10
status_out_of_range: INTEGER = 11
status_unimplemented: INTEGER = 12
status_internal: INTEGER = 13
status_unavailable: INTEGER = 14
status_data_loss: INTEGER = 15
status_unauthenticated: INTEGER = 16
```

## Method Types

```eiffel
-- Unary: single request -> single response
service.add_unary_method ("GetUser", "GetUserRequest", "User")

-- Server streaming: single request -> stream of responses
service.add_server_streaming_method ("ListUsers", "ListUsersRequest", "User")

-- Client streaming: stream of requests -> single response
service.add_client_streaming_method ("RecordData", "DataPoint", "Summary")

-- Bidirectional: stream <-> stream
service.add_bidirectional_method ("Chat", "Message", "Message")
```

## Classes

| Class | Description |
|-------|-------------|
| `SIMPLE_GRPC` | Main facade with factory methods |
| `SIMPLE_GRPC_CHANNEL` | Connection to gRPC server |
| `SIMPLE_GRPC_SERVICE` | Service definition container |
| `SIMPLE_GRPC_METHOD` | RPC method definition |
| `SIMPLE_GRPC_CALL` | Active RPC invocation |
| `SIMPLE_GRPC_STATUS` | Status codes and handling |
| `SIMPLE_GRPC_METADATA` | Headers and trailers |
| `SIMPLE_PROTOBUF` | Wire format encoder/decoder |
| `SIMPLE_PROTOBUF_MESSAGE` | Dynamic message container |
| `SIMPLE_PROTOBUF_FIELD` | Field definition |
| `SIMPLE_HTTP2_FRAME` | HTTP/2 frame structure |

## Limitations (Phase 1)

- No TLS support (plaintext only)
- No HPACK header compression
- No actual network I/O (protocol layer only)
- No .proto file parsing

## License

MIT License - Copyright (c) 2025, Larry Rix
