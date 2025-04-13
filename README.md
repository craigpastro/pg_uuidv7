# pg_uuidv7

This is an experimental Postgres extension to generate v7 UUIDs. Created with
[pgrx](https://github.com/tcdi/pgrx), it is a thin wrapper around the Rust
[uuid](https://docs.rs/uuid/latest/uuid/) crate.

## Usage

```
postgres=# CREATE EXTENSION pg_uuidv7;
CREATE EXTENSION

postgres=# SELECT uuid_generate_v7();
           uuid_generate_v7           
--------------------------------------
 018c5732-17b3-7451-b61a-223e7ee65241
(1 row)

postgres=# SELECT uuid_v7_to_timestamptz('018c5732-17b3-7451-b61a-223e7ee65241');
   uuid_v7_to_timestamptz   
----------------------------
 2023-12-10 20:45:49.875-08
(1 row)
```

## Docker

You can spin up a Postgres container with the `pg_uuidv7` extension installed
with `docker compose up -d`. Once the DB is up, you can connect to it using the
following connection string:

```
postgres://postgres:password@localhost:28801/postgres
```

## Installation

Requires [pgrx](https://github.com/pgcentralfoundation/pgrx). If you have `pgrx` installed then

```
cargo pgrx run pg17
```

should drop you into a psql prompt:

```
psql (17.4)
Type "help" for help.

pg_uuidv7=# CREATE EXTENSION pg_uuidv7;
CREATE EXTENSION
```

## Benchmark

Benchmarks were run on my 2023 Apple MacBook Pro with an M2 Pro chip and 16GB of
memory.

The benchmark I ran was

```console
$ pgbench -c 8 -j 8 -t 200000 -f ${TEST}.sql
```

which I borrowed from
[fboulnois/pg_uuidv7](https://github.com/fboulnois/pg_uuidv7/blob/main/BENCHMARKS.md).

From the results below this extension is faster than the native
`gen_random_uuid()` function.

```
-- SELECT gen_random_uuid();
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 8
maximum number of tries: 1
number of transactions per client: 200000
number of transactions actually processed: 1600000/1600000
number of failed transactions: 0 (0.000%)
latency average = 0.103 ms
initial connection time = 11.973 ms
tps = 77810.710080 (without initial connection time)
```

```
-- SELECT uuid_generate_v7();
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 8
maximum number of tries: 1
number of transactions per client: 200000
number of transactions actually processed: 1600000/1600000
number of failed transactions: 0 (0.000%)
latency average = 0.088 ms
initial connection time = 11.978 ms
tps = 90862.885067 (without initial connection time)
```

## See also

- [fboulnois/pg_uuidv7](https://github.com/fboulnois/pg_uuidv7)
