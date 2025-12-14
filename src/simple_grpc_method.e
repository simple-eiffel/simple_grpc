note
	description: "[
		gRPC method definition.

		Defines an RPC method with its name, type, and message types.
		Method types:
		- Unary: single request -> single response
		- Server streaming: single request -> stream of responses
		- Client streaming: stream of requests -> single response
		- Bidirectional: stream <-> stream
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_GRPC_METHOD

create
	make,
	make_unary,
	make_server_streaming,
	make_client_streaming,
	make_bidirectional

feature {NONE} -- Initialization

	make (a_name: READABLE_STRING_8; a_type: INTEGER; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8)
			-- Create method with name, type, and message types.
		require
			name_not_empty: not a_name.is_empty
			valid_type: a_type >= method_unary and a_type <= method_bidirectional
		do
			create name.make_from_string (a_name)
			method_type := a_type
			create request_type.make_from_string (a_request_type)
			create response_type.make_from_string (a_response_type)
		ensure
			name_set: name.same_string (a_name)
			type_set: method_type = a_type
		end

	make_unary (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8)
			-- Create unary method.
		require
			name_not_empty: not a_name.is_empty
		do
			make (a_name, method_unary, a_request_type, a_response_type)
		ensure
			is_unary: is_unary
		end

	make_server_streaming (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8)
			-- Create server streaming method.
		require
			name_not_empty: not a_name.is_empty
		do
			make (a_name, method_server_streaming, a_request_type, a_response_type)
		ensure
			is_server_streaming: is_server_streaming
		end

	make_client_streaming (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8)
			-- Create client streaming method.
		require
			name_not_empty: not a_name.is_empty
		do
			make (a_name, method_client_streaming, a_request_type, a_response_type)
		ensure
			is_client_streaming: is_client_streaming
		end

	make_bidirectional (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8)
			-- Create bidirectional streaming method.
		require
			name_not_empty: not a_name.is_empty
		do
			make (a_name, method_bidirectional, a_request_type, a_response_type)
		ensure
			is_bidirectional: is_bidirectional
		end

feature -- Method Type Constants

	method_unary: INTEGER = 1
			-- Unary: single request -> single response.

	method_server_streaming: INTEGER = 2
			-- Server streaming: single request -> stream of responses.

	method_client_streaming: INTEGER = 3
			-- Client streaming: stream of requests -> single response.

	method_bidirectional: INTEGER = 4
			-- Bidirectional streaming: stream <-> stream.

feature -- Access

	name: STRING
			-- Method name.

	method_type: INTEGER
			-- Method type (unary, server streaming, etc.).

	request_type: STRING
			-- Request message type name.

	response_type: STRING
			-- Response message type name.

feature -- Status

	is_unary: BOOLEAN
			-- Is this a unary method?
		do
			Result := method_type = method_unary
		end

	is_server_streaming: BOOLEAN
			-- Is this a server streaming method?
		do
			Result := method_type = method_server_streaming
		end

	is_client_streaming: BOOLEAN
			-- Is this a client streaming method?
		do
			Result := method_type = method_client_streaming
		end

	is_bidirectional: BOOLEAN
			-- Is this a bidirectional streaming method?
		do
			Result := method_type = method_bidirectional
		end

	is_streaming: BOOLEAN
			-- Is this a streaming method (any type)?
		do
			Result := method_type /= method_unary
		end

	has_streaming_request: BOOLEAN
			-- Does this method have streaming requests?
		do
			Result := method_type = method_client_streaming or
					  method_type = method_bidirectional
		end

	has_streaming_response: BOOLEAN
			-- Does this method have streaming responses?
		do
			Result := method_type = method_server_streaming or
					  method_type = method_bidirectional
		end

feature -- Conversion

	type_name: STRING
			-- Human-readable method type name.
		do
			inspect method_type
			when method_unary then Result := "unary"
			when method_server_streaming then Result := "server_streaming"
			when method_client_streaming then Result := "client_streaming"
			when method_bidirectional then Result := "bidirectional"
			else
				Result := "unknown"
			end
		end

	full_name (a_service_name: READABLE_STRING_8): STRING
			-- Full method path: /service.Service/MethodName
		do
			create Result.make (50)
			Result.append_character ('/')
			Result.append (a_service_name)
			Result.append_character ('/')
			Result.append (name)
		end

invariant
	name_not_empty: not name.is_empty
	valid_type: method_type >= method_unary and method_type <= method_bidirectional
	request_type_attached: request_type /= Void
	response_type_attached: response_type /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
