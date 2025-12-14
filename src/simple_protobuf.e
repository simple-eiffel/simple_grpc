note
	description: "[
		Protocol Buffers wire format encoding and decoding.

		Implements the protobuf binary wire format for serialization.
		Supports varint, fixed-width, and length-delimited encoding.

		Wire Types:
		- 0: VARINT (int32, int64, uint32, uint64, sint32, sint64, bool, enum)
		- 1: I64 (fixed64, sfixed64, double)
		- 2: LEN (string, bytes, embedded messages, packed repeated)
		- 5: I32 (fixed32, sfixed32, float)
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_PROTOBUF

create
	make

feature {NONE} -- Initialization

	make
			-- Create protobuf encoder/decoder.
		do
			create buffer.make (256)
		end

feature -- Wire Type Constants

	wire_type_varint: INTEGER = 0
			-- Variable-length integer.

	wire_type_i64: INTEGER = 1
			-- 64-bit fixed.

	wire_type_len: INTEGER = 2
			-- Length-delimited.

	wire_type_i32: INTEGER = 5
			-- 32-bit fixed.

feature -- Access

	buffer: ARRAYED_LIST [NATURAL_8]
			-- Encoding buffer.

	to_bytes: ARRAY [NATURAL_8]
			-- Get encoded bytes.
		local
			i: INTEGER
		do
			create Result.make_filled (0, 1, buffer.count)
			from i := 1 until i > buffer.count loop
				Result.put (buffer.i_th (i), i)
				i := i + 1
			end
		end

	to_string: STRING
			-- Get encoded bytes as string.
		local
			i: INTEGER
		do
			create Result.make (buffer.count)
			from i := 1 until i > buffer.count loop
				Result.append_character (buffer.i_th (i).to_character_8)
				i := i + 1
			end
		end

feature -- Buffer Operations

	clear
			-- Clear the buffer.
		do
			buffer.wipe_out
		end

	size: INTEGER
			-- Current buffer size.
		do
			Result := buffer.count
		end

feature -- Encoding: Tags

	encode_tag (a_field_number: INTEGER; a_wire_type: INTEGER)
			-- Encode field tag (field number + wire type).
		require
			valid_field: a_field_number >= 1
			valid_wire_type: a_wire_type >= 0 and a_wire_type <= 5
		do
			encode_varint_32 ((a_field_number |<< 3) | a_wire_type)
		end

feature -- Encoding: Varint

	encode_varint_32 (a_value: INTEGER)
			-- Encode 32-bit integer as varint.
		local
			l_value: NATURAL_32
			l_byte: NATURAL_8
		do
			l_value := a_value.to_natural_32
			from
			until
				l_value < 128
			loop
				l_byte := (l_value & 0x7F).to_natural_8 | 0x80
				buffer.extend (l_byte)
				l_value := l_value |>> 7
			end
			buffer.extend (l_value.to_natural_8)
		end

	encode_varint_64 (a_value: INTEGER_64)
			-- Encode 64-bit integer as varint.
		local
			l_value: NATURAL_64
			l_byte: NATURAL_8
		do
			l_value := a_value.to_natural_64
			from
			until
				l_value < 128
			loop
				l_byte := (l_value & 0x7F).to_natural_8 | 0x80
				buffer.extend (l_byte)
				l_value := l_value |>> 7
			end
			buffer.extend (l_value.to_natural_8)
		end

	encode_uint32 (a_value: NATURAL_32)
			-- Encode unsigned 32-bit integer.
		local
			l_value: NATURAL_32
			l_byte: NATURAL_8
		do
			l_value := a_value
			from
			until
				l_value < 128
			loop
				l_byte := (l_value & 0x7F).to_natural_8 | 0x80
				buffer.extend (l_byte)
				l_value := l_value |>> 7
			end
			buffer.extend (l_value.to_natural_8)
		end

	encode_uint64 (a_value: NATURAL_64)
			-- Encode unsigned 64-bit integer.
		local
			l_value: NATURAL_64
			l_byte: NATURAL_8
		do
			l_value := a_value
			from
			until
				l_value < 128
			loop
				l_byte := (l_value & 0x7F).to_natural_8 | 0x80
				buffer.extend (l_byte)
				l_value := l_value |>> 7
			end
			buffer.extend (l_value.to_natural_8)
		end

feature -- Encoding: ZigZag (Signed Integers)

	encode_sint32 (a_value: INTEGER)
			-- Encode signed 32-bit integer using ZigZag.
		local
			l_zigzag: NATURAL_32
		do
			-- ZigZag: (n << 1) ^ (n >> 31)
			if a_value >= 0 then l_zigzag := (a_value * 2).to_natural_32 else l_zigzag := ((-a_value * 2) - 1).to_natural_32 end
			encode_uint32 (l_zigzag)
		end

	encode_sint64 (a_value: INTEGER_64)
			-- Encode signed 64-bit integer using ZigZag.
		local
			l_zigzag: NATURAL_64
		do
			-- ZigZag: (n << 1) ^ (n >> 63)
			if a_value >= 0 then l_zigzag := (a_value * 2).to_natural_64 else l_zigzag := ((-a_value * 2) - 1).to_natural_64 end
			encode_uint64 (l_zigzag)
		end

feature -- Encoding: Fixed Width

	encode_fixed32 (a_value: NATURAL_32)
			-- Encode 32-bit fixed (little-endian).
		do
			buffer.extend ((a_value & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 8) & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 16) & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 24) & 0xFF).to_natural_8)
		end

	encode_fixed64 (a_value: NATURAL_64)
			-- Encode 64-bit fixed (little-endian).
		do
			buffer.extend ((a_value & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 8) & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 16) & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 24) & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 32) & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 40) & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 48) & 0xFF).to_natural_8)
			buffer.extend (((a_value |>> 56) & 0xFF).to_natural_8)
		end

	encode_sfixed32 (a_value: INTEGER)
			-- Encode signed 32-bit fixed.
		do
			encode_fixed32 (a_value.to_natural_32)
		end

	encode_sfixed64 (a_value: INTEGER_64)
			-- Encode signed 64-bit fixed.
		do
			encode_fixed64 (a_value.to_natural_64)
		end

feature -- Encoding: Length-Delimited

	encode_bytes (a_bytes: ARRAY [NATURAL_8])
			-- Encode byte array with length prefix.
		local
			i: INTEGER
		do
			encode_varint_32 (a_bytes.count)
			from i := a_bytes.lower until i > a_bytes.upper loop
				buffer.extend (a_bytes.item (i))
				i := i + 1
			end
		end

	encode_string (a_string: READABLE_STRING_8)
			-- Encode UTF-8 string with length prefix.
		local
			i: INTEGER
		do
			encode_varint_32 (a_string.count)
			from i := 1 until i > a_string.count loop
				buffer.extend (a_string.item (i).natural_32_code.to_natural_8)
				i := i + 1
			end
		end

	encode_bool (a_value: BOOLEAN)
			-- Encode boolean as varint.
		do
			if a_value then
				buffer.extend (1)
			else
				buffer.extend (0)
			end
		end

feature -- Encoding: Fields (Tag + Value)

	encode_int32_field (a_field_number: INTEGER; a_value: INTEGER)
			-- Encode int32 field with tag.
		do
			encode_tag (a_field_number, wire_type_varint)
			encode_varint_32 (a_value)
		end

	encode_int64_field (a_field_number: INTEGER; a_value: INTEGER_64)
			-- Encode int64 field with tag.
		do
			encode_tag (a_field_number, wire_type_varint)
			encode_varint_64 (a_value)
		end

	encode_uint32_field (a_field_number: INTEGER; a_value: NATURAL_32)
			-- Encode uint32 field with tag.
		do
			encode_tag (a_field_number, wire_type_varint)
			encode_uint32 (a_value)
		end

	encode_uint64_field (a_field_number: INTEGER; a_value: NATURAL_64)
			-- Encode uint64 field with tag.
		do
			encode_tag (a_field_number, wire_type_varint)
			encode_uint64 (a_value)
		end

	encode_sint32_field (a_field_number: INTEGER; a_value: INTEGER)
			-- Encode sint32 field with tag.
		do
			encode_tag (a_field_number, wire_type_varint)
			encode_sint32 (a_value)
		end

	encode_sint64_field (a_field_number: INTEGER; a_value: INTEGER_64)
			-- Encode sint64 field with tag.
		do
			encode_tag (a_field_number, wire_type_varint)
			encode_sint64 (a_value)
		end

	encode_bool_field (a_field_number: INTEGER; a_value: BOOLEAN)
			-- Encode bool field with tag.
		do
			encode_tag (a_field_number, wire_type_varint)
			encode_bool (a_value)
		end

	encode_string_field (a_field_number: INTEGER; a_value: READABLE_STRING_8)
			-- Encode string field with tag.
		do
			encode_tag (a_field_number, wire_type_len)
			encode_string (a_value)
		end

	encode_bytes_field (a_field_number: INTEGER; a_value: ARRAY [NATURAL_8])
			-- Encode bytes field with tag.
		do
			encode_tag (a_field_number, wire_type_len)
			encode_bytes (a_value)
		end

	encode_fixed32_field (a_field_number: INTEGER; a_value: NATURAL_32)
			-- Encode fixed32 field with tag.
		do
			encode_tag (a_field_number, wire_type_i32)
			encode_fixed32 (a_value)
		end

	encode_fixed64_field (a_field_number: INTEGER; a_value: NATURAL_64)
			-- Encode fixed64 field with tag.
		do
			encode_tag (a_field_number, wire_type_i64)
			encode_fixed64 (a_value)
		end

feature -- Decoding

	decode_from_bytes (a_bytes: ARRAY [NATURAL_8])
			-- Load bytes for decoding.
		local
			i: INTEGER
		do
			clear
			from i := a_bytes.lower until i > a_bytes.upper loop
				buffer.extend (a_bytes.item (i))
				i := i + 1
			end
			decode_position := 1
		end

	decode_from_string (a_string: READABLE_STRING_8)
			-- Load string for decoding.
		local
			i: INTEGER
		do
			clear
			from i := 1 until i > a_string.count loop
				buffer.extend (a_string.item (i).natural_32_code.to_natural_8)
				i := i + 1
			end
			decode_position := 1
		end

	has_more: BOOLEAN
			-- Are there more bytes to decode?
		do
			Result := decode_position <= buffer.count
		end

feature -- Decoding: Tags

	decode_tag: TUPLE [field_number: INTEGER; wire_type: INTEGER]
			-- Decode next tag.
		require
			has_more: has_more
		local
			l_tag: NATURAL_32
		do
			l_tag := decode_varint_32_unsigned
			Result := [((l_tag |>> 3).to_integer_32), ((l_tag & 0x07).to_integer_32)]
		end

feature -- Decoding: Varint

	decode_varint_32: INTEGER
			-- Decode varint as signed 32-bit.
		require
			has_more: has_more
		do
			Result := decode_varint_32_unsigned.to_integer_32
		end

	decode_varint_32_unsigned: NATURAL_32
			-- Decode varint as unsigned 32-bit.
		require
			has_more: has_more
		local
			l_byte: NATURAL_8
			l_shift: INTEGER
			l_result: NATURAL_32
		do
			l_shift := 0
			l_result := 0
			from
				l_byte := buffer.i_th (decode_position)
				decode_position := decode_position + 1
			until
				(l_byte & 0x80) = 0
			loop
				l_result := l_result | ((l_byte & 0x7F).to_natural_32 |<< l_shift)
				l_shift := l_shift + 7
				if decode_position <= buffer.count then
					l_byte := buffer.i_th (decode_position)
					decode_position := decode_position + 1
				else
					l_byte := 0
				end
			end
			l_result := l_result | ((l_byte & 0x7F).to_natural_32 |<< l_shift)
			Result := l_result
		end

	decode_varint_64: INTEGER_64
			-- Decode varint as signed 64-bit.
		require
			has_more: has_more
		do
			Result := decode_varint_64_unsigned.to_integer_64
		end

	decode_varint_64_unsigned: NATURAL_64
			-- Decode varint as unsigned 64-bit.
		require
			has_more: has_more
		local
			l_byte: NATURAL_8
			l_shift: INTEGER
			l_result: NATURAL_64
		do
			l_shift := 0
			l_result := 0
			from
				l_byte := buffer.i_th (decode_position)
				decode_position := decode_position + 1
			until
				(l_byte & 0x80) = 0
			loop
				l_result := l_result | ((l_byte & 0x7F).to_natural_64 |<< l_shift)
				l_shift := l_shift + 7
				if decode_position <= buffer.count then
					l_byte := buffer.i_th (decode_position)
					decode_position := decode_position + 1
				else
					l_byte := 0
				end
			end
			l_result := l_result | ((l_byte & 0x7F).to_natural_64 |<< l_shift)
			Result := l_result
		end

feature -- Decoding: ZigZag

	decode_sint32: INTEGER
			-- Decode ZigZag-encoded signed 32-bit.
		local
			l_value: NATURAL_32
		do
			l_value := decode_varint_32_unsigned
			-- Reverse ZigZag: (n >> 1) ^ -(n & 1)
			if (l_value & 1) = 0 then Result := (l_value |>> 1).to_integer_32 else Result := -(((l_value |>> 1) + 1).to_integer_32) end
		end

	decode_sint64: INTEGER_64
			-- Decode ZigZag-encoded signed 64-bit.
		local
			l_value: NATURAL_64
		do
			l_value := decode_varint_64_unsigned
			if (l_value & 1) = 0 then Result := (l_value |>> 1).to_integer_64 else Result := -(((l_value |>> 1) + 1).to_integer_64) end
		end

feature -- Decoding: Fixed Width

	decode_fixed32: NATURAL_32
			-- Decode 32-bit fixed (little-endian).
		require
			has_enough_fixed32: size >= 4
		do
			Result := buffer.i_th (decode_position).to_natural_32
			Result := Result | (buffer.i_th (decode_position + 1).to_natural_32 |<< 8)
			Result := Result | (buffer.i_th (decode_position + 2).to_natural_32 |<< 16)
			Result := Result | (buffer.i_th (decode_position + 3).to_natural_32 |<< 24)
			decode_position := decode_position + 4
		end

	decode_fixed64: NATURAL_64
			-- Decode 64-bit fixed (little-endian).
		require
			has_enough_fixed64: size >= 8
		do
			Result := buffer.i_th (decode_position).to_natural_64
			Result := Result | (buffer.i_th (decode_position + 1).to_natural_64 |<< 8)
			Result := Result | (buffer.i_th (decode_position + 2).to_natural_64 |<< 16)
			Result := Result | (buffer.i_th (decode_position + 3).to_natural_64 |<< 24)
			Result := Result | (buffer.i_th (decode_position + 4).to_natural_64 |<< 32)
			Result := Result | (buffer.i_th (decode_position + 5).to_natural_64 |<< 40)
			Result := Result | (buffer.i_th (decode_position + 6).to_natural_64 |<< 48)
			Result := Result | (buffer.i_th (decode_position + 7).to_natural_64 |<< 56)
			decode_position := decode_position + 8
		end

	decode_sfixed32: INTEGER
			-- Decode signed 32-bit fixed.
		do
			Result := decode_fixed32.to_integer_32
		end

	decode_sfixed64: INTEGER_64
			-- Decode signed 64-bit fixed.
		do
			Result := decode_fixed64.to_integer_64
		end

feature -- Decoding: Length-Delimited

	decode_string: STRING
			-- Decode length-prefixed string.
		local
			l_length, i: INTEGER
		do
			l_length := decode_varint_32
			create Result.make (l_length)
			from i := 1 until i > l_length loop
				if decode_position <= buffer.count then
					Result.append_character (buffer.i_th (decode_position).to_character_8)
					decode_position := decode_position + 1
				end
				i := i + 1
			end
		end

	decode_bytes: ARRAY [NATURAL_8]
			-- Decode length-prefixed bytes.
		local
			l_length, i: INTEGER
		do
			l_length := decode_varint_32
			create Result.make_filled (0, 1, l_length)
			from i := 1 until i > l_length loop
				if decode_position <= buffer.count then
					Result.put (buffer.i_th (decode_position), i)
					decode_position := decode_position + 1
				end
				i := i + 1
			end
		end

	decode_bool: BOOLEAN
			-- Decode boolean.
		do
			Result := decode_varint_32 /= 0
		end

	skip_field (a_wire_type: INTEGER)
			-- Skip a field based on its wire type.
		local
			l_length: INTEGER
		do
			inspect a_wire_type
			when 0 then
				-- VARINT: skip bytes until MSB is 0
				from until not has_more or else (buffer.i_th (decode_position) & 0x80) = 0 loop
					decode_position := decode_position + 1
				end
				if has_more then
					decode_position := decode_position + 1
				end
			when 1 then
				-- I64: skip 8 bytes
				decode_position := decode_position + 8
			when 2 then
				-- LEN: read length then skip
				l_length := decode_varint_32
				decode_position := decode_position + l_length
			when 5 then
				-- I32: skip 4 bytes
				decode_position := decode_position + 4
			else
				-- Unknown wire type, can't skip safely
			end
		end

feature {NONE} -- Implementation

	decode_position: INTEGER
			-- Current position in buffer for decoding.

invariant
	buffer_attached: buffer /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
