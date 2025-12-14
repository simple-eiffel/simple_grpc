note
	description: "[
		gRPC protocol facade for Eiffel.

		Provides factory methods for gRPC components:
		- Channels: Connection to gRPC servers
		- Services: Service definitions with methods
		- Methods: RPC method definitions
		- Calls: Active RPC invocations
		- Messages: Protocol Buffers messages
		- Status: gRPC status codes

		Example usage:
			grpc := create {SIMPLE_GRPC}.make

			-- Create channel
			channel := grpc.new_channel ("localhost", 50051)
			channel.set_plaintext
			channel.connect

			-- Create service
			service := grpc.new_service ("helloworld.Greeter")
			service.add_unary_method ("SayHello", "HelloRequest", "HelloReply")

			-- Create and execute call
			call := channel.new_call (service, "SayHello")
			request := grpc.new_message
			request.set_string (1, "World")
			call.set_request (request)
			call.start
			...
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_GRPC

create
	make

feature {NONE} -- Initialization

	make
			-- Create gRPC facade.
		do
			-- Nothing to initialize
		end

feature -- Channel Factory

	new_channel (a_host: READABLE_STRING_8; a_port: INTEGER): SIMPLE_GRPC_CHANNEL
			-- Create a new channel to host:port.
		require
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port <= 65535
		do
			create Result.make (a_host, a_port)
		ensure
			result_created: Result /= Void
		end

	new_plaintext_channel (a_host: READABLE_STRING_8; a_port: INTEGER): SIMPLE_GRPC_CHANNEL
			-- Create a new plaintext channel.
		require
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port <= 65535
		do
			create Result.make (a_host, a_port)
			Result.set_plaintext
		ensure
			result_created: Result /= Void
			is_plaintext: Result.is_plaintext
		end

feature -- Service Factory

	new_service (a_name: READABLE_STRING_8): SIMPLE_GRPC_SERVICE
			-- Create a new service definition.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make (a_name)
		ensure
			result_created: Result /= Void
		end

feature -- Method Factory

	new_unary_method (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8): SIMPLE_GRPC_METHOD
			-- Create a new unary method.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make_unary (a_name, a_request_type, a_response_type)
		ensure
			result_created: Result /= Void
			is_unary: Result.is_unary
		end

	new_server_streaming_method (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8): SIMPLE_GRPC_METHOD
			-- Create a new server streaming method.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make_server_streaming (a_name, a_request_type, a_response_type)
		ensure
			result_created: Result /= Void
			is_server_streaming: Result.is_server_streaming
		end

	new_client_streaming_method (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8): SIMPLE_GRPC_METHOD
			-- Create a new client streaming method.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make_client_streaming (a_name, a_request_type, a_response_type)
		ensure
			result_created: Result /= Void
			is_client_streaming: Result.is_client_streaming
		end

	new_bidirectional_method (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8): SIMPLE_GRPC_METHOD
			-- Create a new bidirectional streaming method.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make_bidirectional (a_name, a_request_type, a_response_type)
		ensure
			result_created: Result /= Void
			is_bidirectional: Result.is_bidirectional
		end

feature -- Message Factory

	new_message: SIMPLE_PROTOBUF_MESSAGE
			-- Create a new empty message.
		do
			create Result.make
		ensure
			result_created: Result /= Void
		end

	new_message_with_name (a_name: READABLE_STRING_8): SIMPLE_PROTOBUF_MESSAGE
			-- Create a new message with type name.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make_with_name (a_name)
		ensure
			result_created: Result /= Void
		end

feature -- Protocol Buffers Factory

	new_protobuf: SIMPLE_PROTOBUF
			-- Create a new Protocol Buffers encoder/decoder.
		do
			create Result.make
		ensure
			result_created: Result /= Void
		end

	new_protobuf_field_int32 (a_number: INTEGER; a_value: INTEGER): SIMPLE_PROTOBUF_FIELD
			-- Create an int32 field.
		require
			valid_number: a_number >= 1
		do
			create Result.make_int32 (a_number, a_value)
		ensure
			result_created: Result /= Void
		end

	new_protobuf_field_string (a_number: INTEGER; a_value: READABLE_STRING_8): SIMPLE_PROTOBUF_FIELD
			-- Create a string field.
		require
			valid_number: a_number >= 1
		do
			create Result.make_string (a_number, a_value)
		ensure
			result_created: Result /= Void
		end

	new_protobuf_field_bool (a_number: INTEGER; a_value: BOOLEAN): SIMPLE_PROTOBUF_FIELD
			-- Create a bool field.
		require
			valid_number: a_number >= 1
		do
			create Result.make_bool (a_number, a_value)
		ensure
			result_created: Result /= Void
		end

feature -- Status Factory

	new_status_ok: SIMPLE_GRPC_STATUS
			-- Create OK status.
		do
			create Result.make_ok
		ensure
			result_created: Result /= Void
			is_ok: Result.is_ok
		end

	new_status (a_code: INTEGER; a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create status with code and message.
		require
			valid_code: a_code >= 0 and a_code <= 16
		do
			create Result.make (a_code, a_message)
		ensure
			result_created: Result /= Void
		end

	new_status_error (a_code: INTEGER; a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create error status.
		require
			is_error_code: a_code > 0 and a_code <= 16
		do
			create Result.make_error (a_code, a_message)
		ensure
			result_created: Result /= Void
			is_error: Result.is_error
		end

feature -- Metadata Factory

	new_metadata: SIMPLE_GRPC_METADATA
			-- Create empty metadata.
		do
			create Result.make
		ensure
			result_created: Result /= Void
		end

feature -- HTTP/2 Frame Factory

	new_http2_data_frame (a_stream_id: INTEGER; a_data: ARRAY [NATURAL_8]; a_end_stream: BOOLEAN): SIMPLE_HTTP2_FRAME
			-- Create HTTP/2 DATA frame.
		require
			valid_stream_id: a_stream_id > 0
		do
			create Result.make_data (a_stream_id, a_data, a_end_stream)
		ensure
			result_created: Result /= Void
			is_data: Result.is_data
		end

	new_http2_headers_frame (a_stream_id: INTEGER; a_headers: ARRAY [NATURAL_8]; a_end_stream: BOOLEAN): SIMPLE_HTTP2_FRAME
			-- Create HTTP/2 HEADERS frame.
		require
			valid_stream_id: a_stream_id > 0
		do
			create Result.make_headers (a_stream_id, a_headers, a_end_stream, True)
		ensure
			result_created: Result /= Void
			is_headers: Result.is_headers
		end

	new_http2_settings_frame (a_settings: ARRAY [TUPLE [id: INTEGER; value: INTEGER]]): SIMPLE_HTTP2_FRAME
			-- Create HTTP/2 SETTINGS frame.
		do
			create Result.make_settings (a_settings, False)
		ensure
			result_created: Result /= Void
			is_settings: Result.is_settings
		end

	new_http2_settings_ack: SIMPLE_HTTP2_FRAME
			-- Create HTTP/2 SETTINGS ACK frame.
		local
			l_empty: ARRAY [TUPLE [id: INTEGER; value: INTEGER]]
		do
			create l_empty.make_empty
			create Result.make_settings (l_empty, True)
		ensure
			result_created: Result /= Void
			is_settings: Result.is_settings
			is_ack: Result.is_ack
		end

feature -- Status Code Constants (convenience)

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

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
