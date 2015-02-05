
defmodule Checker do

	def check(url) when is_list(url) do

		:inets.start()

		task = Task.async fn ->
			# async requests do not fail
			{:ok, reqRef} = :httpc.request(:get, {url, []}, [], [{:sync, :false}, {:stream, {:self, :once}}])
			receive do
				{:http, {^reqRef, :stream_start, _, _}} -> true
			after
				200 -> false
			end
		end

		Task.await task
	end

	def check(url) when is_binary(url) do
		check to_char_list url
	end
end
