DELIMITER //

//
SET sql_notes = 0; //
SET sql_warnings = 0; //
DROP PROCEDURE IF EXISTS DB_UPDATE; //
CREATE TABLE IF NOT EXISTS DB_VERSION (
	  version varchar(100) not null,
    feature varchar(100) not null,
    description varchar(300) not null,
    date datetime not null,
    primary key (version, feature)
); //
SET sql_warnings = 1; //
SET sql_notes = 1;

//
CREATE PROCEDURE DB_UPDATE(pversion varchar(100), pfeature varchar(100), pdescription varchar(300), poperation int)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
	DML_ROLLBACK_ORIGINAL_STATE:
		BEGIN
			ROLLBACK;
		END;
	
    DDL_ROLLBACK_ORIGINAL_STATE:
		BEGIN
        END;
        
		SHOW ERRORS;
    END;
    
DDL_BLOCK:
	BEGIN
    END;
    
DML_TRANSACTIONAL_BLOCK:
	BEGIN
		START TRANSACTION;

        IF poperation = 1 THEN
			INSERT INTO DB_VERSION (VERSION, FEATURE, DESCRIPTION, DATE)
			VALUES (pversion, pfeature, pdescription, sysdate());
		ELSEIF poperation = 2 THEN
			DELETE FROM DB_VERSION WHERE VERSION = pversion AND FEATURE = pfeature;
            
            IF ROW_COUNT() <> 1 THEN
				SIGNAL SQLSTATE '99999' SET MESSAGE_TEXT = 'failure on uninstalling script: could not found script version and feature';
            END IF;
		ELSE
			SIGNAL SQLSTATE '99999' SET MESSAGE_TEXT = 'operation must be 1 (install) or 2 (uninstall)';
        END IF;
			
        COMMIT;
    END;
END //

/* Set version, feature and description. All must be not null. */
/* Operation (last param): 1 - install, 2 - uninstall */
CALL DB_UPDATE('1.0.3', '14', 'Test #1', 2);

//
DROP PROCEDURE DB_UPDATE;
