
defmodule Parser.M3UTest do

	use ExUnit.Case

	test "parse valid .m3u file" do
		{:ok, file} = StringIO.open """
		#EXTM3U

		#EXTINF:m1
		f1

		#EXTINF:m2
		f2
		"""

		assert Parser.M3U.parse(file) == ["f2", "f1"]

		StringIO.close(file)
	end

	test "parse empty file" do
		{:ok, file} = StringIO.open ""
		assert Parser.M3U.parse(file) == []
		StringIO.close(file)
	end
end
