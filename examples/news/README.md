### News Server/Reader

This is a simple news server and reader example.

In one terminal, run

```
ruby news_server.rb
```

In another terminal (or machine), run

```
ruby news_reader ADDRESS PORT TOPIC
```

where `ADDRESS` is the address of the news server, the PORT is the port of the news server, and TOPIC is the topic to read.

For example:

```
ruby news_reader localhost 1823 Sports
```
