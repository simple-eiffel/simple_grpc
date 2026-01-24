# S01 - Project Inventory

**Library:** simple_grpc
**Version:** 1.0.0
**Status:** BACKWASH (reverse-engineered from implementation)
**Generated:** 2026-01-23

## Overview

simple_grpc provides a pure-Eiffel implementation of the gRPC protocol. It includes:
- gRPC client components (channels, services, methods, calls)
- Protocol Buffers encoding/decoding (wire format)
- HTTP/2 frame generation and parsing
- gRPC status codes and metadata

This is a **protocol-only implementation** - actual network I/O must be provided by integrating with socket libraries.

## Project Files

### Source Files (src/)

| File | Class | Description | LOC |
|------|-------|-------------|-----|
| simple_grpc.e | SIMPLE_GRPC | Main facade/factory class | ~310 |
| simple_grpc_channel.e | SIMPLE_GRPC_CHANNEL | Connection to gRPC server | ~315 |
| simple_grpc_service.e | SIMPLE_GRPC_SERVICE | Service definition | ~180 |
| simple_grpc_method.e | SIMPLE_GRPC_METHOD | RPC method definition | ~150 |
| simple_grpc_call.e | SIMPLE_GRPC_CALL | Active RPC invocation | ~200 |
| simple_grpc_status.e | SIMPLE_GRPC_STATUS | gRPC status codes | ~150 |
| simple_grpc_metadata.e | SIMPLE_GRPC_METADATA | Key-value metadata | ~100 |
| simple_protobuf.e | SIMPLE_PROTOBUF | Protobuf wire encoding | ~615 |
| simple_protobuf_message.e | SIMPLE_PROTOBUF_MESSAGE | Dynamic protobuf message | ~250 |
| simple_protobuf_field.e | SIMPLE_PROTOBUF_FIELD | Protobuf field definition | ~150 |
| simple_http2_frame.e | SIMPLE_HTTP2_FRAME | HTTP/2 frame handling | ~300 |

### Test Files (testing/)

| File | Description |
|------|-------------|
| test_app.e | Main test application entry point |
| lib_tests.e | Library test suite |

### Research Files (research/)

| File | Description |
|------|-------------|
| SIMPLE_GRPC_RESEARCH.md | 7-step research process documentation |

### Configuration Files

| File | Description |
|------|-------------|
| simple_grpc.ecf | ECF configuration |

## Dependencies

### ISE Libraries
- `$ISE_LIBRARY/library/base/base.ecf` - Base library (HASH_TABLE, ARRAYED_LIST, etc.)

### Simple Ecosystem Dependencies
- None (standalone implementation)

## Key Statistics

- **Total Source LOC:** ~2720
- **Number of Classes:** 11
- **Number of Features (SIMPLE_GRPC facade):** ~25
- **Streaming Support:** Unary, Server Streaming, Client Streaming, Bidirectional
- **gRPC Status Codes:** 17 (OK through UNAUTHENTICATED)

## Protocol Support

| Protocol | Version | Support |
|----------|---------|---------|
| gRPC | 1.0 | Full protocol layer |
| Protocol Buffers | proto3 wire format | Encoding/decoding |
| HTTP/2 | RFC 7540 | Frame generation/parsing |

## Phase Status

- Phase 1: Core functionality - COMPLETE
- Phase 2: Expanded features - IN PROGRESS
- Phase 3: Performance optimization - NOT STARTED
- Phase 4: API documentation - IN PROGRESS
- Phase 5: Test coverage - PARTIAL
- Phase 6: Production hardening - NOT STARTED
