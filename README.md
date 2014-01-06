Kurea [![Probably a passing build!](https://api.travis-ci.org/kellyirc/kurea.png?branch=master)](https://travis-ci.org/kellyirc/kurea/)
=====

An IRC bot written for node.js in CoffeeScript, successor of [Vivio](https://github.com/seiyria/vivio), the Java IRC bot.

Installation
============
First, clone the repository. In the root of the repository, run `npm install` to get all of the dependencies.

Running the Bot
===============
First, make a copy of `config.json.sample` and call it `config.json`. Edit this to make the bot join your server/channels and give it any other configuration details necessary. Next, in the root of the repository, run `npm start`.

Developing the Bot
==================
Use `grunt dev` to manage linting the source and running unit tests.

Config options
==============
This group of options comes straight from irc.Client in [node-irc](https://github.com/martynsmith/node-irc). They're either self explanatory or explained in the [node-irc documentation](https://node-irc.readthedocs.org/en/latest/API.html#client).
```
{
	"userName": "Kurea",
	"realName": "Kurea IRC Bot",
	"autoRejoin": false,
	"autoConnect": true,
	"secure": false,
	"selfSigned": false,
	"certExpired": false,
	"floodProtection": true,
	"floodProtectionDelay": "500",
	"sasl": false,
	"stripColors": false,
	"channelPrefixes": "&#",
	"messageSplit": "512",
```
The nickname the bot will attempt to log in as.
```
	"nick": "Moop",
```
Whether raw output will be sent to std out or not.
```	
	"verbose": false,
```
Which user manager under src/auth to use, which is used to keep track of data per-user, such as permissions.
```
	"auth": "nickserv",
```
The nickname of the bot's owner.
```
	"owner": "YourUsername",
```
What type of database to use. Use nedb for a local db. Use mongo if you want to use mongo. Only mongo requires a storageURL.
```
	"storage": "mongo",
	"storageURL": "localhost:28017",
```
This object contains options for every instance of the bot that will be connected to a server. The key is the name of the bot, which is only used internally.
```
	"bots": {
		"Moop-Esper": {
```
Self explanatory connection options.
```
			"server": "irc.esper.net",
			"port": "6667",
			"channels": ["#kellyirc", "#kurea"],
			"password": "insert_password_here"
		},
		"Moop-FreeNode": {
			"server": "irc.freenode.net",
			"port": "6667",
			"channels": ["#kurea"]
		}
	},
```
Some modules like WordnikModule or WolframModule require API keys to access their respective APIs. If you wish to use them, sign up for and supply your own key.
```
	"apiKeys": {
		"wordnik": "GET YOUR OWN",
		"wolfram": "HAHA YOU WISH"
	}
}
```

