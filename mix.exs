defmodule Radio.Mixfile do
	use Mix.Project

	def project do [
		app: :radio,
		version: "0.0.1",
		elixir: "~> 1.0",
		deps: deps]
	end

	def application do [
		applications: [:logger, :inets],
		env: [playlists: %{}, timeout: 2000] ]
	end

	defp deps do
		[]
	end
end
