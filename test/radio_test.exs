
defmodule RadioTest do

	use ExUnit.Case

	test "generate playlist file" do

		playlist1 = """
		NumberOfEntries=1
		Version=2
		Title1=non-existent stream
		File1=http://localhost:8101
		Length1=-1
		Title2=existing stream
		File2=http://localhost:8102
		Length2=l2
		"""

		HTTPServer.serve_once("HTTP/1.0 200 OK\r\nContent-Length: 0\r\n\r\n", 8102)
		HTTPServer.serve_once("HTTP/1.0 200 OK\r\nContent-Length: #{byte_size playlist1}\r\n\r\n#{playlist1}", 8100)

		playlist2 = """
		http://localhost:8201
		http://localhost:8202
		"""

		HTTPServer.serve_once("HTTP/1.0 200 OK\r\nContent-Length: 0\r\n\r\n", 8202)
		HTTPServer.serve_once("HTTP/1.0 200 OK\r\nContent-Length: #{byte_size playlist2}\r\n\r\n#{playlist2}", 8200)

		result = Radio.generate( %{
			"Radio@8100" => {:pls, "http://localhost:8100"},
			"Radio@8200" => {:m3u, "http://localhost:8200"}
		}, 2000)

		assert result == """
		[playlist]
		NumberOfEntries=2
		Version=2
		File1=http://localhost:8102
		Title1=Radio@8100
		Length1=-1
		File2=http://localhost:8202
		Title2=Radio@8200
		Length2=-1

		"""
	end
end
