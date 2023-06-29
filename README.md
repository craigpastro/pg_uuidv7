# pg_uuidv7

A Postgres extension to generate v7 UUIDs created with
[pgrx](https://github.com/tcdi/pgrx). This is simply a thin wrapper around the
Rust [uuid](https://docs.rs/uuid/latest/uuid/) crate.

## Usage

```
postgres=# create extension pg_uuidv7;
CREATE EXTENSION
postgres=# select uuid_generate_v7();
           uuid_generate_v7           
--------------------------------------
 018903c5-8ddb-7275-9d99-0d77e10821a0
(1 row)
```

## Docker

You can spin up a Postgres container with the `pg_uuidv7` extension installed
with

```
docker compose up -d
```

You can connect to the database with
`postgres:://postgres:password@localhost:28801/postgres`.

## Installation

Requires [pgrx](https://github.com/tcdi/pgrx). If you have `pgrx` installed then

```
cargo pgrx run
```

will drop you into a psql prompt

```
psql (15.3)
Type "help" for help.

pg_uuidv7=# create extension pg_uuidv7;
CREATE EXTENSION
pg_uuidv7=# select uuid_generate_v7();
           uuid_generate_v7           
--------------------------------------
 01890414-ce5e-7de1-bafe-3dfc8338fb1c
(1 row)
```

## Benchmark

Benchmarks were run on my 2023 Apple MacBook Pro with an M2 Pro chip and 16GB of
memory.

The benchmark I ran was

```
$ pgbench --client=8 --jobs=8 --transactions=200000 --file=${TEST}.sql
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

- [pg_uuid](https://github.com/fboulnois/pg_uuidv7)
