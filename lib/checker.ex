
defmodule Checker do

	@infty 999999999

	def check(url, timeout) when is_list(url) and is_integer(timeout) do

		task = Task.async fn ->

			# async requests do not fail
			{:ok, reqRef} = :httpc.request(:get, {url, []}, [], [{:sync, :false}, {:stream, {:self, :once}}])

			receive do

				{:http, {^reqRef, :stream_start, _, _}} ->
					# IceCast stream
					:httpc.cancel_request reqRef
					true

				{:http, {^reqRef, {:error, {:could_not_parse_as_http, body}}}} ->
					# SHOUTcast stream
					:httpc.cancel_request reqRef
					String.starts_with? body, "ICY 200 OK"
			after
				timeout ->
					:httpc.cancel_request reqRef
					false
			end
		end

		Task.await task, @infty
	end

	def check(url, timeout) when is_binary(url) do
		check to_char_list(url), timeout
	end
end
