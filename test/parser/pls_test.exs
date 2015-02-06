
defmodule Parser.PLSTest do

	use ExUnit.Case

	test "parse valid .pls file" do
		{:ok, file} = StringIO.open """
		NumberOfEntries=2
		Version=2
		Title1=t1
		File1=f1
		Length1=l1
		Title2=t2
		File2=f2
		Length2=l2
		""", [:utf8]

		assert Parser.PLS.parse(file) == ["f2", "f1"]

		StringIO.close(file)
	end

	test "parse invalid file" do
		{:ok, file} = StringIO.open """
		some dummy data
		which is not in
		pls file format
		""", [:utf8]

		assert Parser.PLS.parse(file) == []

		StringIO.close(file)
	end

	test "parse empty file" do
		{:ok, file} = StringIO.open "", [:utf8]
		assert Parser.PLS.parse(file) == []
		StringIO.close(file)
	end
end
