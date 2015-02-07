
defmodule CheckerTest do

	use ExUnit.Case

	defp serve(what, port) do
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

	# TODO run mocked servers on localhost

	test "check IceCast stream" do
		serve("HTTP/1.0 200 OK\r\nContent-Length: 0\r\n\r\n", 8123)
		assert Checker.check("http://localhost:8123", 2000) == true
	end

	test "check SHOUTcast stream" do
		serve("ICY 200 OK\r\nContent-Length: 0\r\n\r\n", 8124)
		assert Checker.check("http://localhost:8124", 2000) == true
	end

	# test "check non-stream URL" do
	# 	assert Checker.check("http://google.com", 2000) == false
	# end

	test "check invalid URL" do
		assert Checker.check("http://localhost:812345", 2000) == false
	end
end
