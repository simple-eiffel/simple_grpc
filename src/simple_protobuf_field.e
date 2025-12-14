note
	description: "[
		A Protocol Buffers field definition.

		Represents a single field in a protobuf message with its
		number, type, name, and value.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_PROTOBUF_FIELD

create
	make,
	make_int32,
	make_int64,
	make_uint32,
	make_uint64,
	make_sint32,
	make_sint64,
	make_bool,
	make_string,
	make_bytes,
	make_message,
	make_fixed32,
	make_fixed64

feature {NONE} -- Initialization

	make (a_number: INTEGER; a_type: INTEGER; a_value: detachable ANY)
			-- Create field with number, type, and value.
		require
			valid_number: a_number >= 1
			valid_type: a_type >= type_int32 and a_type <= type_message
		do
			number := a_number
			field_type := a_type
			value := a_value
			create name.make_empty
		ensure
			number_set: number = a_number
			type_set: field_type = a_type
			value_set: value = a_value
		end

	make_int32 (a_number: INTEGER; a_value: INTEGER)
			-- Create int32 field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_int32
			value := a_value.to_reference
			create name.make_empty
		end

	make_int64 (a_number: INTEGER; a_value: INTEGER_64)
			-- Create int64 field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_int64
			value := a_value.to_reference
			create name.make_empty
		end

	make_uint32 (a_number: INTEGER; a_value: NATURAL_32)
			-- Create uint32 field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_uint32
			value := a_value.to_reference
			create name.make_empty
		end

	make_uint64 (a_number: INTEGER; a_value: NATURAL_64)
			-- Create uint64 field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_uint64
			value := a_value.to_reference
			create name.make_empty
		end

	make_sint32 (a_number: INTEGER; a_value: INTEGER)
			-- Create sint32 field (ZigZag encoded).
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_sint32
			value := a_value.to_reference
			create name.make_empty
		end

	make_sint64 (a_number: INTEGER; a_value: INTEGER_64)
			-- Create sint64 field (ZigZag encoded).
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_sint64
			value := a_value.to_reference
			create name.make_empty
		end

	make_bool (a_number: INTEGER; a_value: BOOLEAN)
			-- Create bool field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_bool
			value := a_value.to_reference
			create name.make_empty
		end

	make_string (a_number: INTEGER; a_value: READABLE_STRING_8)
			-- Create string field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_string
			value := a_value.to_string_8
			create name.make_empty
		end

	make_bytes (a_number: INTEGER; a_value: ARRAY [NATURAL_8])
			-- Create bytes field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_bytes
			value := a_value
			create name.make_empty
		end

	make_message (a_number: INTEGER; a_value: SIMPLE_PROTOBUF_MESSAGE)
			-- Create nested message field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_message
			value := a_value
			create name.make_empty
		end

	make_fixed32 (a_number: INTEGER; a_value: NATURAL_32)
			-- Create fixed32 field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_fixed32
			value := a_value.to_reference
			create name.make_empty
		end

	make_fixed64 (a_number: INTEGER; a_value: NATURAL_64)
			-- Create fixed64 field.
		require
			valid_number: a_number >= 1
		do
			number := a_number
			field_type := type_fixed64
			value := a_value.to_reference
			create name.make_empty
		end

feature -- Type Constants

	type_int32: INTEGER = 1
	type_int64: INTEGER = 2
	type_uint32: INTEGER = 3
	type_uint64: INTEGER = 4
	type_sint32: INTEGER = 5
	type_sint64: INTEGER = 6
	type_bool: INTEGER = 7
	type_string: INTEGER = 8
	type_bytes: INTEGER = 9
	type_fixed32: INTEGER = 10
	type_fixed64: INTEGER = 11
	type_sfixed32: INTEGER = 12
	type_sfixed64: INTEGER = 13
	type_float: INTEGER = 14
	type_double: INTEGER = 15
	type_message: INTEGER = 16

feature -- Access

	number: INTEGER
			-- Field number (1-based).

	field_type: INTEGER
			-- Field type (one of type_* constants).

	name: STRING
			-- Optional field name.

	value: detachable ANY
			-- Field value.

feature -- Status

	is_varint_type: BOOLEAN
			-- Is this a varint-encoded type?
		do
			Result := field_type = type_int32 or
					  field_type = type_int64 or
					  field_type = type_uint32 or
					  field_type = type_uint64 or
					  field_type = type_sint32 or
					  field_type = type_sint64 or
					  field_type = type_bool
		end

	is_fixed32_type: BOOLEAN
			-- Is this a 32-bit fixed type?
		do
			Result := field_type = type_fixed32 or
					  field_type = type_sfixed32 or
					  field_type = type_float
		end

	is_fixed64_type: BOOLEAN
			-- Is this a 64-bit fixed type?
		do
			Result := field_type = type_fixed64 or
					  field_type = type_sfixed64 or
					  field_type = type_double
		end

	is_length_delimited: BOOLEAN
			-- Is this a length-delimited type?
		do
			Result := field_type = type_string or
					  field_type = type_bytes or
					  field_type = type_message
		end

	wire_type: INTEGER
			-- Get wire type for this field type.
		do
			if is_varint_type then
				Result := 0  -- VARINT
			elseif is_fixed64_type then
				Result := 1  -- I64
			elseif is_length_delimited then
				Result := 2  -- LEN
			elseif is_fixed32_type then
				Result := 5  -- I32
			end
		end

feature -- Element Change

	set_name (a_name: READABLE_STRING_8)
			-- Set field name.
		do
			name := a_name.to_string_8
		end

	set_value (a_value: detachable ANY)
			-- Set field value.
		do
			value := a_value
		end

feature -- Conversion

	type_name: STRING
			-- Human-readable type name.
		do
			inspect field_type
			when type_int32 then Result := "int32"
			when type_int64 then Result := "int64"
			when type_uint32 then Result := "uint32"
			when type_uint64 then Result := "uint64"
			when type_sint32 then Result := "sint32"
			when type_sint64 then Result := "sint64"
			when type_bool then Result := "bool"
			when type_string then Result := "string"
			when type_bytes then Result := "bytes"
			when type_fixed32 then Result := "fixed32"
			when type_fixed64 then Result := "fixed64"
			when type_sfixed32 then Result := "sfixed32"
			when type_sfixed64 then Result := "sfixed64"
			when type_float then Result := "float"
			when type_double then Result := "double"
			when type_message then Result := "message"
			else
				Result := "unknown"
			end
		end

invariant
	valid_number: number >= 1
	name_attached: name /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
