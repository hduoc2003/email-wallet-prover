use file_rotate::{
    compression::Compression,
    suffix::{AppendTimestamp, FileLimit},
    ContentLimit, FileRotate,
};
use lazy_static::lazy_static;
use slog::{o, Drain};
use slog_async;
use slog_json;
use slog_term;
use std::env;
use slog::Level;

use crate::strings::JSON_LOGGER_KEY;

lazy_static! {
    pub static ref LOG: slog::Logger = init_logger();
}

fn init_logger() -> slog::Logger {
    let directory = std::path::Path::new("logs");
    let log_path = directory.join("relayer.log");
    let file_rotate = FileRotate::new(
        log_path.clone(),
        AppendTimestamp::default(FileLimit::MaxFiles(1_000_000)),
        ContentLimit::Bytes(5_000_000),
        Compression::OnRotate(5),
        #[cfg(unix)]
        None,
    );
    let log_file_drain = slog_json::Json::default(file_rotate).fuse();

    // Check if LOGGER env var is set and true or True or TRUE, if not, set false
    let terminal_json_output = match env::var(JSON_LOGGER_KEY) {
        Ok(val) => val.eq_ignore_ascii_case("true"),
        Err(_) => false,
    };

    let log_terminal_decorator = slog_term::TermDecorator::new().build();
    let log_terminal_drain = slog_term::FullFormat::new(log_terminal_decorator)
        .build()
        .fuse();
    let log_terminal_json_drain = slog_json::Json::default(std::io::stdout()).fuse();

    let log_drain = if terminal_json_output {
        slog::Duplicate(log_terminal_json_drain, log_file_drain).fuse()
    } else {
        slog::Duplicate(log_terminal_drain, log_file_drain).fuse()
    };

    // Tạo một Filter cho mức độ log
    let level_filter = slog::LevelFilter::new(log_drain, Level::Info).fuse();

    let logger = slog::Logger::root(level_filter, o!("version" => env!("CARGO_PKG_VERSION")));
    logger
}
