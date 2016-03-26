:warning::warning: Project still in a very experimental phase :warning::warning:

# Comredis

Comredis is your comrade for Redis command generation in Elixir. It helps you generate correct commands with the right arity. You can then use your favorite client to push them to Redis.

It parses the [Redis commands documentation](https://github.com/antirez/redis-doc/blob/master/commands.json) and generates functions in compile-time. All functions are defined in the `Comredis` module.

## Examples

```elixir
Comredis.client_list
#=> ["CLIENT LIST"]

Comredis.get("key")
#=> ["GET", "key"]

Comredis.setnx("key", "value")
#=> ["SETNX", "key", "value"]
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
