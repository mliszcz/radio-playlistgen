
use Mix.Config

config :logger, :console,
	level: :info,
	format: "$date $time [$level] $metadata$message\n",
	metadata: [:user_id]

config :radio, :timeout, 2000

import_config "playlists.exs"
