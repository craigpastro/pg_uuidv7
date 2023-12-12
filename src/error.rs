use thiserror::Error;

#[derive(Debug, PartialEq, Error)]
pub enum MyError {
    #[error("uuid error: {0}")]
    UuidError(#[from] uuid::Error),

    #[error("error extracting timestamp from uuid")]
    TimestampExtractionError,
}
