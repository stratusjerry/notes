Sqlite Notes
===

## Potential speedups
Change journal mode: Default is `DELETE` which creates a rollback journal; can be altered via `PRAGMA` to `WAL` (Write-Ahead Log) which is generally significantly faster; or set to `OFF` if no log is needed (testing)

## Commands

- `VACUUM` : copy database contents into a temporary database file and overwrite the original, useful when reclaiming deleted data
- `ANALYZE` : gets statistics about tables and indices and stores in internal database tables. Useful in generating row count, correlation between indexed columns, etc
