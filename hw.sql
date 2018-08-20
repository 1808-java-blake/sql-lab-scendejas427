-- Part I – Working with an existing database

-- Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SET SCHEMA 'chinook';

SELECT * FROM employee;
-- Task – Select all records from the Employee table where last name is King.

SELECT * FROM employee
	WHERE lastname='King';

-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee
	WHERE firstname='Andre' AND reportsto=null;

-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.

SELECT * FROM album
	ORDER BY title DESC;

-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer
	ORDER BY city;
-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
INSERT INTO genre (genreid,name) VALUES (1111,'this'),(1234,'that');
-- Task – Insert two new records into Employee table
INSERT INTO employee (employeeid,firstname,lastname) VALUES (123,'f','d'),(213,'w','d');

-- Task – Insert two new records into Customer table
INSERT INTO customer (customerid,firstname,lastname,email) VALUES (123,'f','d','@'),(213,'w','d','@');

-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer 
	SET firstname='Robert', lastname='Walter'
	WHERE firstname='Aaron' AND lastname='Mitchell';
-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist 
	SET name='CCR'
	WHERE name='Creedence Clearwater Revival';
-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
SELECT * FROM invoice
	WHERE billingaddress LIKE 'T%';

-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
SELECT * FROM invoice
	WHERE total BETWEEN 15 and 50;
-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM employee
	WHERE hiredate BETWEEN '2003-6-01 00:00:00' and '2004-3-01 00:00:00';
-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE FROM invoiceline
	WHERE invoiceid IN (SELECT invoiceid FROM invoice
WHERE customerid IN (SELECT customerid FROM customer
 	WHERE firstname='Robert' AND lastname= 'Walter'));

DELETE FROM invoice
WHERE customerid IN (SELECT customerid FROM customer
 	WHERE firstname='Robert' AND lastname= 'Walter');
	
DELETE FROM customer
 	WHERE firstname='Robert' AND lastname= 'Walter'; 
-- SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
CREATE OR REPLACE FUNCTION timeing()
RETURNS TIME AS $$
	BEGIN
	RETURN current_time;
	END;$$ LANGUAGE plpgsql;
-- Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION medialength(this VARCHAR(120))
RETURNS INTEGER AS $$
			BEGIN
			RETURN LENGTH(THIS);
			END;$$ LANGUAGE plpgsql;
-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
CREATE OR REPLACE FUNCTION avgtot()
RETURNS NUMERIC AS $$
			BEGIN
			RETURN AVG(total) FROM invoice;
			END;$$ LANGUAGE plpgsql;
-- Task – Create a function that returns the most expensive track
CREATE OR REPLACE FUNCTION expen()
RETURNS NUMERIC AS $$
			BEGIN
			RETURN MAX(unitprice), name FROM track;
			END;$$ LANGUAGE plpgsql;
-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION invline()
RETURNS NUMERIC AS $$
			BEGIN
			RETURN AVG(unitprice) FROM invoiceline;
			END;$$ LANGUAGE plpgsql;
-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
  CREATE OR REPLACE FUNCTION employ()
RETURNS refcursor as $$
DECLARE 
    curs refcursor;
BEGIN
    OPEN curs for SELECT * FROM employee WHERE birthdate >= '1968-01-01 00:00:00';
    RETURN curs;
END;
$$ LANGUAGE plpgsql;	
-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
 
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE FUNCTION employn()
RETURNS refcursor as $$
DECLARE 
    curs refcursor;
BEGIN
    OPEN curs for SELECT firstname, lastname FROM employee;
    RETURN curs;
END;
$$ LANGUAGE plpgsql;
-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE FUNCTION employup(i INTEGER)
RETURNS INTEGER as $$
BEGIN
    UPDATE employee SET firstname='first',lastname='last',address='here'
	WHERE employeeid=i;
    RETURN i;
END;
$$ LANGUAGE plpgsql;
-- Task – Create a stored procedure that returns the managers of an employee.
 SET SCHEMA 'chinook';

CREATE OR REPLACE FUNCTION employlookup(i INTEGER)
RETURNS INTEGER as $$
BEGIN

    RETURN MAX (reportsto) FROM employee WHERE employeeid=i;
END;
$$ LANGUAGE plpgsql;


-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION employn()
RETURNS refcursor as $$
DECLARE 
    curs refcursor;
BEGIN
    OPEN curs for SELECT firstname, lastname FROM employee;
    RETURN curs;
END;
$$ LANGUAGE plpgsql;
-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
						
CREATE OR REPLACE FUNCTION clearit(i INTEGER)
RETURNS INTEGER as $$
BEGIN
    DELETE FROM invoiceline
	WHERE invoiceid IN (SELECT invoiceid FROM invoice
WHERE invoiceid=i);

DELETE FROM invoice
WHERE invoiceid=i;
RETURN i;
END;
$$ LANGUAGE plpgsql;
-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
CREATE OR REPLACE FUNCTION clean()
RETURNS INTEGER as $$
BEGIN

INSERT INTO customer (customerid,firstname,lastname,email) VALUES (2928,'k','i','@');
RETURN 1;
END;
$$ LANGUAGE plpgsql;
-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.

-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table

-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.

-- 6.2 INSTEAD OF
-- Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.

-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT invoice.invoiceid, customer.firstname, customer.lastname
FROM invoice
INNER JOIN customer ON invoice.customerid=customer.customerid;
-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.

SELECT invoice.invoiceid, customer.firstname, customer.lastname, customer.customerid, invoice.total
FROM invoice
FULL JOIN customer ON invoice.customerid=customer.customerid;
-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
SELECT artist.name, album.title
FROM artist
RIGHT JOIN album ON album.artistid=artist.artistid;
-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT *
FROM artist
CROSS JOIN album 
ORDER BY artist.name ASC;
-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT * FROM employee x INNER JOIN employee y ON (x.reportsto=y.employeeid);






