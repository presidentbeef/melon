## MELON

MELON is a new communication paradigm for mobile ad hoc networks (MANETs).

This library is a prototype implementation of MELON in Ruby using ZeroMQ.

### Concepts

Conceptionally, MELON communicates via a semi-persistent shared storage space.
Messages are retrieved by matching them against a template (similar to tuple-spaces).
Templates may really be any features, but in this implementation messages are arrays and they are matched using arrays with either literal values (e.g., `1`) or classes (e.g, `Integer`).

MELON has two basic types of messages: read-only and take-only.

Read-only messages may only be retrieved by copying, never removed from the storage space.
These can be considered "broadcast" messages.

Take-only messages may only be retrieved from the storage space by removal, and only once.

All messages may only be retrieved once by a given process. Messages are retrieved in per-sender FIFO order. In other words, messages from a given sender will be retrieved in the order that sender stored them.

MELON also provides bulk read and take operations.

### Operations

* `Melon#store` - store a take-only message
* `Melon#write` - store a read-only message
* `Melon#take` - retrieve a matching take-only message
* `Melon#read` - retrieve a matching read-only message
* `Melon#take_all` - retrieve all available matching take-only messages
* `Melon#read_all` - retrieve all available matching read-only messages

Retrieval operations are blocking by default. They will block the process until a matching message is found. To return `nil` after a best-effort search of available processes, pass `false` as the second argument.

Note all retrieval methods are best effort. There is no guarantee that a matching message will be retrieved, even if it exists.

Guarantees:

* Each message will only be retrieved at most once per process
* Matching messages will be retrieved in per-process FIFO order
* Take-only messages can only be retrieved at most once

### Requirements

* Ruby
* [ZeroMQ](zeromq.org)

### Installation

```
git clone git@github.com:presidentbeef/melon.git
cd melon
gem build melon.gemspec
gem install manet_melon*.gem
```

### Example Applications

See README.md in the examples directory for information about running the code examples.

### Documentation

See [here](https://escholarship.org/uc/item/8md1h50q#page-82) for more details about MELON.
