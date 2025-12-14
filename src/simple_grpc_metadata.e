note
	description: "[
		gRPC metadata (headers and trailers).

		Metadata are key-value pairs sent with gRPC calls.
		Keys ending in '-bin' contain binary values (Base64 encoded).
		All other keys contain ASCII values.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_GRPC_METADATA

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty metadata.
		do
			create entries.make (10)
		end

feature -- Access

	entries: ARRAYED_LIST [TUPLE [key: STRING; value: STRING]]
			-- Metadata entries.

	value (a_key: READABLE_STRING_8): detachable STRING
			-- Get value for key, or Void if not found.
		local
			i: INTEGER
			l_key_lower: STRING
		do
			l_key_lower := a_key.as_lower.to_string_8
			from i := 1 until i > entries.count or Result /= Void loop
				if entries.i_th (i).key.same_string (l_key_lower) then
					Result := entries.i_th (i).value
				end
				i := i + 1
			end
		end

	values (a_key: READABLE_STRING_8): ARRAYED_LIST [STRING]
			-- Get all values for key (metadata can have duplicate keys).
		local
			i: INTEGER
			l_key_lower: STRING
		do
			create Result.make (2)
			l_key_lower := a_key.as_lower.to_string_8
			from i := 1 until i > entries.count loop
				if entries.i_th (i).key.same_string (l_key_lower) then
					Result.extend (entries.i_th (i).value)
				end
				i := i + 1
			end
		end

	count: INTEGER
			-- Number of entries.
		do
			Result := entries.count
		end

	is_empty: BOOLEAN
			-- Is metadata empty?
		do
			Result := entries.is_empty
		end

feature -- Status

	has (a_key: READABLE_STRING_8): BOOLEAN
			-- Does metadata contain key?
		do
			Result := value (a_key) /= Void
		end

	is_binary_key (a_key: READABLE_STRING_8): BOOLEAN
			-- Is this a binary metadata key?
		do
			Result := a_key.ends_with ("-bin")
		end

feature -- Element Change

	put (a_key: READABLE_STRING_8; a_value: READABLE_STRING_8)
			-- Add or replace metadata entry.
		local
			l_key_lower: STRING
			i: INTEGER
			l_found: BOOLEAN
		do
			l_key_lower := a_key.as_lower.to_string_8
			from i := 1 until i > entries.count or l_found loop
				if entries.i_th (i).key.same_string (l_key_lower) then
					entries.put_i_th ([l_key_lower, a_value.to_string_8], i)
					l_found := True
				end
				i := i + 1
			end
			if not l_found then
				entries.extend ([l_key_lower, a_value.to_string_8])
			end
		end

	add (a_key: READABLE_STRING_8; a_value: READABLE_STRING_8)
			-- Add metadata entry (allows duplicates).
		do
			entries.extend ([a_key.as_lower.to_string_8, a_value.to_string_8])
		end

	remove (a_key: READABLE_STRING_8)
			-- Remove all entries with key.
		local
			i: INTEGER
			l_key_lower: STRING
		do
			l_key_lower := a_key.as_lower.to_string_8
			from i := entries.count until i < 1 loop
				if entries.i_th (i).key.same_string (l_key_lower) then
					entries.go_i_th (i)
					entries.remove
				end
				i := i - 1
			end
		end

	clear
			-- Remove all entries.
		do
			entries.wipe_out
		end

feature -- Standard gRPC Headers

	set_content_type (a_type: READABLE_STRING_8)
			-- Set content-type header.
		do
			put ("content-type", a_type)
		end

	set_grpc_timeout (a_timeout_ms: INTEGER)
			-- Set grpc-timeout header in milliseconds.
		do
			put ("grpc-timeout", a_timeout_ms.out + "m")
		end

	set_grpc_encoding (a_encoding: READABLE_STRING_8)
			-- Set grpc-encoding header.
		do
			put ("grpc-encoding", a_encoding)
		end

	set_grpc_accept_encoding (a_encodings: READABLE_STRING_8)
			-- Set grpc-accept-encoding header.
		do
			put ("grpc-accept-encoding", a_encodings)
		end

	set_user_agent (a_agent: READABLE_STRING_8)
			-- Set user-agent header.
		do
			put ("user-agent", a_agent)
		end

	set_authorization (a_auth: READABLE_STRING_8)
			-- Set authorization header.
		do
			put ("authorization", a_auth)
		end

	content_type: STRING
			-- Get content-type header.
		do
			if attached value ("content-type") as v then
				Result := v
			else
				Result := "application/grpc"
			end
		end

	grpc_status: INTEGER
			-- Get grpc-status trailer value.
		do
			if attached value ("grpc-status") as v and then v.is_integer then
				Result := v.to_integer
			end
		end

	grpc_message: STRING
			-- Get grpc-message trailer value.
		do
			if attached value ("grpc-message") as v then
				Result := v
			else
				create Result.make_empty
			end
		end

feature -- Encoding

	to_http2_headers: STRING
			-- Encode as HTTP/2 header block (simplified, no HPACK).
		local
			i: INTEGER
		do
			create Result.make (100)
			from i := 1 until i > entries.count loop
				Result.append (entries.i_th (i).key)
				Result.append (": ")
				Result.append (entries.i_th (i).value)
				Result.append ("%R%N")
				i := i + 1
			end
		end

	from_http2_headers (a_headers: READABLE_STRING_8)
			-- Parse HTTP/2 header block (simplified).
		local
			l_lines: LIST [READABLE_STRING_8]
			l_line: STRING
			l_colon_pos: INTEGER
			l_key, l_value: STRING
			i: INTEGER
		do
			clear
			l_lines := a_headers.split ('%N')
			from i := 1 until i > l_lines.count loop
				l_line := l_lines.i_th (i).to_string_8
				l_line.right_adjust
				l_line.left_adjust
				if l_line.count > 0 then
					l_colon_pos := l_line.index_of (':', 1)
					if l_colon_pos > 1 then
						l_key := l_line.substring (1, l_colon_pos - 1)
						l_key.left_adjust
						l_key.right_adjust
						if l_colon_pos < l_line.count then
							l_value := l_line.substring (l_colon_pos + 1, l_line.count)
							l_value.left_adjust
							l_value.right_adjust
						else
							create l_value.make_empty
						end
						add (l_key, l_value)
					end
				end
				i := i + 1
			end
		end

feature -- Iteration

	do_all (a_action: PROCEDURE [TUPLE [key: STRING; value: STRING]])
			-- Execute action for each entry.
		local
			i: INTEGER
		do
			from i := 1 until i > entries.count loop
				a_action.call ([entries.i_th (i).key, entries.i_th (i).value])
				i := i + 1
			end
		end

invariant
	entries_attached: entries /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
