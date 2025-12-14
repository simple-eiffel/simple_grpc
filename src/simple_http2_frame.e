note
	description: "[
		HTTP/2 frame structure for gRPC transport.

		HTTP/2 frames have a 9-byte header:
		- 3 bytes: payload length
		- 1 byte: frame type
		- 1 byte: flags
		- 4 bytes: stream identifier (MSB reserved)

		Frame types used by gRPC:
		- DATA (0x0): Message payload
		- HEADERS (0x1): Request/response headers
		- RST_STREAM (0x3): Stream termination
		- SETTINGS (0x4): Connection settings
		- PING (0x6): Connection health check
		- GOAWAY (0x7): Graceful shutdown
		- WINDOW_UPDATE (0x8): Flow control
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_HTTP2_FRAME

create
	make,
	make_data,
	make_headers,
	make_settings,
	make_window_update,
	make_ping,
	make_goaway,
	make_rst_stream

feature {NONE} -- Initialization

	make (a_type: INTEGER; a_flags: INTEGER; a_stream_id: INTEGER; a_payload: detachable ARRAY [NATURAL_8])
			-- Create frame with type, flags, stream ID and payload.
		require
			valid_type: a_type >= 0 and a_type <= 255
			valid_flags: a_flags >= 0 and a_flags <= 255
			valid_stream_id: a_stream_id >= 0
		do
			frame_type := a_type
			flags := a_flags
			stream_id := a_stream_id
			if attached a_payload then
				payload := a_payload
			else
				create payload.make_empty
			end
		ensure
			type_set: frame_type = a_type
			flags_set: flags = a_flags
			stream_id_set: stream_id = a_stream_id
		end

	make_data (a_stream_id: INTEGER; a_data: ARRAY [NATURAL_8]; a_end_stream: BOOLEAN)
			-- Create DATA frame.
		require
			valid_stream_id: a_stream_id > 0
		do
			frame_type := type_data
			if a_end_stream then
				flags := flag_end_stream
			else
				flags := 0
			end
			stream_id := a_stream_id
			payload := a_data
		end

	make_headers (a_stream_id: INTEGER; a_headers: ARRAY [NATURAL_8]; a_end_stream: BOOLEAN; a_end_headers: BOOLEAN)
			-- Create HEADERS frame.
		require
			valid_stream_id: a_stream_id > 0
		local
			l_flags: INTEGER
		do
			frame_type := type_headers
			l_flags := 0
			if a_end_stream then
				l_flags := l_flags | flag_end_stream
			end
			if a_end_headers then
				l_flags := l_flags | flag_end_headers
			end
			flags := l_flags
			stream_id := a_stream_id
			payload := a_headers
		end

	make_settings (a_settings: ARRAY [TUPLE [id: INTEGER; value: INTEGER]]; a_ack: BOOLEAN)
			-- Create SETTINGS frame.
		local
			l_payload: ARRAYED_LIST [NATURAL_8]
			i: INTEGER
			l_setting: TUPLE [id: INTEGER; value: INTEGER]
		do
			frame_type := type_settings
			if a_ack then
				flags := flag_ack
				create payload.make_empty
			else
				flags := 0
				create l_payload.make (a_settings.count * 6)
				from i := a_settings.lower until i > a_settings.upper loop
					l_setting := a_settings.item (i)
					-- Setting ID (2 bytes big-endian)
					l_payload.extend (((l_setting.id |>> 8) & 0xFF).to_natural_8)
					l_payload.extend ((l_setting.id & 0xFF).to_natural_8)
					-- Setting value (4 bytes big-endian)
					l_payload.extend (((l_setting.value |>> 24) & 0xFF).to_natural_8)
					l_payload.extend (((l_setting.value |>> 16) & 0xFF).to_natural_8)
					l_payload.extend (((l_setting.value |>> 8) & 0xFF).to_natural_8)
					l_payload.extend ((l_setting.value & 0xFF).to_natural_8)
					i := i + 1
				end
				create payload.make_from_special (l_payload.area.aliased_resized_area (l_payload.count))
			end
			stream_id := 0
		end

	make_window_update (a_stream_id: INTEGER; a_increment: INTEGER)
			-- Create WINDOW_UPDATE frame.
		require
			valid_increment: a_increment > 0 and a_increment <= 0x7FFFFFFF
		do
			frame_type := type_window_update
			flags := 0
			stream_id := a_stream_id
			create payload.make_filled (0, 1, 4)
			-- 4 bytes big-endian, MSB reserved (must be 0)
			payload.put (((a_increment |>> 24) & 0x7F).to_natural_8, 1)
			payload.put (((a_increment |>> 16) & 0xFF).to_natural_8, 2)
			payload.put (((a_increment |>> 8) & 0xFF).to_natural_8, 3)
			payload.put ((a_increment & 0xFF).to_natural_8, 4)
		end

	make_ping (a_data: ARRAY [NATURAL_8]; a_ack: BOOLEAN)
			-- Create PING frame.
		require
			valid_data: a_data.count = 8
		do
			frame_type := type_ping
			if a_ack then
				flags := flag_ack
			else
				flags := 0
			end
			stream_id := 0
			payload := a_data
		end

	make_goaway (a_last_stream_id: INTEGER; a_error_code: INTEGER)
			-- Create GOAWAY frame.
		do
			frame_type := type_goaway
			flags := 0
			stream_id := 0
			create payload.make_filled (0, 1, 8)
			-- Last stream ID (4 bytes big-endian)
			payload.put (((a_last_stream_id |>> 24) & 0x7F).to_natural_8, 1)
			payload.put (((a_last_stream_id |>> 16) & 0xFF).to_natural_8, 2)
			payload.put (((a_last_stream_id |>> 8) & 0xFF).to_natural_8, 3)
			payload.put ((a_last_stream_id & 0xFF).to_natural_8, 4)
			-- Error code (4 bytes big-endian)
			payload.put (((a_error_code |>> 24) & 0xFF).to_natural_8, 5)
			payload.put (((a_error_code |>> 16) & 0xFF).to_natural_8, 6)
			payload.put (((a_error_code |>> 8) & 0xFF).to_natural_8, 7)
			payload.put ((a_error_code & 0xFF).to_natural_8, 8)
		end

	make_rst_stream (a_stream_id: INTEGER; a_error_code: INTEGER)
			-- Create RST_STREAM frame.
		require
			valid_stream_id: a_stream_id > 0
		do
			frame_type := type_rst_stream
			flags := 0
			stream_id := a_stream_id
			create payload.make_filled (0, 1, 4)
			-- Error code (4 bytes big-endian)
			payload.put (((a_error_code |>> 24) & 0xFF).to_natural_8, 1)
			payload.put (((a_error_code |>> 16) & 0xFF).to_natural_8, 2)
			payload.put (((a_error_code |>> 8) & 0xFF).to_natural_8, 3)
			payload.put ((a_error_code & 0xFF).to_natural_8, 4)
		end

feature -- Frame Type Constants

	type_data: INTEGER = 0
	type_headers: INTEGER = 1
	type_priority: INTEGER = 2
	type_rst_stream: INTEGER = 3
	type_settings: INTEGER = 4
	type_push_promise: INTEGER = 5
	type_ping: INTEGER = 6
	type_goaway: INTEGER = 7
	type_window_update: INTEGER = 8
	type_continuation: INTEGER = 9

feature -- Flag Constants

	flag_end_stream: INTEGER = 0x01
	flag_end_headers: INTEGER = 0x04
	flag_padded: INTEGER = 0x08
	flag_priority: INTEGER = 0x20
	flag_ack: INTEGER = 0x01

feature -- Error Code Constants

	error_no_error: INTEGER = 0x0
	error_protocol_error: INTEGER = 0x1
	error_internal_error: INTEGER = 0x2
	error_flow_control_error: INTEGER = 0x3
	error_settings_timeout: INTEGER = 0x4
	error_stream_closed: INTEGER = 0x5
	error_frame_size_error: INTEGER = 0x6
	error_refused_stream: INTEGER = 0x7
	error_cancel: INTEGER = 0x8
	error_compression_error: INTEGER = 0x9
	error_connect_error: INTEGER = 0xA
	error_enhance_your_calm: INTEGER = 0xB
	error_inadequate_security: INTEGER = 0xC
	error_http_1_1_required: INTEGER = 0xD

feature -- Access

	frame_type: INTEGER
			-- Frame type (0-255).

	flags: INTEGER
			-- Frame flags (0-255).

	stream_id: INTEGER
			-- Stream identifier (0 = connection-level).

	payload: ARRAY [NATURAL_8]
			-- Frame payload.

	length: INTEGER
			-- Payload length.
		do
			Result := payload.count
		end

feature -- Status

	is_data: BOOLEAN
			-- Is this a DATA frame?
		do
			Result := frame_type = type_data
		end

	is_headers: BOOLEAN
			-- Is this a HEADERS frame?
		do
			Result := frame_type = type_headers
		end

	is_settings: BOOLEAN
			-- Is this a SETTINGS frame?
		do
			Result := frame_type = type_settings
		end

	is_end_stream: BOOLEAN
			-- Does this frame have END_STREAM flag?
		do
			Result := (flags & flag_end_stream) /= 0
		end

	is_end_headers: BOOLEAN
			-- Does this frame have END_HEADERS flag?
		do
			Result := (flags & flag_end_headers) /= 0
		end

	is_ack: BOOLEAN
			-- Does this frame have ACK flag?
		do
			Result := (flags & flag_ack) /= 0
		end

feature -- Encoding

	encode: ARRAY [NATURAL_8]
			-- Encode frame to bytes.
		local
			l_result: ARRAYED_LIST [NATURAL_8]
			l_length: INTEGER
			i: INTEGER
		do
			l_length := payload.count
			create l_result.make (9 + l_length)

			-- Length (3 bytes big-endian)
			l_result.extend (((l_length |>> 16) & 0xFF).to_natural_8)
			l_result.extend (((l_length |>> 8) & 0xFF).to_natural_8)
			l_result.extend ((l_length & 0xFF).to_natural_8)

			-- Type (1 byte)
			l_result.extend (frame_type.to_natural_8)

			-- Flags (1 byte)
			l_result.extend (flags.to_natural_8)

			-- Stream ID (4 bytes big-endian, MSB reserved)
			l_result.extend (((stream_id |>> 24) & 0x7F).to_natural_8)
			l_result.extend (((stream_id |>> 16) & 0xFF).to_natural_8)
			l_result.extend (((stream_id |>> 8) & 0xFF).to_natural_8)
			l_result.extend ((stream_id & 0xFF).to_natural_8)

			-- Payload
			from i := payload.lower until i > payload.upper loop
				l_result.extend (payload.item (i))
				i := i + 1
			end

			create Result.make_from_special (l_result.area.aliased_resized_area (l_result.count))
		end

feature -- Decoding

	decode (a_bytes: ARRAY [NATURAL_8]): BOOLEAN
			-- Decode frame from bytes. Returns True if successful.
		require
			enough_bytes: a_bytes.count >= 9
		local
			l_length: INTEGER
			i, j: INTEGER
		do
			-- Length (3 bytes big-endian)
			l_length := (a_bytes.item (a_bytes.lower).to_integer_32 |<< 16) |
						(a_bytes.item (a_bytes.lower + 1).to_integer_32 |<< 8) |
						a_bytes.item (a_bytes.lower + 2).to_integer_32

			if a_bytes.count >= 9 + l_length then
				-- Type (1 byte)
				frame_type := a_bytes.item (a_bytes.lower + 3).to_integer_32

				-- Flags (1 byte)
				flags := a_bytes.item (a_bytes.lower + 4).to_integer_32

				-- Stream ID (4 bytes big-endian, ignore MSB reserved bit)
				stream_id := ((a_bytes.item (a_bytes.lower + 5).to_integer_32 & 0x7F) |<< 24) |
							(a_bytes.item (a_bytes.lower + 6).to_integer_32 |<< 16) |
							(a_bytes.item (a_bytes.lower + 7).to_integer_32 |<< 8) |
							a_bytes.item (a_bytes.lower + 8).to_integer_32

				-- Payload
				create payload.make_filled (0, 1, l_length)
				from
					i := a_bytes.lower + 9
					j := 1
				until
					j > l_length
				loop
					payload.put (a_bytes.item (i), j)
					i := i + 1
					j := j + 1
				end

				Result := True
			end
		end

feature -- Conversion

	type_name: STRING
			-- Human-readable frame type name.
		do
			inspect frame_type
			when type_data then Result := "DATA"
			when type_headers then Result := "HEADERS"
			when type_priority then Result := "PRIORITY"
			when type_rst_stream then Result := "RST_STREAM"
			when type_settings then Result := "SETTINGS"
			when type_push_promise then Result := "PUSH_PROMISE"
			when type_ping then Result := "PING"
			when type_goaway then Result := "GOAWAY"
			when type_window_update then Result := "WINDOW_UPDATE"
			when type_continuation then Result := "CONTINUATION"
			else
				Result := "UNKNOWN(" + frame_type.out + ")"
			end
		end

invariant
	valid_type: frame_type >= 0 and frame_type <= 255
	valid_flags: flags >= 0 and flags <= 255
	valid_stream_id: stream_id >= 0
	payload_attached: payload /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
