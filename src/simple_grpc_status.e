note
	description: "[
		gRPC status codes and status handling.

		gRPC defines 17 status codes (0-16) for RPC results.
		Status 0 (OK) indicates success; all others indicate errors.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_GRPC_STATUS

create
	make,
	make_ok,
	make_error

feature {NONE} -- Initialization

	make (a_code: INTEGER; a_message: READABLE_STRING_8)
			-- Create status with code and message.
		require
			valid_code: a_code >= 0 and a_code <= 16
		do
			code := a_code
			create message.make_from_string (a_message)
		ensure
			code_set: code = a_code
			message_set: message.same_string (a_message)
		end

	make_ok
			-- Create OK status.
		do
			code := status_ok
			create message.make_empty
		ensure
			is_ok: is_ok
		end

	make_error (a_code: INTEGER; a_message: READABLE_STRING_8)
			-- Create error status.
		require
			is_error_code: a_code > 0 and a_code <= 16
		do
			code := a_code
			create message.make_from_string (a_message)
		ensure
			not_ok: not is_ok
		end

feature -- Status Code Constants

	status_ok: INTEGER = 0
			-- Not an error; returned on success.

	status_cancelled: INTEGER = 1
			-- The operation was cancelled.

	status_unknown: INTEGER = 2
			-- Unknown error.

	status_invalid_argument: INTEGER = 3
			-- Client specified an invalid argument.

	status_deadline_exceeded: INTEGER = 4
			-- Deadline expired before operation could complete.

	status_not_found: INTEGER = 5
			-- Some requested entity was not found.

	status_already_exists: INTEGER = 6
			-- Entity we attempted to create already exists.

	status_permission_denied: INTEGER = 7
			-- Caller does not have permission.

	status_resource_exhausted: INTEGER = 8
			-- Some resource has been exhausted.

	status_failed_precondition: INTEGER = 9
			-- System is not in required state.

	status_aborted: INTEGER = 10
			-- Operation was aborted.

	status_out_of_range: INTEGER = 11
			-- Operation was attempted past valid range.

	status_unimplemented: INTEGER = 12
			-- Operation is not implemented.

	status_internal: INTEGER = 13
			-- Internal error.

	status_unavailable: INTEGER = 14
			-- Service is currently unavailable.

	status_data_loss: INTEGER = 15
			-- Unrecoverable data loss or corruption.

	status_unauthenticated: INTEGER = 16
			-- Request does not have valid authentication.

feature -- Access

	code: INTEGER
			-- Status code (0-16).

	message: STRING
			-- Status message.

feature -- Status

	is_ok: BOOLEAN
			-- Is this a success status?
		do
			Result := code = status_ok
		end

	is_error: BOOLEAN
			-- Is this an error status?
		do
			Result := code /= status_ok
		end

	is_retryable: BOOLEAN
			-- Should client retry on this error?
		do
			Result := code = status_unavailable or
					  code = status_aborted or
					  code = status_resource_exhausted
		end

feature -- Conversion

	code_name: STRING
			-- Human-readable code name.
		do
			inspect code
			when status_ok then Result := "OK"
			when status_cancelled then Result := "CANCELLED"
			when status_unknown then Result := "UNKNOWN"
			when status_invalid_argument then Result := "INVALID_ARGUMENT"
			when status_deadline_exceeded then Result := "DEADLINE_EXCEEDED"
			when status_not_found then Result := "NOT_FOUND"
			when status_already_exists then Result := "ALREADY_EXISTS"
			when status_permission_denied then Result := "PERMISSION_DENIED"
			when status_resource_exhausted then Result := "RESOURCE_EXHAUSTED"
			when status_failed_precondition then Result := "FAILED_PRECONDITION"
			when status_aborted then Result := "ABORTED"
			when status_out_of_range then Result := "OUT_OF_RANGE"
			when status_unimplemented then Result := "UNIMPLEMENTED"
			when status_internal then Result := "INTERNAL"
			when status_unavailable then Result := "UNAVAILABLE"
			when status_data_loss then Result := "DATA_LOSS"
			when status_unauthenticated then Result := "UNAUTHENTICATED"
			else
				Result := "UNKNOWN(" + code.out + ")"
			end
		end

	to_string: STRING
			-- Full status string.
		do
			create Result.make (50)
			Result.append (code_name)
			if not message.is_empty then
				Result.append (": ")
				Result.append (message)
			end
		end

feature -- Factory Methods

	ok: SIMPLE_GRPC_STATUS
			-- Create OK status.
		do
			create Result.make_ok
		ensure
			is_ok: Result.is_ok
		end

	cancelled (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create CANCELLED status.
		do
			create Result.make (status_cancelled, a_message)
		end

	unknown (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create UNKNOWN status.
		do
			create Result.make (status_unknown, a_message)
		end

	invalid_argument (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create INVALID_ARGUMENT status.
		do
			create Result.make (status_invalid_argument, a_message)
		end

	deadline_exceeded (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create DEADLINE_EXCEEDED status.
		do
			create Result.make (status_deadline_exceeded, a_message)
		end

	not_found (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create NOT_FOUND status.
		do
			create Result.make (status_not_found, a_message)
		end

	already_exists (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create ALREADY_EXISTS status.
		do
			create Result.make (status_already_exists, a_message)
		end

	permission_denied (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create PERMISSION_DENIED status.
		do
			create Result.make (status_permission_denied, a_message)
		end

	resource_exhausted (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create RESOURCE_EXHAUSTED status.
		do
			create Result.make (status_resource_exhausted, a_message)
		end

	failed_precondition (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create FAILED_PRECONDITION status.
		do
			create Result.make (status_failed_precondition, a_message)
		end

	aborted (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create ABORTED status.
		do
			create Result.make (status_aborted, a_message)
		end

	out_of_range (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create OUT_OF_RANGE status.
		do
			create Result.make (status_out_of_range, a_message)
		end

	unimplemented (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create UNIMPLEMENTED status.
		do
			create Result.make (status_unimplemented, a_message)
		end

	internal (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create INTERNAL status.
		do
			create Result.make (status_internal, a_message)
		end

	unavailable (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create UNAVAILABLE status.
		do
			create Result.make (status_unavailable, a_message)
		end

	data_loss (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create DATA_LOSS status.
		do
			create Result.make (status_data_loss, a_message)
		end

	unauthenticated (a_message: READABLE_STRING_8): SIMPLE_GRPC_STATUS
			-- Create UNAUTHENTICATED status.
		do
			create Result.make (status_unauthenticated, a_message)
		end

invariant
	valid_code: code >= 0 and code <= 16
	message_attached: message /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
