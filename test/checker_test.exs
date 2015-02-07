
defmodule CheckerTest do

	use ExUnit.Case

	test "check IceCast stream" do
		HTTPServer.serve_once("HTTP/1.0 200 OK\r\nContent-Length: 0\r\n\r\n", 8123)
		assert Checker.check("http://localhost:8123", 2000) == true
	end

	test "check SHOUTcast stream" do
		HTTPServer.serve_once("ICY 200 OK\r\nContent-Length: 0\r\n\r\n", 8124)
		assert Checker.check("http://localhost:8124", 2000) == true
	end

	# test "check non-stream URL" do
	# 	assert Checker.check("http://google.com", 2000) == false
	# end

	test "check invalid URL" do
		assert Checker.check("http://localhost:812345", 2000) == false
	end
end
