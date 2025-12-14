note
	description: "[
		gRPC channel (connection to a server).

		A channel represents a connection to a gRPC server.
		It manages the HTTP/2 connection and creates calls.

		Note: This implementation does not include actual network I/O.
		It provides the protocol layer for integration with socket libraries.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_GRPC_CHANNEL

create
	make

feature {NONE} -- Initialization

	make (a_host: READABLE_STRING_8; a_port: INTEGER)
			-- Create channel to host:port.
		require
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port <= 65535
		do
			create host.make_from_string (a_host)
			port := a_port
			state := state_idle
			is_plaintext := True
			next_stream_id := 1
			create services.make (10)
			create default_metadata.make
			default_timeout_ms := 30000  -- 30 seconds default
		ensure
			host_set: host.same_string (a_host)
			port_set: port = a_port
			state_idle: state = state_idle
		end

feature -- State Constants

	state_idle: INTEGER = 0
			-- Channel not connected.

	state_connecting: INTEGER = 1
			-- Connection in progress.

	state_ready: INTEGER = 2
			-- Connected and ready.

	state_transient_failure: INTEGER = 3
			-- Temporary connection failure.

	state_shutdown: INTEGER = 4
			-- Channel shut down.

feature -- Access

	host: STRING
			-- Server hostname.

	port: INTEGER
			-- Server port.

	state: INTEGER
			-- Current channel state.

	services: HASH_TABLE [SIMPLE_GRPC_SERVICE, STRING]
			-- Registered services.

	default_metadata: SIMPLE_GRPC_METADATA
			-- Default metadata for all calls.

	default_timeout_ms: INTEGER
			-- Default timeout in milliseconds.

	authority: STRING
			-- HTTP/2 :authority header value.
		do
			create Result.make (50)
			Result.append (host)
			if port /= 80 and port /= 443 then
				Result.append_character (':')
				Result.append_integer (port)
			end
		end

feature -- Status

	is_plaintext: BOOLEAN
			-- Is this a plaintext (non-TLS) connection?

	is_ready: BOOLEAN
			-- Is channel ready for calls?
		do
			Result := state = state_ready
		end

	is_connected: BOOLEAN
			-- Is channel connected?
		do
			Result := state = state_ready or state = state_connecting
		end

	is_shutdown: BOOLEAN
			-- Is channel shut down?
		do
			Result := state = state_shutdown
		end

feature -- Configuration

	set_plaintext
			-- Use plaintext (no TLS).
		require
			not_connected: state = state_idle
		do
			is_plaintext := True
		ensure
			is_plaintext: is_plaintext
		end

	set_tls
			-- Use TLS (not implemented in Phase 1).
		require
			not_connected: state = state_idle
		do
			is_plaintext := False
		ensure
			not_plaintext: not is_plaintext
		end

	set_default_timeout (a_timeout_ms: INTEGER)
			-- Set default timeout for calls.
		require
			valid_timeout: a_timeout_ms >= 0
		do
			default_timeout_ms := a_timeout_ms
		ensure
			timeout_set: default_timeout_ms = a_timeout_ms
		end

	add_default_metadata (a_key: READABLE_STRING_8; a_value: READABLE_STRING_8)
			-- Add default metadata sent with every call.
		do
			default_metadata.add (a_key, a_value)
		end

feature -- Service Registration

	register_service (a_service: SIMPLE_GRPC_SERVICE)
			-- Register a service definition.
		require
			service_not_void: a_service /= Void
		do
			services.put (a_service, a_service.name)
		ensure
			service_registered: services.has (a_service.name)
		end

	service (a_name: READABLE_STRING_8): detachable SIMPLE_GRPC_SERVICE
			-- Get registered service by name.
		do
			Result := services.item (a_name.to_string_8)
		end

feature -- Connection

	connect
			-- Connect to server.
		require
			not_connected: state = state_idle
		do
			state := state_connecting
			-- In a real implementation, this would:
			-- 1. Open TCP socket
			-- 2. Perform TLS handshake if not plaintext
			-- 3. Send HTTP/2 connection preface
			-- 4. Exchange SETTINGS frames
			state := state_ready
		ensure
			is_ready: is_ready
		end

	shutdown
			-- Shut down channel.
		do
			state := state_shutdown
		ensure
			is_shutdown: is_shutdown
		end

feature -- Call Creation

	new_call (a_service: SIMPLE_GRPC_SERVICE; a_method_name: READABLE_STRING_8): detachable SIMPLE_GRPC_CALL
			-- Create a new call for method.
		require
			service_not_void: a_service /= Void
			method_exists: a_service.has_method (a_method_name)
		local
			l_method: detachable SIMPLE_GRPC_METHOD
		do
			l_method := a_service.method (a_method_name)
			if attached l_method then
				create Result.make (l_method, a_service.name)
				Result.set_timeout (default_timeout_ms)
				-- Copy default metadata
				default_metadata.do_all (agent (k, v: STRING; c: SIMPLE_GRPC_CALL)
					do
						c.add_request_metadata (k, v)
					end (?, ?, Result))
			end
		end

	new_unary_call (a_service_name: READABLE_STRING_8; a_method_name: READABLE_STRING_8): SIMPLE_GRPC_CALL
			-- Create a new unary call.
		local
			l_method: SIMPLE_GRPC_METHOD
		do
			create l_method.make_unary (a_method_name, "", "")
			create Result.make (l_method, a_service_name)
			Result.set_timeout (default_timeout_ms)
		end

feature -- HTTP/2 Frame Generation

	build_request_headers (a_call: SIMPLE_GRPC_CALL): SIMPLE_HTTP2_FRAME
			-- Build HEADERS frame for request.
		local
			l_headers: STRING
			l_bytes: ARRAY [NATURAL_8]
			i: INTEGER
		do
			create l_headers.make (200)

			-- Pseudo-headers
			l_headers.append (":method: POST%R%N")
			l_headers.append (":scheme: ")
			if is_plaintext then
				l_headers.append ("http")
			else
				l_headers.append ("https")
			end
			l_headers.append ("%R%N")
			l_headers.append (":path: ")
			l_headers.append (a_call.path)
			l_headers.append ("%R%N")
			l_headers.append (":authority: ")
			l_headers.append (authority)
			l_headers.append ("%R%N")

			-- gRPC headers
			l_headers.append ("content-type: application/grpc%R%N")
			l_headers.append ("te: trailers%R%N")

			-- Timeout if set
			if a_call.timeout_ms > 0 then
				l_headers.append ("grpc-timeout: ")
				l_headers.append_integer (a_call.timeout_ms)
				l_headers.append ("m%R%N")
			end

			-- Custom metadata
			a_call.request_metadata.do_all (agent (k, v: STRING; h: STRING)
				do
					h.append (k)
					h.append (": ")
					h.append (v)
					h.append ("%R%N")
				end (?, ?, l_headers))

			-- Convert to bytes
			create l_bytes.make_filled (0, 1, l_headers.count)
			from i := 1 until i > l_headers.count loop
				l_bytes.put (l_headers.item (i).natural_32_code.to_natural_8, i)
				i := i + 1
			end

			create Result.make_headers (allocate_stream_id, l_bytes, False, True)
		end

	build_data_frame (a_stream_id: INTEGER; a_data: ARRAY [NATURAL_8]; a_end_stream: BOOLEAN): SIMPLE_HTTP2_FRAME
			-- Build DATA frame.
		do
			create Result.make_data (a_stream_id, a_data, a_end_stream)
		end

feature {NONE} -- Implementation

	next_stream_id: INTEGER
			-- Next stream ID to allocate.

	allocate_stream_id: INTEGER
			-- Allocate a new stream ID (odd for client-initiated).
		do
			Result := next_stream_id
			next_stream_id := next_stream_id + 2
		end

invariant
	host_not_empty: not host.is_empty
	valid_port: port > 0 and port <= 65535
	valid_state: state >= state_idle and state <= state_shutdown
	services_attached: services /= Void
	default_metadata_attached: default_metadata /= Void
	odd_stream_id: next_stream_id \\ 2 = 1  -- Client streams are odd

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
