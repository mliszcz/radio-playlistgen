
defmodule CheckerTest do

	use ExUnit.Case

	# TODO run mocked servers on localhost

	test "check IceCast stream" do
		assert Checker.check("http://31.192.216.5:8000/rmf_fm", 2000) == true
	end

	test "check SHOUTcast stream" do
		assert Checker.check("http://stream3.polskieradio.pl:8900/", 2000) == true
	end

	# test "check non-stream URL" do
	# 	assert Checker.check("http://google.com", 2000) == false
	# end

	test "check invalid URL" do
		assert Checker.check("http://some.site.that.does.not.exist:12345", 2000) == false
	end
end
