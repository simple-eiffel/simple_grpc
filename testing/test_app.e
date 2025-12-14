note
	description: "Test application for simple_grpc"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		local
			tests: LIB_TESTS
		do
			create tests
			io.put_string ("simple_grpc test runner%N")
			io.put_string ("========================%N%N")

			passed := 0
			failed := 0

			-- Protocol Buffers Tests
			io.put_string ("Protocol Buffers Tests%N")
			io.put_string ("----------------------%N")
			run_test (agent tests.test_new_protobuf, "test_new_protobuf")
			run_test (agent tests.test_protobuf_varint_encoding, "test_protobuf_varint_encoding")
			run_test (agent tests.test_protobuf_varint_decoding, "test_protobuf_varint_decoding")
			run_test (agent tests.test_protobuf_zigzag_encoding, "test_protobuf_zigzag_encoding")
			run_test (agent tests.test_protobuf_string_encoding, "test_protobuf_string_encoding")
			run_test (agent tests.test_protobuf_field_encoding, "test_protobuf_field_encoding")
			run_test (agent tests.test_protobuf_fixed32, "test_protobuf_fixed32")

			-- Protobuf Message Tests
			io.put_string ("%NProtobuf Message Tests%N")
			io.put_string ("----------------------%N")
			run_test (agent tests.test_new_message, "test_new_message")
			run_test (agent tests.test_message_with_name, "test_message_with_name")
			run_test (agent tests.test_message_set_fields, "test_message_set_fields")
			run_test (agent tests.test_message_encode_decode, "test_message_encode_decode")

			-- Protobuf Field Tests
			io.put_string ("%NProtobuf Field Tests%N")
			io.put_string ("--------------------%N")
			run_test (agent tests.test_new_field_int32, "test_new_field_int32")
			run_test (agent tests.test_new_field_string, "test_new_field_string")
			run_test (agent tests.test_field_wire_type, "test_field_wire_type")

			-- HTTP/2 Frame Tests
			io.put_string ("%NHTTP/2 Frame Tests%N")
			io.put_string ("------------------%N")
			run_test (agent tests.test_new_http2_data_frame, "test_new_http2_data_frame")
			run_test (agent tests.test_new_http2_headers_frame, "test_new_http2_headers_frame")
			run_test (agent tests.test_http2_frame_encode_decode, "test_http2_frame_encode_decode")
			run_test (agent tests.test_http2_settings_frame, "test_http2_settings_frame")
			run_test (agent tests.test_http2_window_update, "test_http2_window_update")

			-- gRPC Status Tests
			io.put_string ("%NgRPC Status Tests%N")
			io.put_string ("-----------------%N")
			run_test (agent tests.test_new_status_ok, "test_new_status_ok")
			run_test (agent tests.test_new_status_error, "test_new_status_error")
			run_test (agent tests.test_status_code_names, "test_status_code_names")
			run_test (agent tests.test_status_retryable, "test_status_retryable")

			-- gRPC Metadata Tests
			io.put_string ("%NgRPC Metadata Tests%N")
			io.put_string ("-------------------%N")
			run_test (agent tests.test_new_metadata, "test_new_metadata")
			run_test (agent tests.test_metadata_put_get, "test_metadata_put_get")
			run_test (agent tests.test_metadata_binary_key, "test_metadata_binary_key")

			-- gRPC Method Tests
			io.put_string ("%NgRPC Method Tests%N")
			io.put_string ("-----------------%N")
			run_test (agent tests.test_new_unary_method, "test_new_unary_method")
			run_test (agent tests.test_new_server_streaming_method, "test_new_server_streaming_method")
			run_test (agent tests.test_new_bidirectional_method, "test_new_bidirectional_method")
			run_test (agent tests.test_method_full_name, "test_method_full_name")

			-- gRPC Service Tests
			io.put_string ("%NgRPC Service Tests%N")
			io.put_string ("------------------%N")
			run_test (agent tests.test_new_service, "test_new_service")
			run_test (agent tests.test_service_add_methods, "test_service_add_methods")
			run_test (agent tests.test_service_method_path, "test_service_method_path")
			run_test (agent tests.test_service_package_name, "test_service_package_name")

			-- gRPC Channel Tests
			io.put_string ("%NgRPC Channel Tests%N")
			io.put_string ("------------------%N")
			run_test (agent tests.test_new_channel, "test_new_channel")
			run_test (agent tests.test_channel_plaintext, "test_channel_plaintext")
			run_test (agent tests.test_channel_authority, "test_channel_authority")
			run_test (agent tests.test_channel_connect, "test_channel_connect")

			-- gRPC Call Tests
			io.put_string ("%NgRPC Call Tests%N")
			io.put_string ("----------------%N")
			run_test (agent tests.test_new_call, "test_new_call")
			run_test (agent tests.test_call_path, "test_call_path")
			run_test (agent tests.test_call_grpc_message_framing, "test_call_grpc_message_framing")

			-- gRPC Facade Tests
			io.put_string ("%NgRPC Facade Tests%N")
			io.put_string ("-----------------%N")
			run_test (agent tests.test_facade_new_channel, "test_facade_new_channel")
			run_test (agent tests.test_facade_new_service, "test_facade_new_service")
			run_test (agent tests.test_facade_new_message, "test_facade_new_message")
			run_test (agent tests.test_facade_new_status, "test_facade_new_status")

			io.put_string ("%N========================%N")
			io.put_string ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				io.put_string ("TESTS FAILED%N")
			else
				io.put_string ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				io.put_string ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			io.put_string ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
