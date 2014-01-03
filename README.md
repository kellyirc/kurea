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
