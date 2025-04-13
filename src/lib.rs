use error::MyError;
use pgrx::prelude::*;
use std::time::Duration;

::pgrx::pg_module_magic!();

pub mod error;

#[pg_extern]
fn uuid_generate_v7() -> pgrx::Uuid {
    let u = uuid::Uuid::now_v7();
    pgrx::Uuid::from_bytes(u.into_bytes())
}

#[pg_extern]
fn uuid_v7_to_timestamptz(u: pgrx::Uuid) -> Result<pgrx::datum::TimestampWithTimeZone, MyError> {
    uuid::Uuid::from_slice(u.as_bytes())?
        .get_timestamp()
        .ok_or(MyError::TimestampExtractionError)
        .map(|ts| ts.to_unix())
        .map(|(secs, nanos)| Duration::new(secs, nanos).as_secs_f64())
        .map(|fsecs| pgrx::datum::datetime_support::to_timestamp(fsecs))
}

#[cfg(any(test, feature = "pg_test"))]
#[pg_schema]
mod tests {
    use super::*;

    #[pg_test]
    fn test_uuid_generate_v7() {
        let g = uuid_generate_v7();
        let u = uuid::Uuid::from_slice(g.as_bytes()).unwrap();
        assert_eq!(7, u.get_version_num());
    }

    #[pg_test]
    fn test_uuid_v7_to_timestamptz() {
        uuid_v7_to_timestamptz(uuid_generate_v7()).unwrap();
    }

    #[pg_test]
    fn test_error_uuid_v7_to_timestamptz() {
        let g = uuid::Uuid::new_v4();
        let u = pgrx::Uuid::from_slice(g.as_bytes()).unwrap();
        let err = uuid_v7_to_timestamptz(u).unwrap_err();
        assert_eq!(err, error::MyError::TimestampExtractionError)
    }
}

/// This module is required by `cargo pgrx test` invocations.
/// It must be visible at the root of your extension crate.
#[cfg(test)]
pub mod pg_test {
    pub fn setup(_options: Vec<&str>) {
        // perform one-off initialization when the pg_test framework starts
    }

    pub fn postgresql_conf_options() -> Vec<&'static str> {
        // return any postgresql.conf settings that are required for your tests
        vec![]
    }
}
