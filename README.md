# Bitlytics

A simple analytics library designed to ship data points out to an HTTP endpoint

# Features

* Client ID
* Session ID

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
1. (Optional) Set to debug mode while in-dev
	```
	Bitlytics.Instance().SetDebug(true);
	```
1. Start a session to create data points within
	```
	Bitlytics.Instance().NewSession();
	```
1. Write data points
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