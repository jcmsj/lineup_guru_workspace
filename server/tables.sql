CREATE TABLE IF NOT EXISTS queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL UNIQUE,
    current INT NOT NULL,
    last_position INT NOT NULL,
    icon VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    multi_join_on boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS theme(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    seed VARCHAR(8) NOT NULL,
    brightness VARCHAR(16) NOT NULL,
    appBackground VARCHAR(8) NOT NULL,
    appBarBackground VARCHAR(8) NOT NULL,
    appBarForeground VARCHAR(8) NOT NULL,
    queueItemBackground VARCHAR(8) NOT NULL,
    queueItemForeground VARCHAR(8) NOT NULL
);
-- REPLACE INTO queue (
--     name, 
--     current, 
--     last_position, 
--     icon
-- ) VALUES(
--     "sample", 
--     0, 
--     5, 
--     "payments_outlined"
-- );
