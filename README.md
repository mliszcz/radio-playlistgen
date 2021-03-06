radio-playlistgen
=====
[![Build Status](https://img.shields.io/travis/mliszcz/radio-playlistgen/master.svg)](https://travis-ci.org/mliszcz/radio-playlistgen) 
[![Coverage](https://img.shields.io/coveralls/mliszcz/radio-playlistgen/master.svg)](https://coveralls.io/r/mliszcz/radio-playlistgen?branch=master)

# Overview

This application parses *pls*/*m3u* playlists with radio stations live streams,
filters unreachable and combines available sources into one *pls* playlist
with proper metadata.

#Example
*http://radio-one.com/listen.pls*:
```
[playlist]
NumberOfEntries=2
Version=2
Title1=
File1=http://down.stream.radio-one.com:8000/
Length1=-1
Title2=
File2=http://up.stream.radio-one.com:8000/
Length2=-1
```

*/home/me/Documents/radio.m3u*:
```
http://stream.radio-two.com:8000/
```

Usage:
```elixir
iex(1)> Radio.generate( %{
...(1)>   "Radio One" => {:pls, "http://radio.com/listen.pls"},
...(1)>   "Radio Two" => {:m3u, "/home/me/Documents/radio.m3u"}
...(1)> }, 2000) |> IO.puts
[playlist]
NumberOfEntries=2
Version=2
Title1=Radio One
File1=http://up.stream.radio-one.com:8000/
Length1=-1
Title2=Radio Two
File2=http://stream.radio-two.com:8000/
Length2=-1
```

# Configuration

`Radio.generate/2` requires two arguments:
a **map with playlists** and a **timeout value**
(after which stream will be considered as unavailable).
Both default to application's environment variables:
`:playlists` and `:timeout` respectively.
One may configure these variables in `config/config.esx`.
Note that `config/config.esx` includes `config/playlists.esx`
which contains some prefefined radio stations.
