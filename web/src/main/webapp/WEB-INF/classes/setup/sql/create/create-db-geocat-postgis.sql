-- ======================================================================
-- === Extra SQL required for geocat service
-- ======================================================================

CREATE TABLE Formats
  (
    id          int,
    name        varchar(200),
    version     varchar(200),
    validated   varchar(1),
    primary key(id)
  );

-- ======================================================================

