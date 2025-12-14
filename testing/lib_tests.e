note
	description: "Tests for simple_grpc library"
	author: "Larry Rix"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Protocol Buffers Tests

	test_new_protobuf
			-- Test creating a protobuf encoder.
		local
			pb: SIMPLE_PROTOBUF
		do
			create pb.make
			assert ("buffer_created", pb.buffer /= Void)
			assert ("buffer_empty", pb.size = 0)
		end

	test_protobuf_varint_encoding
			-- Test varint encoding.
		local
			pb: SIMPLE_PROTOBUF
		do
			create pb.make
			pb.encode_varint_32 (1)
			assert ("single_byte", pb.size = 1)

			pb.clear
			pb.encode_varint_32 (150)
			assert ("two_bytes", pb.size = 2)

			pb.clear
			pb.encode_varint_32 (300)
			assert ("two_bytes_300", pb.size = 2)
		end

	test_protobuf_varint_decoding
			-- Test varint decoding.
		local
			pb: SIMPLE_PROTOBUF
			l_value: INTEGER
		do
			create pb.make
			pb.encode_varint_32 (150)

			pb.decode_from_bytes (pb.to_bytes)
			l_value := pb.decode_varint_32
			assert ("decoded_150", l_value = 150)
		end

	test_protobuf_zigzag_encoding
			-- Test ZigZag encoding for signed integers.
		local
			pb: SIMPLE_PROTOBUF
		do
			create pb.make

			-- Test positive
			pb.encode_sint32 (1)
			pb.decode_from_bytes (pb.to_bytes)
			assert ("positive_1", pb.decode_sint32 = 1)

			-- Test negative
			pb.clear
			pb.encode_sint32 (-1)
			pb.decode_from_bytes (pb.to_bytes)
			assert ("negative_1", pb.decode_sint32 = -1)

			-- Test larger negative
			pb.clear
			pb.encode_sint32 (-100)
			pb.decode_from_bytes (pb.to_bytes)
			assert ("negative_100", pb.decode_sint32 = -100)
		end

	test_protobuf_string_encoding
			-- Test string encoding.
		local
			pb: SIMPLE_PROTOBUF
			l_decoded: STRING
		do
			create pb.make
			pb.encode_string ("Hello")

			pb.decode_from_bytes (pb.to_bytes)
			l_decoded := pb.decode_string
			assert ("string_decoded", l_decoded.same_string ("Hello"))
		end

	test_protobuf_field_encoding
			-- Test field encoding with tags.
		local
			pb: SIMPLE_PROTOBUF
		do
			create pb.make
			pb.encode_int32_field (1, 150)
			assert ("field_encoded", pb.size > 0)
		end

	test_protobuf_fixed32
			-- Test fixed32 encoding/decoding.
		local
			pb: SIMPLE_PROTOBUF
			l_value: NATURAL_32
		do
			create pb.make
			pb.encode_fixed32 (0x12345678)
			assert ("fixed32_size", pb.size = 4)

			pb.decode_from_bytes (pb.to_bytes)
			l_value := pb.decode_fixed32
			assert ("fixed32_decoded", l_value = 0x12345678)
		end

feature -- Protobuf Message Tests

	test_new_message
			-- Test creating a protobuf message.
		local
			msg: SIMPLE_PROTOBUF_MESSAGE
		do
			create msg.make
			assert ("message_created", msg /= Void)
			assert ("no_fields", msg.fields.count = 0)
		end

	test_message_with_name
			-- Test creating named message.
		local
			msg: SIMPLE_PROTOBUF_MESSAGE
		do
			create msg.make_with_name ("helloworld.HelloRequest")
			assert ("name_set", msg.name.same_string ("helloworld.HelloRequest"))
		end

	test_message_set_fields
			-- Test setting message fields.
		local
			msg: SIMPLE_PROTOBUF_MESSAGE
		do
			create msg.make
			msg.set_int32 (1, 42)
			msg.set_string (2, "test")
			msg.set_bool (3, True)

			assert ("int32_value", msg.int32_value (1) = 42)
			assert ("string_value", msg.string_value (2).same_string ("test"))
			assert ("bool_value", msg.bool_value (3))
		end

	test_message_encode_decode
			-- Test encoding and decoding a message.
		local
			msg, decoded: SIMPLE_PROTOBUF_MESSAGE
			l_bytes: ARRAY [NATURAL_8]
		do
			create msg.make
			msg.set_int32 (1, 100)
			msg.set_string (2, "Hello World")

			l_bytes := msg.encode
			assert ("encoded", l_bytes.count > 0)

			create decoded.make
			decoded.decode (l_bytes)
			assert ("has_fields", decoded.fields.count > 0)
		end

feature -- Protobuf Field Tests

	test_new_field_int32
			-- Test creating int32 field.
		local
			field: SIMPLE_PROTOBUF_FIELD
		do
			create field.make_int32 (1, 42)
			assert ("number_set", field.number = 1)
			assert ("type_set", field.field_type = field.type_int32)
			assert ("is_varint", field.is_varint_type)
		end

	test_new_field_string
			-- Test creating string field.
		local
			field: SIMPLE_PROTOBUF_FIELD
		do
			create field.make_string (1, "test")
			assert ("type_string", field.field_type = field.type_string)
			assert ("is_length_delimited", field.is_length_delimited)
		end

	test_field_wire_type
			-- Test wire type calculation.
		local
			f_int, f_string, f_fixed32, f_fixed64: SIMPLE_PROTOBUF_FIELD
		do
			create f_int.make_int32 (1, 0)
			create f_string.make_string (1, "")
			create f_fixed32.make_fixed32 (1, 0)
			create f_fixed64.make_fixed64 (1, 0)

			assert ("int32_wire_0", f_int.wire_type = 0)
			assert ("string_wire_2", f_string.wire_type = 2)
			assert ("fixed32_wire_5", f_fixed32.wire_type = 5)
			assert ("fixed64_wire_1", f_fixed64.wire_type = 1)
		end

feature -- HTTP/2 Frame Tests

	test_new_http2_data_frame
			-- Test creating DATA frame.
		local
			frame: SIMPLE_HTTP2_FRAME
			l_data: ARRAY [NATURAL_8]
		do
			create l_data.make_filled (65, 1, 5)  -- "AAAAA"
			create frame.make_data (1, l_data, True)

			assert ("is_data", frame.is_data)
			assert ("stream_id", frame.stream_id = 1)
			assert ("end_stream", frame.is_end_stream)
			assert ("payload_size", frame.length = 5)
		end

	test_new_http2_headers_frame
			-- Test creating HEADERS frame.
		local
			frame: SIMPLE_HTTP2_FRAME
			l_headers: ARRAY [NATURAL_8]
		do
			create l_headers.make_filled (0, 1, 10)
			create frame.make_headers (1, l_headers, False, True)

			assert ("is_headers", frame.is_headers)
			assert ("end_headers", frame.is_end_headers)
			assert ("not_end_stream", not frame.is_end_stream)
		end

	test_http2_frame_encode_decode
			-- Test frame encoding and decoding.
		local
			frame, decoded: SIMPLE_HTTP2_FRAME
			l_data, l_encoded: ARRAY [NATURAL_8]
		do
			create l_data.make_filled (42, 1, 10)
			create frame.make_data (3, l_data, True)

			l_encoded := frame.encode
			assert ("encoded_size", l_encoded.count = 19)  -- 9 header + 10 payload

			create decoded.make (0, 0, 0, Void)
			assert ("decode_success", decoded.decode (l_encoded))
			assert ("decoded_type", decoded.frame_type = frame.type_data)
			assert ("decoded_stream", decoded.stream_id = 3)
			assert ("decoded_flags", decoded.is_end_stream)
		end

	test_http2_settings_frame
			-- Test creating SETTINGS frame.
		local
			frame: SIMPLE_HTTP2_FRAME
			l_settings: ARRAY [TUPLE [id: INTEGER; value: INTEGER]]
		do
			l_settings := <<[1, 4096], [3, 100]>>
			create frame.make_settings (l_settings, False)

			assert ("is_settings", frame.is_settings)
			assert ("not_ack", not frame.is_ack)
			assert ("payload_12", frame.length = 12)  -- 2 settings * 6 bytes
		end

	test_http2_window_update
			-- Test creating WINDOW_UPDATE frame.
		local
			frame: SIMPLE_HTTP2_FRAME
		do
			create frame.make_window_update (0, 65535)
			assert ("type_window_update", frame.frame_type = frame.type_window_update)
			assert ("payload_4", frame.length = 4)
		end

feature -- gRPC Status Tests

	test_new_status_ok
			-- Test creating OK status.
		local
			status: SIMPLE_GRPC_STATUS
		do
			create status.make_ok
			assert ("is_ok", status.is_ok)
			assert ("not_error", not status.is_error)
			assert ("code_0", status.code = 0)
		end

	test_new_status_error
			-- Test creating error status.
		local
			status: SIMPLE_GRPC_STATUS
		do
			create status.make_error (3, "Invalid argument")
			assert ("is_error", status.is_error)
			assert ("not_ok", not status.is_ok)
			assert ("code_3", status.code = 3)
			assert ("message", status.message.same_string ("Invalid argument"))
		end

	test_status_code_names
			-- Test status code names.
		local
			status: SIMPLE_GRPC_STATUS
		do
			create status.make (0, "")
			assert ("ok_name", status.code_name.same_string ("OK"))

			create status.make (1, "")
			assert ("cancelled_name", status.code_name.same_string ("CANCELLED"))

			create status.make (14, "")
			assert ("unavailable_name", status.code_name.same_string ("UNAVAILABLE"))
		end

	test_status_retryable
			-- Test retryable status codes.
		local
			unavailable, internal: SIMPLE_GRPC_STATUS
		do
			create unavailable.make (14, "")
			create internal.make (13, "")

			assert ("unavailable_retryable", unavailable.is_retryable)
			assert ("internal_not_retryable", not internal.is_retryable)
		end

feature -- gRPC Metadata Tests

	test_new_metadata
			-- Test creating metadata.
		local
			md: SIMPLE_GRPC_METADATA
		do
			create md.make
			assert ("is_empty", md.is_empty)
			assert ("count_0", md.count = 0)
		end

	test_metadata_put_get
			-- Test putting and getting metadata.
		local
			md: SIMPLE_GRPC_METADATA
		do
			create md.make
			md.put ("content-type", "application/grpc")
			md.put ("authorization", "Bearer token123")

			assert ("has_content_type", md.has ("content-type"))
			assert ("content_type_value", attached md.value ("content-type") as v and then v.same_string ("application/grpc"))
			assert ("count_2", md.count = 2)
		end

	test_metadata_binary_key
			-- Test binary key detection.
		local
			md: SIMPLE_GRPC_METADATA
		do
			create md.make
			assert ("is_binary", md.is_binary_key ("grpc-trace-bin"))
			assert ("not_binary", not md.is_binary_key ("content-type"))
		end

feature -- gRPC Method Tests

	test_new_unary_method
			-- Test creating unary method.
		local
			method: SIMPLE_GRPC_METHOD
		do
			create method.make_unary ("SayHello", "HelloRequest", "HelloReply")
			assert ("name_set", method.name.same_string ("SayHello"))
			assert ("is_unary", method.is_unary)
			assert ("not_streaming", not method.is_streaming)
		end

	test_new_server_streaming_method
			-- Test creating server streaming method.
		local
			method: SIMPLE_GRPC_METHOD
		do
			create method.make_server_streaming ("ListFeatures", "Rectangle", "Feature")
			assert ("is_server_streaming", method.is_server_streaming)
			assert ("has_streaming_response", method.has_streaming_response)
			assert ("no_streaming_request", not method.has_streaming_request)
		end

	test_new_bidirectional_method
			-- Test creating bidirectional method.
		local
			method: SIMPLE_GRPC_METHOD
		do
			create method.make_bidirectional ("RouteChat", "RouteNote", "RouteNote")
			assert ("is_bidirectional", method.is_bidirectional)
			assert ("has_both_streaming", method.has_streaming_request and method.has_streaming_response)
		end

	test_method_full_name
			-- Test generating full method name.
		local
			method: SIMPLE_GRPC_METHOD
		do
			create method.make_unary ("SayHello", "", "")
			assert ("full_name", method.full_name ("helloworld.Greeter").same_string ("/helloworld.Greeter/SayHello"))
		end

feature -- gRPC Service Tests

	test_new_service
			-- Test creating service.
		local
			service: SIMPLE_GRPC_SERVICE
		do
			create service.make ("helloworld.Greeter")
			assert ("name_set", service.name.same_string ("helloworld.Greeter"))
			assert ("no_methods", service.method_count = 0)
		end

	test_service_add_methods
			-- Test adding methods to service.
		local
			service: SIMPLE_GRPC_SERVICE
		do
			create service.make ("routeguide.RouteGuide")
			service.add_unary_method ("GetFeature", "Point", "Feature")
			service.add_server_streaming_method ("ListFeatures", "Rectangle", "Feature")
			service.add_client_streaming_method ("RecordRoute", "Point", "RouteSummary")
			service.add_bidirectional_method ("RouteChat", "RouteNote", "RouteNote")

			assert ("method_count_4", service.method_count = 4)
			assert ("has_get_feature", service.has_method ("GetFeature"))
			assert ("has_list_features", service.has_method ("ListFeatures"))
		end

	test_service_method_path
			-- Test method path generation.
		local
			service: SIMPLE_GRPC_SERVICE
		do
			create service.make ("helloworld.Greeter")
			assert ("path", service.method_path ("SayHello").same_string ("/helloworld.Greeter/SayHello"))
		end

	test_service_package_name
			-- Test extracting package name.
		local
			service: SIMPLE_GRPC_SERVICE
		do
			create service.make ("helloworld.Greeter")
			assert ("package", service.package_name.same_string ("helloworld"))
			assert ("simple", service.simple_name.same_string ("Greeter"))
		end

feature -- gRPC Channel Tests

	test_new_channel
			-- Test creating channel.
		local
			channel: SIMPLE_GRPC_CHANNEL
		do
			create channel.make ("localhost", 50051)
			assert ("host_set", channel.host.same_string ("localhost"))
			assert ("port_set", channel.port = 50051)
			assert ("is_idle", channel.state = channel.state_idle)
		end

	test_channel_plaintext
			-- Test plaintext channel configuration.
		local
			channel: SIMPLE_GRPC_CHANNEL
		do
			create channel.make ("localhost", 50051)
			channel.set_plaintext
			assert ("is_plaintext", channel.is_plaintext)
		end

	test_channel_authority
			-- Test authority header generation.
		local
			channel: SIMPLE_GRPC_CHANNEL
		do
			create channel.make ("example.com", 443)
			assert ("authority_no_port", channel.authority.same_string ("example.com"))

			create channel.make ("example.com", 8080)
			assert ("authority_with_port", channel.authority.same_string ("example.com:8080"))
		end

	test_channel_connect
			-- Test channel connection.
		local
			channel: SIMPLE_GRPC_CHANNEL
		do
			create channel.make ("localhost", 50051)
			channel.connect
			assert ("is_ready", channel.is_ready)
		end

feature -- gRPC Call Tests

	test_new_call
			-- Test creating call.
		local
			method: SIMPLE_GRPC_METHOD
			call: SIMPLE_GRPC_CALL
		do
			create method.make_unary ("SayHello", "HelloRequest", "HelloReply")
			create call.make (method, "helloworld.Greeter")

			assert ("method_set", call.method = method)
			assert ("state_created", call.state = call.state_created)
		end

	test_call_path
			-- Test call path generation.
		local
			method: SIMPLE_GRPC_METHOD
			call: SIMPLE_GRPC_CALL
		do
			create method.make_unary ("SayHello", "", "")
			create call.make (method, "helloworld.Greeter")
			assert ("path", call.path.same_string ("/helloworld.Greeter/SayHello"))
		end

	test_call_grpc_message_framing
			-- Test gRPC message framing.
		local
			method: SIMPLE_GRPC_METHOD
			call: SIMPLE_GRPC_CALL
			msg: SIMPLE_PROTOBUF_MESSAGE
			l_encoded: ARRAY [NATURAL_8]
		do
			create method.make_unary ("Test", "", "")
			create call.make (method, "test.Service")

			create msg.make
			msg.set_string (1, "Hello")

			l_encoded := call.encode_grpc_message (msg)
			assert ("has_framing", l_encoded.count >= 5)
			assert ("no_compression", l_encoded.item (1) = 0)
		end

feature -- gRPC Facade Tests

	test_facade_new_channel
			-- Test facade channel creation.
		local
			grpc: SIMPLE_GRPC
			channel: SIMPLE_GRPC_CHANNEL
		do
			create grpc.make
			channel := grpc.new_channel ("localhost", 50051)
			assert ("channel_created", channel /= Void)
		end

	test_facade_new_service
			-- Test facade service creation.
		local
			grpc: SIMPLE_GRPC
			service: SIMPLE_GRPC_SERVICE
		do
			create grpc.make
			service := grpc.new_service ("helloworld.Greeter")
			assert ("service_created", service /= Void)
		end

	test_facade_new_message
			-- Test facade message creation.
		local
			grpc: SIMPLE_GRPC
			msg: SIMPLE_PROTOBUF_MESSAGE
		do
			create grpc.make
			msg := grpc.new_message
			assert ("message_created", msg /= Void)
		end

	test_facade_new_status
			-- Test facade status creation.
		local
			grpc: SIMPLE_GRPC
			status: SIMPLE_GRPC_STATUS
		do
			create grpc.make
			status := grpc.new_status_ok
			assert ("status_ok", status.is_ok)

			status := grpc.new_status_error (3, "Bad request")
			assert ("status_error", status.is_error)
		end

end
