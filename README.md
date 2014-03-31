Accord CLI
==========

[![npm](https://badge.fury.io/js/accord-cli.png)](http://badge.fury.io/js/accord-cli)  [![dependencies](https://david-dm.org/carrot/accord-cli.png)](https://david-dm.org/carrot/accord-cli)[![tests](https://travis-ci.org/carrot/accord-cli.png?branch=master)](https://travis-ci.org/carrot/accord-cli)

Compile any language from the command line

> **Note:** This project is in early development, and versioning is a little different. [Read this](http://markup.im/#q4_cRZ1Q) for more details.

### Why should you care?

Based on a careful analysis of your location, the time of day, and the force with which you have been hitting keys on your keyboard, we have determined with 98% confidence that you might have been recently thinking, _"Man, I really wish I could compile any js-based language via the command line just to quickly see the output"_. Well, you're in luck, that's pretty much exactly what accord cli will do for you.

[Accord](https://github.com/jenius/accord) is a unified interface to a bunch of different compiled languages that you might be using as a part of your web stack. By ensuring that the interfaces are consistent, you can use any language that accord supports in the same way, without having to wade through pages of API docs to figure out how it's public API works. Most importantly, you can switch between two different languages with minimal pain. While accord is built for programmatic use, this project exposes a nice clean CLI interface so you can compile and watch from your command line. Whoo!

### Installation

```
npm install accord-cli -g
```

### Usage

To compile, just pass the filename with the `--compile` or `-c` flag:

```
$ accord -c foo.jade
```

To compile to a specific output location, use the `--out` or `-o` flag:

```
$ accord -c foo.jade -o bar.html
```

To compile with options, just put in your options as flags as such:

```
$ accord -c foo.jade --name 'doge' --location 'nyc'
```

To watch a file, recompiling it any time it changes, use the `--watch` or `-w` flag:

```
$ accord -w foo.jade
```

...that's it! For all usage options, just run `accord` or `accord help`

### License & Contributing

- Details on the license [can be found here](LICENSE.md)
- Details on running tests and contributing [can be found here](contributing.md)
