
use Mix.Config

config :radio, :playlists, %{
	"Polskie Radio Program 1" 	=> {:pls, "http://stream3.polskieradio.pl:8900/listen.pls"},
	"Polskie Radio Program 3" 	=> {:pls, "http://stream3.polskieradio.pl:8904/listen.pls"},
	"RMF FM" 					=> {:pls, "http://www.rmfon.pl/n/rmffm.pls"},
	"RMF MAXXX" 				=> {:pls, "http://www.rmfon.pl/n/rmfmaxxx.pls"},
	"Radio ZET" 				=> {:pls, "http://91.121.179.221:8050/listen.pls"},
	"Radio ESKA Kraków" 		=> {:pls, "http://acdn.smcloud.net/t046-1.mp3.pls"},
	"Radio WAWA" 				=> {:pls, "http://acdn.smcloud.net/t050-1.mp3.pls"},
	"KRK.FM" 					=> {:m3u, "http://stream4.nadaje.com:11770/test.m3u"},
	"Radiofonia" 				=> {:pls, "http://www.rmfon.pl/n/radiofonia.pls"},
	# "Radio Złote Przeboje" 		=> {:pls, "http://www.radio.pionier.net.pl/stream.pls?radio=radio88"} # seems to be down
	"Radio Złote Przeboje" 		=> {:pls, "http://www.tuba.fm/stream.pls?radio=9&mp3=1"} # 96 kbps stream
}
