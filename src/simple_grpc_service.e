note
	description: "[
		gRPC service definition.

		A service is a collection of RPC methods.
		Service name format: package.ServiceName (e.g., helloworld.Greeter)
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_GRPC_SERVICE

create
	make

feature {NONE} -- Initialization

	make (a_name: READABLE_STRING_8)
			-- Create service with name.
		require
			name_not_empty: not a_name.is_empty
		do
			create name.make_from_string (a_name)
			create methods.make (10)
		ensure
			name_set: name.same_string (a_name)
		end

feature -- Access

	name: STRING
			-- Service name (package.ServiceName).

	methods: HASH_TABLE [SIMPLE_GRPC_METHOD, STRING]
			-- Methods by name.

	method (a_name: READABLE_STRING_8): detachable SIMPLE_GRPC_METHOD
			-- Get method by name.
		do
			Result := methods.item (a_name.to_string_8)
		end

	method_count: INTEGER
			-- Number of methods.
		do
			Result := methods.count
		end

feature -- Element Change

	add_method (a_method: SIMPLE_GRPC_METHOD)
			-- Add a method to the service.
		require
			method_not_void: a_method /= Void
		do
			methods.put (a_method, a_method.name)
		ensure
			method_added: methods.has (a_method.name)
		end

	add_unary_method (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8)
			-- Add a unary method.
		require
			name_not_empty: not a_name.is_empty
		local
			l_method: SIMPLE_GRPC_METHOD
		do
			create l_method.make_unary (a_name, a_request_type, a_response_type)
			add_method (l_method)
		end

	add_server_streaming_method (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8)
			-- Add a server streaming method.
		require
			name_not_empty: not a_name.is_empty
		local
			l_method: SIMPLE_GRPC_METHOD
		do
			create l_method.make_server_streaming (a_name, a_request_type, a_response_type)
			add_method (l_method)
		end

	add_client_streaming_method (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8)
			-- Add a client streaming method.
		require
			name_not_empty: not a_name.is_empty
		local
			l_method: SIMPLE_GRPC_METHOD
		do
			create l_method.make_client_streaming (a_name, a_request_type, a_response_type)
			add_method (l_method)
		end

	add_bidirectional_method (a_name: READABLE_STRING_8; a_request_type: READABLE_STRING_8; a_response_type: READABLE_STRING_8)
			-- Add a bidirectional streaming method.
		require
			name_not_empty: not a_name.is_empty
		local
			l_method: SIMPLE_GRPC_METHOD
		do
			create l_method.make_bidirectional (a_name, a_request_type, a_response_type)
			add_method (l_method)
		end

	remove_method (a_name: READABLE_STRING_8)
			-- Remove a method by name.
		do
			methods.remove (a_name.to_string_8)
		end

feature -- Status

	has_method (a_name: READABLE_STRING_8): BOOLEAN
			-- Does service have method with name?
		do
			Result := methods.has (a_name.to_string_8)
		end

feature -- Conversion

	method_path (a_method_name: READABLE_STRING_8): STRING
			-- Full method path: /package.Service/Method
		do
			create Result.make (50)
			Result.append_character ('/')
			Result.append (name)
			Result.append_character ('/')
			Result.append (a_method_name)
		end

	package_name: STRING
			-- Extract package name from service name.
		local
			l_dot: INTEGER
		do
			l_dot := name.last_index_of ('.', name.count)
			if l_dot > 0 then
				Result := name.substring (1, l_dot - 1)
			else
				create Result.make_empty
			end
		end

	simple_name: STRING
			-- Extract simple service name (without package).
		local
			l_dot: INTEGER
		do
			l_dot := name.last_index_of ('.', name.count)
			if l_dot > 0 and l_dot < name.count then
				Result := name.substring (l_dot + 1, name.count)
			else
				Result := name.twin
			end
		end

feature -- Iteration

	do_all_methods (a_action: PROCEDURE [SIMPLE_GRPC_METHOD])
			-- Execute action for each method.
		do
			from methods.start until methods.after loop
				a_action.call ([methods.item_for_iteration])
				methods.forth
			end
		end

invariant
	name_not_empty: not name.is_empty
	methods_attached: methods /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
