
defmodule Checker do

	def check(url, timeout \\ 200)

	def check(url, timeout) when is_list(url) and is_integer(timeout) do

		:inets.start()

		task = Task.async fn ->
			# async requests do not fail
			{:ok, reqRef} = :httpc.request(:get, {url, []}, [], [{:sync, :false}, {:stream, {:self, :once}}])
			receive do
				{:http, {^reqRef, :stream_start, _, _}} ->
					:httpc.cancel_request reqRef
					true
			after
				timeout ->
					:httpc.cancel_request reqRef
					false
			end
		end

		Task.await task, 2*timeout
	end

	def check(url, timeout) when is_binary(url) do
		check to_char_list(url), timeout
	end
end
