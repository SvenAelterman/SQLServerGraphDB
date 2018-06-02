CREATE DATABASE PizzaGraphSample;
GO

USE PizzaGraphSample
GO

/*
	RESET
*/

DROP TABLE IF EXISTS relCoworkers;
DROP TABLE IF EXISTS relToppingLikes;
DROP TABLE IF EXISTS relToppingDislikes;
DROP TABLE IF EXISTS Toppings;
DROP TABLE IF EXISTS People;

CREATE TABLE Toppings
(
	ToppingId INT IDENTITY(1,1) NOT NULL,
	Topping VARCHAR(20) NOT NULL,
	CONSTRAINT PK_Toppings PRIMARY KEY CLUSTERED (ToppingId) 
);

CREATE TABLE People
(
	PersonId INT IDENTITY(100, 1) NOT NULL,
	FirstName VARCHAR(20) NOT NULL,
	CONSTRAINT PK_People PRIMARY KEY CLUSTERED (PersonId)
);

CREATE TABLE relCoworkers
(
	PersonId INT NOT NULL,
	CoworkerId INT NOT NULL,
	CONSTRAINT PK_relCoworkers PRIMARY KEY CLUSTERED (PersonId, CoworkerId),
	CONSTRAINT FK_relCoworkers_PersonId FOREIGN KEY (PersonId) REFERENCES People (PersonId),
	CONSTRAINT FK_relCoworkers_CoworkerId FOREIGN KEY (CoworkerId) REFERENCES People (PersonId)
);

CREATE TABLE relToppingLikes
(
	PersonId INT NOT NULL,
	ToppingId INT NOT NULL,
	CONSTRAINT PK_relToppingLikes PRIMARY KEY CLUSTERED (PersonId, ToppingId),
	CONSTRAINT FK_relToppingLikes_People FOREIGN KEY (PersonId) REFERENCES People (PersonId),
	CONSTRAINT FK_relToppingLikes_Toppings FOREIGN KEY (ToppingId) REFERENCES Toppings (ToppingId)
);

CREATE TABLE relToppingDislikes
(
	PersonId INT NOT NULL,
	ToppingId INT NOT NULL
	CONSTRAINT PK_relToppingDislikes PRIMARY KEY CLUSTERED (PersonId, ToppingId),
	CONSTRAINT FK_relToppingDislikes_People FOREIGN KEY (PersonId) REFERENCES People (PersonId),
	CONSTRAINT FK_relToppingDislikes_Toppings FOREIGN KEY (ToppingId) REFERENCES Toppings (ToppingId)
);

INSERT INTO People
VALUES ('Sven'), ('Monica'), ('Phyllis'), ('Joann');

INSERT INTO Toppings
VALUES ('Pepperoni'), ('Mushrooms'), ('Pepper'), ('Sausage');

SELECT * FROM People;

INSERT INTO relCoworkers
VALUES (100, 101), (100, 102), (100, 103), (101, 102), (101, 103), (102, 103);

INSERT INTO relToppingLikes
VALUES (100, 1), (100, 2), (100, 3);
INSERT INTO relToppingLikes
VALUES (101, 1), (101, 2), (101, 4);
INSERT INTO relToppingLikes
VALUES (102, 2), (102, 3);
INSERT INTO relToppingLikes
VALUES (103, 2);

INSERT INTO relToppingDislikes
VALUES (102, 4);

DECLARE @MyName VARCHAR(4) = 'Sven';

/*
	Does not take my own preferences into account...
*/
SELECT DISTINCT Toppings.topping
FROM dbo.toppings AS Toppings
WHERE Toppings.ToppingId IN
(
	SELECT Likes.toppingID
	FROM dbo.relToppingLikes AS Likes
	WHERE Likes.PersonId IN
	(
		SELECT Coworkers.coworkerID
		FROM dbo.relCoworkers AS Coworkers
		WHERE Coworkers.personID IN
		(
			SELECT Person.PersonId
			FROM dbo.people AS Person
			WHERE Person.firstName = @MyName
		)
	)
)
/* Don't include any dislikes */
AND Toppings.ToppingId NOT IN
(
	SELECT DisLikes.toppingID
	FROM dbo.relToppingDisLikes AS DisLikes
	WHERE DisLikes.PersonId IN
	(
		SELECT Coworkers.coworkerID
		FROM dbo.relCoworkers AS Coworkers
		WHERE Coworkers.personID IN
		(
			SELECT Person.PersonId
			FROM dbo.people AS Person
			WHERE Person.firstName = @MyName
		)
	)
);

WITH Coworkers (CoworkerId) AS
(
	SELECT Coworkers.CoworkerID
	FROM dbo.relCoworkers AS Coworkers
	WHERE Coworkers.PersonId IN
	(
		SELECT Person.PersonId
		FROM dbo.People AS Person
		WHERE Person.FirstName = @MyName
	)
)
SELECT DISTINCT Toppings.Topping
FROM dbo.Toppings
WHERE Toppings.ToppingId IN
(
	SELECT Likes.toppingID
	FROM dbo.relToppingLikes AS Likes
	WHERE Likes.PersonId IN
	(SELECT CoworkerId FROM Coworkers)
)
AND Toppings.ToppingId NOT IN
(
SELECT Likes.toppingID
	FROM dbo.relToppingDislikes AS Likes
	WHERE Likes.PersonId IN
	(SELECT CoworkerId FROM Coworkers)
);

/*------------------------------------------------------------------------------
	GRAPH SOLUTION
------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS eLikes;
DROP TABLE IF EXISTS eDislikes;
DROP TABLE IF EXISTS eWorksWith;
DROP TABLE IF EXISTS gPeople;
DROP TABLE IF EXISTS gToppings;

CREATE TABLE gPeople
(
	FirstName VARCHAR(20) NOT NULL
) AS NODE;

CREATE TABLE gToppings
(
	ToppingId INT IDENTITY(1, 1) NOT NULL,
	Topping VARCHAR(20) NOT NULL
) AS NODE;

CREATE TABLE eWorksWith AS EDGE;

CREATE TABLE eLikes AS EDGE;

CREATE TABLE eDislikes AS EDGE;

INSERT INTO gPeople
VALUES ('Sven'), ('Monica'), ('Phyllis'), ('Joann');
INSERT INTO gToppings
VALUES ('Pepperoni'), ('Mushrooms'), ('Pepper'), ('Sausage');

INSERT INTO eWorksWith
VALUES (
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Sven'),
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Monica'));
INSERT INTO eWorksWith
VALUES (
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Sven'),
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Phyllis'));
INSERT INTO eWorksWith
VALUES (
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Sven'),
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Joann'));
INSERT INTO eWorksWith
VALUES (
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Monica'),
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Joann'));
INSERT INTO eWorksWith
VALUES (
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Monica'),
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Phyllis'));
INSERT INTO eWorksWith
VALUES (
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Phyllis'),
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Joann'));

INSERT INTO eLikes
VALUES (
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Sven'),
	(SELECT $node_id FROM gToppings WHERE Topping = 'Pepperoni')
	);
INSERT INTO eLikes
VALUES (
	(SELECT $node_id FROM gPeople WHERE FirstName = 'Monica'),
	(SELECT $node_id FROM gToppings WHERE Topping = 'Pepperoni')
	);

SELECT Topping, FirstName
FROM gPeople, gToppings, eLikes
WHERE MATCH(gPeople-(eLikes)->gToppings);

SELECT P.FirstName, C.FirstName
FROM gPeople P, gPeople C, eWorksWith
WHERE MATCH(P-(eWorksWith)->C);

SELECT P.FirstName, C.FirstName, Topping
FROM gPeople P, gPeople C, eWorksWith, eLikes, gToppings
WHERE MATCH(P-(eWorksWith)->C-(eLikes)->gToppings);

DECLARE @MyName VARCHAR(4) = 'Sven';
SELECT DISTINCT Topping.Topping
FROM gPeople AS Person, gPeople AS Coworker
	, eWorksWith, eLikes, gToppings AS Topping
WHERE Person.FirstName = @MyName AND
	MATCH(Person-(eWorkswith)->Coworker-(eLikes)->Topping)
	AND Topping.ToppingId NOT IN
	(
		SELECT DISTINCT Topping.ToppingId
		FROM gPeople AS Coworker, eWorkswith
			, eDisLikes, gToppings AS Topping
		WHERE MATCH(Person-(eWorkswith)->Coworker-(eDisLikes)->Topping)
	)
;