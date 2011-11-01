
CREATE TABLE HarvestHistory
  (
    id             int not null,
    harvestDate    varchar(30),
        harvesterUuid  varchar(250),
        harvesterName  varchar(128),
        harvesterType  varchar(128),
    deleted        char(1) default 'n' not null,
    info           CLOB(1G),
    params         CLOB(1G),

    primary key(id)

  );

CREATE INDEX HarvestHistoryNDX1 ON HarvestHistory(harvestDate);
