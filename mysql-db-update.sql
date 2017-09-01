DELIMITER //

/*
 * About the comments in this file: after you do the reading and understood each part, you can
 * remove the comments. To say the truth, you are is ENCOURAGED to do it, specially considering
 * creating scripts is part of your routine.
 */

#Bootstrap - initial section always present in the top of file to avoid sucker mistakes
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

/*
 * Content - here you must put your script to make changes in the database.
 *
 * There are four sections, mapped as blocks of code(label: BEGIN ... END), that must be implemented.
 * 
 * DDL_BLOCK - structural changes. New tables, changes in any procedure or trigger, that is, DDL-class statements;
 * DML_TRANSACTIONAL_BLOCK - data. You can insert, update or delete data from database, that is, DML-class statements;
 *    Note that data manipulation is handled using an single transaction to guarantee atomicity.
 *    DDL-class statements with transactions are not supported in MySQL.
 *    DO NOT REMOVE THE START TRANSACTION AND COMMIT STATEMENTS.
 * 
 * The main two sections were describled above. There are others two sections, dedicated for error handling 
 * during the execution of script.
 * 
 * DML_ROLLBACK_ORIGINAL_STATE - rollbacks changes in the data.
 *    DO NOT REMOVE THE ROLLBACK statement at the end of the block;
 * 
 * DDL_ROLLBACK_ORIGINAL_STATE - rollbacks changes in structural changes;
 *
 * Tip: for error handling keep the algorithm more simple possible to avoid 
 *    pieces of the changes after the execution of error handling. 
 *    Keep in mind that the script must be atomic in both cases: installing, normal flow, and during
 *    error handling.
 *
 * Tip: if you want an rollback script, that is, an script that uninstall changes, you must create
 *    an separated script with option Uninstall (see in the end of this file, CALL DB_UPDATE ...).
 *    Note: this isn't related to error handling, otherwise, is just to uninstall an previous
 *    script that was executed successfully.
 */
//
CREATE PROCEDURE DB_UPDATE(pversion varchar(100), pfeature varchar(100), pdescription varchar(300), poperation int)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION #For rollback in case of failure
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
    
#Rock it sections, DDL, and DML statements in junction with the register of version
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

#Set version, feature and description. All must be not null
#Operation (last param): 1 - install, 2 - uninstall
CALL DB_UPDATE('1.0.3', '14', 'Test #1', 1);

//
#Cleanup - bye!
DROP PROCEDURE DB_UPDATE;
