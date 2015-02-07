ExUnit.start()

defmodule HTTPServer do

	def serve_once(what, port) do
		me = self
		ref = make_ref
		Task.async fn ->
			{:ok, ss} = :gen_tcp.listen(port, [])
			send me, {:ok, ref}
			{:ok, s} = :gen_tcp.accept(ss)
			:gen_tcp.recv(s, 0)
			:gen_tcp.send(s, what)
			:gen_tcp.close(s)
			:gen_tcp.close(ss)
		end
		receive do
			{:ok, ^ref} -> :ok
		end
	end

end
