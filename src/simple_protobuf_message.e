note
	description: "[
		A Protocol Buffers message container.

		Holds fields with their values for encoding/decoding.
		Provides a dynamic message structure without code generation.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_PROTOBUF_MESSAGE

create
	make,
	make_with_name

feature {NONE} -- Initialization

	make
			-- Create empty message.
		do
			create name.make_empty
			create fields.make (10)
		end

	make_with_name (a_name: READABLE_STRING_8)
			-- Create message with type name.
		require
			name_not_empty: not a_name.is_empty
		do
			create name.make_from_string (a_name)
			create fields.make (10)
		ensure
			name_set: name.same_string (a_name)
		end

feature -- Access

	name: STRING
			-- Message type name (fully qualified).

	fields: ARRAYED_LIST [SIMPLE_PROTOBUF_FIELD]
			-- Message fields.

	field (a_number: INTEGER): detachable SIMPLE_PROTOBUF_FIELD
			-- Field by number, or Void if not found.
		local
			i: INTEGER
		do
			from i := 1 until i > fields.count or Result /= Void loop
				if fields.i_th (i).number = a_number then
					Result := fields.i_th (i)
				end
				i := i + 1
			end
		end

	field_by_name (a_name: READABLE_STRING_8): detachable SIMPLE_PROTOBUF_FIELD
			-- Field by name, or Void if not found.
		local
			i: INTEGER
		do
			from i := 1 until i > fields.count or Result /= Void loop
				if fields.i_th (i).name.same_string (a_name) then
					Result := fields.i_th (i)
				end
				i := i + 1
			end
		end

feature -- Field Access Helpers

	int32_value (a_field_number: INTEGER): INTEGER
			-- Get int32 field value.
		local
			l_field: like field
		do
			l_field := field (a_field_number)
			if attached l_field and then attached {INTEGER_REF} l_field.value as l_int then
				Result := l_int.item
			end
		end

	int64_value (a_field_number: INTEGER): INTEGER_64
			-- Get int64 field value.
		local
			l_field: like field
		do
			l_field := field (a_field_number)
			if attached l_field and then attached {INTEGER_64_REF} l_field.value as l_int then
				Result := l_int.item
			end
		end

	string_value (a_field_number: INTEGER): STRING
			-- Get string field value.
		local
			l_field: like field
		do
			l_field := field (a_field_number)
			if attached l_field and then attached {READABLE_STRING_8} l_field.value as l_str then
				Result := l_str.to_string_8
			else
				create Result.make_empty
			end
		end

	bool_value (a_field_number: INTEGER): BOOLEAN
			-- Get bool field value.
		local
			l_field: like field
		do
			l_field := field (a_field_number)
			if attached l_field and then attached {BOOLEAN_REF} l_field.value as l_bool then
				Result := l_bool.item
			end
		end

	bytes_value (a_field_number: INTEGER): ARRAY [NATURAL_8]
			-- Get bytes field value.
		local
			l_field: like field
		do
			l_field := field (a_field_number)
			if attached l_field and then attached {ARRAY [NATURAL_8]} l_field.value as l_bytes then
				Result := l_bytes
			else
				create Result.make_empty
			end
		end

	message_value (a_field_number: INTEGER): detachable SIMPLE_PROTOBUF_MESSAGE
			-- Get nested message field value.
		local
			l_field: like field
		do
			l_field := field (a_field_number)
			if attached l_field and then attached {SIMPLE_PROTOBUF_MESSAGE} l_field.value as l_msg then
				Result := l_msg
			end
		end

feature -- Element Change

	set_name (a_name: READABLE_STRING_8)
			-- Set message type name.
		do
			name := a_name.to_string_8
		end

	add_field (a_field: SIMPLE_PROTOBUF_FIELD)
			-- Add a field to the message.
		require
			field_not_void: a_field /= Void
		do
			fields.extend (a_field)
		ensure
			field_added: fields.has (a_field)
		end

	set_int32 (a_field_number: INTEGER; a_value: INTEGER)
			-- Set int32 field.
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_int32 (a_field_number, a_value)
			add_or_update_field (l_field)
		end

	set_int64 (a_field_number: INTEGER; a_value: INTEGER_64)
			-- Set int64 field.
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_int64 (a_field_number, a_value)
			add_or_update_field (l_field)
		end

	set_uint32 (a_field_number: INTEGER; a_value: NATURAL_32)
			-- Set uint32 field.
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_uint32 (a_field_number, a_value)
			add_or_update_field (l_field)
		end

	set_uint64 (a_field_number: INTEGER; a_value: NATURAL_64)
			-- Set uint64 field.
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_uint64 (a_field_number, a_value)
			add_or_update_field (l_field)
		end

	set_sint32 (a_field_number: INTEGER; a_value: INTEGER)
			-- Set sint32 field (ZigZag encoded).
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_sint32 (a_field_number, a_value)
			add_or_update_field (l_field)
		end

	set_sint64 (a_field_number: INTEGER; a_value: INTEGER_64)
			-- Set sint64 field (ZigZag encoded).
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_sint64 (a_field_number, a_value)
			add_or_update_field (l_field)
		end

	set_bool (a_field_number: INTEGER; a_value: BOOLEAN)
			-- Set bool field.
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_bool (a_field_number, a_value)
			add_or_update_field (l_field)
		end

	set_string (a_field_number: INTEGER; a_value: READABLE_STRING_8)
			-- Set string field.
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_string (a_field_number, a_value)
			add_or_update_field (l_field)
		end

	set_bytes (a_field_number: INTEGER; a_value: ARRAY [NATURAL_8])
			-- Set bytes field.
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_bytes (a_field_number, a_value)
			add_or_update_field (l_field)
		end

	set_message (a_field_number: INTEGER; a_value: SIMPLE_PROTOBUF_MESSAGE)
			-- Set nested message field.
		local
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_field.make_message (a_field_number, a_value)
			add_or_update_field (l_field)
		end

feature -- Encoding

	encode: ARRAY [NATURAL_8]
			-- Encode message to bytes.
		local
			l_protobuf: SIMPLE_PROTOBUF
			i: INTEGER
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			create l_protobuf.make
			from i := 1 until i > fields.count loop
				l_field := fields.i_th (i)
				encode_field (l_protobuf, l_field)
				i := i + 1
			end
			Result := l_protobuf.to_bytes
		end

	encode_to_string: STRING
			-- Encode message to string.
		local
			l_bytes: ARRAY [NATURAL_8]
			i: INTEGER
		do
			l_bytes := encode
			create Result.make (l_bytes.count)
			from i := l_bytes.lower until i > l_bytes.upper loop
				Result.append_character (l_bytes.item (i).to_character_8)
				i := i + 1
			end
		end

feature -- Decoding

	decode (a_bytes: ARRAY [NATURAL_8])
			-- Decode message from bytes.
		local
			l_protobuf: SIMPLE_PROTOBUF
			l_tag: TUPLE [field_number: INTEGER; wire_type: INTEGER]
			l_field: SIMPLE_PROTOBUF_FIELD
		do
			fields.wipe_out
			create l_protobuf.make
			l_protobuf.decode_from_bytes (a_bytes)
			from
			until
				not l_protobuf.has_more
			loop
				l_tag := l_protobuf.decode_tag
				l_field := decode_field (l_protobuf, l_tag.field_number, l_tag.wire_type)
				if attached l_field then
					fields.extend (l_field)
				end
			end
		end

	decode_from_string (a_string: READABLE_STRING_8)
			-- Decode message from string.
		local
			l_bytes: ARRAY [NATURAL_8]
			i: INTEGER
		do
			create l_bytes.make_filled (0, 1, a_string.count)
			from i := 1 until i > a_string.count loop
				l_bytes.put (a_string.item (i).natural_32_code.to_natural_8, i)
				i := i + 1
			end
			decode (l_bytes)
		end

feature {NONE} -- Implementation

	add_or_update_field (a_field: SIMPLE_PROTOBUF_FIELD)
			-- Add field or update existing with same number.
		local
			i: INTEGER
			l_found: BOOLEAN
		do
			from i := 1 until i > fields.count or l_found loop
				if fields.i_th (i).number = a_field.number then
					fields.put_i_th (a_field, i)
					l_found := True
				end
				i := i + 1
			end
			if not l_found then
				fields.extend (a_field)
			end
		end

	encode_field (a_protobuf: SIMPLE_PROTOBUF; a_field: SIMPLE_PROTOBUF_FIELD)
			-- Encode a single field.
		do
			inspect a_field.field_type
			when {SIMPLE_PROTOBUF_FIELD}.type_int32 then
				if attached {INTEGER_REF} a_field.value as l_int then
					a_protobuf.encode_int32_field (a_field.number, l_int.item)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_int64 then
				if attached {INTEGER_64_REF} a_field.value as l_int then
					a_protobuf.encode_int64_field (a_field.number, l_int.item)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_uint32 then
				if attached {NATURAL_32_REF} a_field.value as l_nat then
					a_protobuf.encode_uint32_field (a_field.number, l_nat.item)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_uint64 then
				if attached {NATURAL_64_REF} a_field.value as l_nat then
					a_protobuf.encode_uint64_field (a_field.number, l_nat.item)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_sint32 then
				if attached {INTEGER_REF} a_field.value as l_int then
					a_protobuf.encode_sint32_field (a_field.number, l_int.item)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_sint64 then
				if attached {INTEGER_64_REF} a_field.value as l_int then
					a_protobuf.encode_sint64_field (a_field.number, l_int.item)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_bool then
				if attached {BOOLEAN_REF} a_field.value as l_bool then
					a_protobuf.encode_bool_field (a_field.number, l_bool.item)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_string then
				if attached {READABLE_STRING_8} a_field.value as l_str then
					a_protobuf.encode_string_field (a_field.number, l_str)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_bytes then
				if attached {ARRAY [NATURAL_8]} a_field.value as l_bytes then
					a_protobuf.encode_bytes_field (a_field.number, l_bytes)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_message then
				if attached {SIMPLE_PROTOBUF_MESSAGE} a_field.value as l_msg then
					a_protobuf.encode_bytes_field (a_field.number, l_msg.encode)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_fixed32 then
				if attached {NATURAL_32_REF} a_field.value as l_nat then
					a_protobuf.encode_fixed32_field (a_field.number, l_nat.item)
				end
			when {SIMPLE_PROTOBUF_FIELD}.type_fixed64 then
				if attached {NATURAL_64_REF} a_field.value as l_nat then
					a_protobuf.encode_fixed64_field (a_field.number, l_nat.item)
				end
			else
				-- Unknown field type, skip
			end
		end

	decode_field (a_protobuf: SIMPLE_PROTOBUF; a_field_number: INTEGER; a_wire_type: INTEGER): detachable SIMPLE_PROTOBUF_FIELD
			-- Decode a single field based on wire type.
		do
			inspect a_wire_type
			when 0 then
				-- VARINT: could be int32, int64, uint32, uint64, sint32, sint64, bool, enum
				-- Default to int64 as it can hold all values
				create Result.make_int64 (a_field_number, a_protobuf.decode_varint_64)
			when 1 then
				-- I64: fixed64, sfixed64, double
				create Result.make_fixed64 (a_field_number, a_protobuf.decode_fixed64)
			when 2 then
				-- LEN: string, bytes, embedded messages, packed repeated
				-- Default to bytes
				create Result.make_bytes (a_field_number, a_protobuf.decode_bytes)
			when 5 then
				-- I32: fixed32, sfixed32, float
				create Result.make_fixed32 (a_field_number, a_protobuf.decode_fixed32)
			else
				-- Unknown wire type, skip
				a_protobuf.skip_field (a_wire_type)
			end
		end

invariant
	fields_attached: fields /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
