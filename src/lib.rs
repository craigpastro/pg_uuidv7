use pgrx::prelude::*;

pgrx::pg_module_magic!();

#[pg_extern]
fn uuid_generate_v7() -> pgrx::Uuid {
    let u = uuid::Uuid::now_v7();
    pgrx::Uuid::from_bytes(u.into_bytes())
}

#[cfg(any(test, feature = "pg_test"))]
#[pg_schema]
mod tests {
    use super::*;

    #[pg_test]
    fn test_pguuidv7() {
        let g = uuid_generate_v7();
        let u = uuid::Uuid::from_slice(g.as_bytes()).unwrap();
        assert_eq!(7, u.get_version_num());
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
