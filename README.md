:warning::warning: Project still in a very experimental phase :warning::warning:

[![Build Status](https://travis-ci.org/iurifq/comredis.svg?branch=master)](https://travis-ci.org/iurifq/comredis)

# Comredis

Comredis is your comrade for Redis command generation in Elixir. It helps you generate correct commands with the right arity. You can then use your favorite client to push them to Redis.

It parses the [Redis commands documentation](https://github.com/antirez/redis-doc/blob/master/commands.json) and generates functions in compile-time. All functions are defined in the `Comredis` module.

## Examples

```elixir
Comredis.client_list
#=> ["CLIENT", "LIST"]

Comredis.get("k")
#=> ["GET", "k"]

Comredis.mget(["k1", "k2"])
#=> ["MGET", "k1", "k2"]

Comredis.set("k", "v")
#=> ["SET", "k", "v"]

# Using SET with expire time. It allows only the options the command accepts
Comredis.set("k", "v", ex: 10)
#=> ["SET", "k", "v", "EX", 10]
```

You also get nice documentation for each command directly from the Redis' documentation.

```
h Comredis.get
```

>                                        def get(key)

> Get the value of a key

> *Group:* string

> *Available since Redis version 1.0.0.*

> *Time complexity:* O(1)
