--Dayton Abbott
--D326: Advanced Data Management
--Customer Rental History report

--Creating function to transform the TIMESTAMP format to DATE for summary table
--PART B1
CREATE OR REPLACE FUNCTION date_transform(date_time TIMESTAMP)
	RETURNS DATE
	LANGUAGE plpgsql
AS
$$
DECLARE rental_date DATE;
BEGIN 
	SELECT DATE(date_time) INTO rental_date;
	RETURN rental_date;
END;
$$;

--Creating function to transform the status from a bool to a VARCHAR descriptor
--PART B2
CREATE OR REPLACE FUNCTION status_transform(rental_date DATE)
	RETURNS VARCHAR(8)
	LANGUAGE plpgsql
AS
$$
DECLARE customer_status_desc VARCHAR(8);
BEGIN
	IF rental_date >= (CURRENT_DATE - INTERVAL '3 MONTH') 
		THEN customer_status_desc = 'Active'; 
		ELSE customer_status_desc = 'Inactive';
	END IF;
	RETURN customer_status_desc;
END;
$$;

--Creating the detailed report table
--PART C1
CREATE TABLE customer_rental_history (
	customer_id INT,
	rental_id INT PRIMARY KEY,
	date_time TIMESTAMP
);

--TEST SELECT PART C1_____________________________________________________________________
SELECT * 
FROM customer_rental_history;

--Creating the summary report table
--PART C2
CREATE TABLE customer_status (
	customer_id INT PRIMARY KEY,
	most_recent_purchase DATE,
	status VARCHAR(8),
	CONSTRAINT status_check CHECK (status IN ('Active', 'Inactive'))
);

--TEST SELECT PART C2_____________________________________________________________________
SELECT *
FROM customer_status;


--Populating the detailed table with all customer rentals
--PART D1
INSERT INTO customer_rental_history (customer_id, rental_id, date_time)
SELECT customer.customer_id, rental.rental_id, rental.rental_date
FROM customer
LEFT JOIN rental ON customer.customer_id = rental.customer_id
ORDER BY customer_id;

--TEST SELECT PART D1_____________________________________________________________________
SELECT *
FROM customer_rental_history;

--Populating the summary table with customer ID, most recent purchase date, and status
--PART D2
INSERT INTO customer_status (customer_id, most_recent_purchase, status)
SELECT CRH.customer_id, date_transform(MAX(CRH.date_time)) AS most_recent_purchase, 
	status_transform(date_transform(MAX(CRH.date_time))) AS status
FROM customer_rental_history AS CRH
INNER JOIN customer_rental_history ON CRH.customer_id = CRH.customer_id
GROUP BY CRH.customer_id
ORDER BY customer_id;

--TEST SELECT PART D2_____________________________________________________________________
SELECT *
FROM customer_status;

--Creating trigger function to update the summary table when data is added to the detailed table
--PART E
CREATE OR REPLACE FUNCTION status_trigger_function()
	RETURNS TRIGGER
	LANGUAGE plpgsql
AS $$
BEGIN
	IF TG_OP = 'UPDATE' OR NEW.date_time > (
		SELECT most_recent_purchase
		FROM customer_status
		WHERE customer_status.customer_id = NEW.customer_id)
	THEN
		UPDATE customer_status
		SET most_recent_purchase = date_transform(NEW.date_time)
		WHERE customer_status.customer_id = NEW.customer_id;
		UPDATE customer_status
		SET status = status_transform(most_recent_purchase)
		WHERE customer_status.customer_id = NEW.customer_id;
	END IF;
	IF TG_OP = 'DELETE'
	THEN
		UPDATE customer_status
		SET most_recent_purchase = (
			SELECT date_transform(MAX(date_time))
			FROM customer_rental_history
			WHERE customer_rental_history.customer_id = OLD.customer_id)
		WHERE customer_status.customer_id = OLD.customer_id;
		UPDATE customer_status
		SET status = status_transform(most_recent_purchase)
		WHERE customer_status.customer_id = OLD.customer_id;
	END IF;
RETURN NULL;
END;
$$;

--Creating TRIGGER binding for status_trigger_function
--PART E
CREATE OR REPLACE TRIGGER customer_status_trigger
	AFTER INSERT OR UPDATE OR DELETE ON customer_rental_history
	FOR EACH ROW
	EXECUTE FUNCTION status_trigger_function();
	
--TEST INSERT_______________________________________________________________________________
--PART E
INSERT INTO customer_rental_history
VALUES (2, 16050, '2023-12-29 22:30:30'),
		(5, 16051, '2024-2-13 22:30:30'),
		(100, 16052, '2024-2-15 22:30:30'),
		(150, 16053, '2024-2-09 22:30:30');
		
--TEST SELECT_______________________________________________________________________________
--PART E
Select *
FROM customer_status
WHERE status = 'Active';

--DELETE TEST VALUES________________________________________________________________________
--PART E

DELETE FROM customer_rental_history
WHERE date_time > '2020-01-01';
	
--inserting some recent rental purchases to demonstrate the functionality of status_transform function
--TEST INSERT ______________________________________________________________________________
--PART F
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES ('2023-12-19 16:30:30', 352, 52, '2023-12-22 16:30:30', 1),
		('2024-01-20 16:30:30', 313, 13, '2024-01-22 16:30:30', 1),
		('2023-12-13 16:30:30', 273, 27, '2024-01-22 16:30:30', 1),
		('2023-12-16 16:30:30', 863, 96, '2023-12-22 16:30:30', 1),
		('2023-02-19 16:30:30', 1243, 124, '2024-02-25 16:30:30', 1),
		('2023-12-19 16:30:30', 3158, 158, '2023-12-22 16:30:30', 1),
		('2024-01-19 16:30:30', 3191, 191, '2024-01-15 16:30:30', 1),
		('2023-12-19 16:30:30', 2303, 230, '2023-12-22 16:30:30', 1),
		('2024-01-19 16:30:30', 2753, 275, '2023-01-22 16:30:30', 1),
		('2023-12-19 16:30:30', 3017, 302, '2023-12-22 16:30:30', 1),
		('2024-01-19 16:30:30', 3333, 333, '2024-01-27 16:30:30', 1),
		('2023-12-19 16:30:30', 3653, 365, '2023-12-22 16:30:30', 1),
		('2023-12-19 16:30:30', 3973, 397, '2023-12-22 16:30:30', 1),
		('2024-01-19 16:30:30', 4213, 421, '2024-01-21 16:30:30', 1),
		('2023-12-19 16:30:30', 4553, 455, '2023-12-22 16:30:30', 1),
		('2024-01-19 16:30:30', 4293, 479, '2024-01-12 16:30:30', 1),
		('2023-12-19 16:30:30', 3492, 492, '2023-12-22 16:30:30', 1),
		('2023-12-19 16:30:30', 512, 512, '2023-12-22 16:30:30', 1),
		('2024-02-21 16:30:30', 2518, 518, '2024-02-27 16:30:30', 1),
		('2023-12-19 16:30:30', 1520, 520, '2023-12-22 16:30:30', 1),
		('2024-02-21 16:30:30', 531, 531, '2024-02-25 16:30:30', 1),
		('2023-12-19 16:30:30', 542, 542, '2023-12-22 16:30:30', 1),
		('2023-12-19 16:30:30', 382, 1, '2023-12-22 16:30:30', 1),
		('2024-01-20 16:30:30', 313, 2, '2024-01-22 16:30:30', 1),
		('2023-12-13 16:30:30', 273, 3, '2024-01-22 16:30:30', 1),
		('2023-12-16 16:30:30', 863, 4, '2023-12-22 16:30:30', 1),
		('2023-12-19 16:30:30', 1243, 5, '2024-02-25 16:30:30', 1),
		('2023-12-19 16:30:30', 3158, 6, '2023-12-22 16:30:30', 1),
		('2024-01-19 16:30:30', 3191, 8, '2024-01-15 16:30:30', 1),
		('2023-12-19 16:30:30', 2303, 10, '2023-12-22 16:30:30', 1);

--Creating a PROCEDURE to clear and then refresh the detailed and summary tables 
--PART F
CREATE OR REPLACE PROCEDURE report_table_truncate_proc()
	LANGUAGE plpgsql
AS $$
BEGIN
	TRUNCATE TABLE customer_rental_history, customer_status;
	INSERT INTO customer_rental_history (customer_id, rental_id, date_time)
		SELECT customer.customer_id, rental.rental_id, rental.rental_date
		FROM customer
		LEFT JOIN rental ON customer.customer_id = rental.customer_id
		ORDER BY customer_id;
	INSERT INTO customer_status (customer_id, most_recent_purchase, status)
		SELECT CRH.customer_id, date_transform(MAX(CRH.date_time)) AS most_recent_purchase, 
			status_transform(date_transform(MAX(CRH.date_time))) AS status
		FROM customer_rental_history AS CRH
		INNER JOIN customer_rental_history ON CRH.customer_id = CRH.customer_id
		GROUP BY CRH.customer_id
		ORDER BY customer_id;
END;
$$;

--CALL PROCEDURE _________________________________________________________________

CALL report_table_truncate_proc();

--TEST SELECT ____________________________________________________________________

SELECT *
FROM customer_status
WHERE customer_id;

--REMOVE ALL STUDENT CREATED REPORT TABLES, FUNCTIONS, TRIGGERS, TEST DATA_______________________________
/*
DROP TRIGGER IF EXISTS report_table_truncate_trigger ON rental;
DROP TRIGGER IF EXISTS customer_status_trigger ON customer_rental_history;

DROP FUNCTION IF EXISTS date_transform, status_transform, report_table_truncate_function, status_trigger_function;

DROP TABLE IF EXISTS customer_status, customer_rental_history;

DELETE FROM rental
WHERE rental_date >= '2020-01-01';
*/