# Drift Analysis: simple_grpc

Generated: 2026-01-24
Method: `ec.exe -flatshort` vs `specs/*.md` + `research/*.md`

## Specification Sources

| Source | Files | Lines |
|--------|-------|-------|
| specs/*.md | 8 | 1724 |
| research/*.md | 1 | 222 |

## Classes Analyzed

| Class | Spec'd Features | Actual Features | Drift |
|-------|-----------------|-----------------|-------|
| SIMPLE_GRPC | 19 | 58 | +39 |

## Feature-Level Drift

### Specified, Implemented ✓
- `new_channel` ✓
- `new_http2_data_frame` ✓
- `new_http2_headers_frame` ✓
- `new_message` ✓
- `new_message_with_name` ✓
- `new_metadata` ✓
- `new_plaintext_channel` ✓
- `new_protobuf` ✓
- `new_server_streaming_method` ✓
- `new_service` ✓
- ... and 4 more

### Specified, NOT Implemented ✗
- `state_connecting` ✗
- `state_idle` ✗
- `state_ready` ✗
- `state_shutdown` ✗
- `state_transient_failure` ✗

### Implemented, NOT Specified
- `Io`
- `Operating_environment`
- `Status_aborted`
- `Status_already_exists`
- `Status_cancelled`
- `Status_data_loss`
- `Status_deadline_exceeded`
- `Status_failed_precondition`
- `Status_internal`
- `Status_invalid_argument`
- ... and 34 more

## Summary

| Category | Count |
|----------|-------|
| Spec'd, implemented | 14 |
| Spec'd, missing | 5 |
| Implemented, not spec'd | 44 |
| **Overall Drift** | **HIGH** |

## Conclusion

**simple_grpc** has high drift. Significant gaps between spec and implementation.
