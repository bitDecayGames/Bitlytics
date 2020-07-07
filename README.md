# Bitlytics

A simple analytics library designed to ship data points out to an HTTP endpoint

# Features

* Automatic tagging
	* Client ID
	* Session ID
* Event batching to reduce network traffic
* Session time tracking

# Support

Currently only InfluxDB Cloud is supported

# Usage

1. Create a sender
	```
	var sender = new InfluxDB(<endpointURL>, <organization>, <bucketID>, <authToken>);
	```
1. Initialize Bitlytics
	```
	Bitlytics.Init("Brawnfire", sender);
	```
1. (Optional) Set to dev mode while in-dev to prevent sending metrics to the server
	```
	Bitlytics.Instance().SetDevMode(true);
	```
	* This can also be done via the `-D dev_analytics` compilation flag
1. Start a session to create data points within
	```
	Bitlytics.Instance().NewSession();
	```
1. Write data points
	```
	Bitlytics.Instance().Queue(Common.GameStarted, 1);
	```
1. (Optional) Pause/Resume session
	```
	Bitlytics.Instance().Pause();
	.
	.
	.
	Bitlytics.Instance().Resume();
	```
1. End Session when finished
	```
	Bitlytics.Instance().EndSession();
	```

# Sessions

* A session is a period of time the player is considered to be "playing" the game.
* Sessions automatically track play time
	* Sessions can be paused to keep play time more accurate (such as when the window loses focus)
	* Due to limitations of detecting when an HTML5 game is closed, play time is reported every time metrics are sent up to the API.
* Sessions will automatically report all data on an configurable interval set when starting a new session.

# Tags

* Sessions will automatically attach a default set of tags to all metrics:
	* GameID
	* ClientID
	* SessionID
	* Session Number
* Custom tags can be added one of two ways:
	1. Added to individual metrics by specifying them as an optional parameter to `Bitlytics.Instance().Queue(...)`
	1. Added as default tags to be attached to all metrics in a session via `Bitlytics.Instance().AddSessionTag(...)`
* Tags are a way to help group a set of metrics together and should not contain the measured data.

# Events

* Event are reported via `Bitlytics.Instance().Queue(...)`
* Event names should not have duplication of tag values as it is not needed
* Event values currently only support floats