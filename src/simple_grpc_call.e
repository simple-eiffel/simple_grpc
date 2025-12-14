note
	description: "[
		gRPC call (RPC invocation).

		Represents an active or completed RPC call with its
		request, response, metadata, and status.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_GRPC_CALL

create
	make

feature {NONE} -- Initialization

	make (a_method: SIMPLE_GRPC_METHOD; a_service_name: READABLE_STRING_8)
			-- Create call for method.
		require
			method_not_void: a_method /= Void
		do
			method := a_method
			create service_name.make_from_string (a_service_name)
			create request_metadata.make
			create response_metadata.make
			create trailer_metadata.make
			create status.make_ok
			state := state_created
			timeout_ms := 0
		ensure
			method_set: method = a_method
			state_created: state = state_created
		end

feature -- State Constants

	state_created: INTEGER = 0
			-- Call created, not started.

	state_sending: INTEGER = 1
			-- Sending request(s).

	state_receiving: INTEGER = 2
			-- Receiving response(s).

	state_completed: INTEGER = 3
			-- Call completed.

	state_cancelled: INTEGER = 4
			-- Call was cancelled.

	state_error: INTEGER = 5
			-- Call ended with error.

feature -- Access

	method: SIMPLE_GRPC_METHOD
			-- The method being called.

	service_name: STRING
			-- Service name.

	request: detachable SIMPLE_PROTOBUF_MESSAGE
			-- Request message (for unary/server-streaming).

	response: detachable SIMPLE_PROTOBUF_MESSAGE
			-- Response message (for unary/client-streaming).

	request_metadata: SIMPLE_GRPC_METADATA
			-- Request headers.

	response_metadata: SIMPLE_GRPC_METADATA
			-- Response headers.

	trailer_metadata: SIMPLE_GRPC_METADATA
			-- Response trailers (contain status).

	status: SIMPLE_GRPC_STATUS
			-- Call status.

	state: INTEGER
			-- Current call state.

	timeout_ms: INTEGER
			-- Timeout in milliseconds (0 = no timeout).

feature -- Status

	is_ok: BOOLEAN
			-- Did call complete successfully?
		do
			Result := state = state_completed and status.is_ok
		end

	is_error: BOOLEAN
			-- Did call end with error?
		do
			Result := state = state_error or (state = state_completed and status.is_error)
		end

	is_cancelled: BOOLEAN
			-- Was call cancelled?
		do
			Result := state = state_cancelled
		end

	is_completed: BOOLEAN
			-- Is call complete (success, error, or cancelled)?
		do
			Result := state >= state_completed
		end

	is_active: BOOLEAN
			-- Is call currently active?
		do
			Result := state = state_sending or state = state_receiving
		end

feature -- Element Change

	set_request (a_request: SIMPLE_PROTOBUF_MESSAGE)
			-- Set request message.
		require
			not_started: state = state_created
		do
			request := a_request
		ensure
			request_set: request = a_request
		end

	set_timeout (a_timeout_ms: INTEGER)
			-- Set timeout in milliseconds.
		require
			not_started: state = state_created
			valid_timeout: a_timeout_ms >= 0
		do
			timeout_ms := a_timeout_ms
		ensure
			timeout_set: timeout_ms = a_timeout_ms
		end

	add_request_metadata (a_key: READABLE_STRING_8; a_value: READABLE_STRING_8)
			-- Add request metadata.
		require
			not_started: state = state_created
		do
			request_metadata.add (a_key, a_value)
		end

feature -- Execution

	start
			-- Start the call.
		require
			state_created: state = state_created
		do
			state := state_sending
		ensure
			state_sending: state = state_sending
		end

	send_message (a_message: SIMPLE_PROTOBUF_MESSAGE)
			-- Send a message (for streaming).
		require
			state_sending: state = state_sending
			supports_streaming_request: method.has_streaming_request
		do
			-- In a real implementation, this would send via the channel
			request := a_message
		end

	finish_sending
			-- Finish sending (half-close for client streaming).
		require
			state_sending: state = state_sending
		do
			state := state_receiving
		ensure
			state_receiving: state = state_receiving
		end

	receive_message: detachable SIMPLE_PROTOBUF_MESSAGE
			-- Receive a message (for streaming).
		require
			state_receiving: state = state_receiving
		do
			Result := response
		end

	complete_with_status (a_status: SIMPLE_GRPC_STATUS; a_response: detachable SIMPLE_PROTOBUF_MESSAGE)
			-- Complete call with status and optional response.
		do
			status := a_status
			response := a_response
			if a_status.is_ok then
				state := state_completed
			else
				state := state_error
			end
		ensure
			is_completed: is_completed
		end

	cancel
			-- Cancel the call.
		require
			not_completed: not is_completed
		do
			state := state_cancelled
			status := status.cancelled ("Call cancelled by client")
		ensure
			is_cancelled: is_cancelled
		end

feature -- gRPC Message Framing

	encode_grpc_message (a_message: SIMPLE_PROTOBUF_MESSAGE): ARRAY [NATURAL_8]
			-- Encode message with gRPC length-prefix framing.
			-- Format: 1-byte compressed flag + 4-byte length + payload
		local
			l_payload: ARRAY [NATURAL_8]
			l_result: ARRAYED_LIST [NATURAL_8]
			l_length: INTEGER
			i: INTEGER
		do
			l_payload := a_message.encode
			l_length := l_payload.count
			create l_result.make (5 + l_length)

			-- Compressed flag (0 = not compressed)
			l_result.extend (0)

			-- Length (4 bytes big-endian)
			l_result.extend (((l_length |>> 24) & 0xFF).to_natural_8)
			l_result.extend (((l_length |>> 16) & 0xFF).to_natural_8)
			l_result.extend (((l_length |>> 8) & 0xFF).to_natural_8)
			l_result.extend ((l_length & 0xFF).to_natural_8)

			-- Payload
			from i := l_payload.lower until i > l_payload.upper loop
				l_result.extend (l_payload.item (i))
				i := i + 1
			end

			create Result.make_from_special (l_result.area.aliased_resized_area (l_result.count))
		end

	decode_grpc_message (a_data: ARRAY [NATURAL_8]): detachable SIMPLE_PROTOBUF_MESSAGE
			-- Decode message from gRPC length-prefix framing.
		local
			l_compressed: BOOLEAN
			l_length: INTEGER
			l_payload: ARRAY [NATURAL_8]
			i, j: INTEGER
		do
			if a_data.count >= 5 then
				-- Compressed flag
				l_compressed := a_data.item (a_data.lower) /= 0

				-- Length (4 bytes big-endian)
				l_length := (a_data.item (a_data.lower + 1).to_integer_32 |<< 24) |
							(a_data.item (a_data.lower + 2).to_integer_32 |<< 16) |
							(a_data.item (a_data.lower + 3).to_integer_32 |<< 8) |
							a_data.item (a_data.lower + 4).to_integer_32

				if a_data.count >= 5 + l_length then
					-- Extract payload
					create l_payload.make_filled (0, 1, l_length)
					from
						i := a_data.lower + 5
						j := 1
					until
						j > l_length
					loop
						l_payload.put (a_data.item (i), j)
						i := i + 1
						j := j + 1
					end

					-- Decode message
					create Result.make
					Result.decode (l_payload)
				end
			end
		end

feature -- Path Generation

	path: STRING
			-- Full method path for HTTP/2 request.
		do
			create Result.make (50)
			Result.append_character ('/')
			Result.append (service_name)
			Result.append_character ('/')
			Result.append (method.name)
		end

invariant
	method_attached: method /= Void
	request_metadata_attached: request_metadata /= Void
	response_metadata_attached: response_metadata /= Void
	trailer_metadata_attached: trailer_metadata /= Void
	status_attached: status /= Void
	valid_state: state >= state_created and state <= state_error

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
