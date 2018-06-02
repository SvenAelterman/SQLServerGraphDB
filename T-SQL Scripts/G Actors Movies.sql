-- VS Enterprise 3 sub - db2017.database.windows.net
USE GraphSample;
GO

/*
	CLEANUP
*/
DROP TABLE IF EXISTS acts_in;
DROP TABLE IF EXISTS is_related_to;
DROP TABLE IF EXISTS Actors;
DROP TABLE IF EXISTS Movies;
DROP TABLE IF EXISTS Episodes;
DROP TABLE IF EXISTS Series;
DROP TABLE IF EXISTS sequel_to;
GO

/*******************************************************************************
	ACTORS and MOVIES nodes
*******************************************************************************/
CREATE TABLE Actors (
	ActorID INT PRIMARY KEY IDENTITY (1000, 1) NOT NULL, 
	FirstName NVARCHAR(50) NOT NULL, 
	LastName NVARCHAR(50) NOT NULL
) AS NODE;

CREATE TABLE Movies (
	MovieId INT PRIMARY KEY IDENTITY (1, 1) NOT NULL,
	MovieTitle NVARCHAR(100) NOT NULL,
	SortableMovieTitle NVARCHAR(102) NOT NULL,
	ReleaseYear SMALLINT NOT NULL
) AS NODE;

INSERT INTO Actors VALUES ('Michelle', 'Pfeiffer');
INSERT INTO Actors VALUES ('Dustin', 'Hoffman');
INSERT INTO Actors VALUES ('Robert', 'De Niro');
INSERT INTO Actors VALUES ('Raphael', 'De Niro');
INSERT INTO Actors VALUES ('Sean', 'Connery');
INSERT INTO Actors VALUES ('Daniel', 'Craig');
INSERT INTO Actors VALUES ('John', 'Malkovich');
INSERT INTO Actors VALUES ('Mike', 'Myers');

INSERT INTO Movies VALUES ('The Wizard of Lies', 'Wizard of Lies, The', 2017);
INSERT INTO Movies VALUES ('Being John Malkovich', 'Being John Malkovich', 1999);
INSERT INTO Movies VALUES ('Coolio Feat. L.V.: Gangsta''s Paradise', 'Coolio Feat. L.V.: Gangsta''s Paradise', 1995);
INSERT INTO Movies VALUES ('Little Fockers', 'Little Fockers', 2010);
INSERT INTO Movies VALUES ('Love Streams', 'Love Streams', 1984);
INSERT INTO Movies VALUES ('Casino Royale', 'Casino Royale', 2006);
INSERT INTO Movies VALUES ('Dr. No', 'Dr. No', 1962);
INSERT INTO Movies VALUES ('Austin Powers in Goldmember', 'Austin Powers in GoldMember', 2002);
INSERT INTO Movies VALUES ('Austin Powers: The Spy Who Shagged Me', 'Austin Powers: The Spy Who Shagged Me', 1999);
INSERT INTO Movies VALUES ('Goldfinger', 'Goldfinger', 1964);

SELECT * FROM Actors;
SELECT * FROM Movies;

/*******************************************************************************
	Acts in edge: character name, leading role, awarded
*******************************************************************************/

CREATE TABLE acts_in (
	CharacterFirstName NVARCHAR(50) NULL,
	CharacterLastName NVARCHAR(50) NULL,
	IsLeadingRole BIT NOT NULL DEFAULT 0,
	WasAwarded BIT NOT NULL DEFAULT 0
) AS EDGE;

/*ALTER TABLE acts_in 
	ADD CONSTRAINT FK_acts_in FOREIGN KEY ($from_id) REFERENCES Actors ($node_id);*/

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1000), -- Pfeiffer
	(SELECT $node_id FROM Movies WHERE MovieId = 1), -- Wizard of Lies
	'Ruth', 'Madoff', 1, 0);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1002), -- De Niro
	(SELECT $node_id FROM Movies WHERE MovieId = 1), -- Wizard of Lies
	'Bernie', 'Madoff', 1, 0);	

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1000), -- Pfeiffer
	(SELECT $node_id FROM Movies WHERE MovieId = 3), -- Coolio
	NULL, NULL, 0, 0);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1002), -- De Niro
	(SELECT $node_id FROM Movies WHERE MovieId = 4), -- Little Fockers
	'Jack', 'Byrnes', 1, 0);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1004), -- Connery
	(SELECT $node_id FROM Movies WHERE MovieId = 7), -- Dr. No
	'James', 'Bond', 1, 0);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1005), -- Craig
	(SELECT $node_id FROM Movies WHERE MovieId = 6), -- Casino Royale
	'James', 'Bond', 1, 0);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1003), -- Raphael De Niro
	(SELECT $node_id FROM Movies WHERE MovieId = 5), -- Love Streams
	'Billy', NULL, 0, 0);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1006), -- John Malkovich
	(SELECT $node_id FROM Movies WHERE MovieId = 2), -- Being John Malkovich
	'John', 'Malkovich', 0, 0);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1001), -- Dustin Hoffman
	(SELECT $node_id FROM Movies WHERE MovieId = 2), -- Being John Malkovich
	'Willy', 'Loman', 0, 0);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1007), -- Mike Myers
	(SELECT $node_id FROM Movies WHERE MovieId = 8), -- Goldmember
	'Austin', 'Powers', 1, 1);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1007), -- Mike Myers
	(SELECT $node_id FROM Movies WHERE MovieId = 8), -- Goldmember
	'Dr.', 'Evil', 1, 1);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1007), -- Mike Myers
	(SELECT $node_id FROM Movies WHERE MovieId = 9), -- Spy Who Shagged Me
	'Austin', 'Powers', 1, 1);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1007), -- Mike Myers
	(SELECT $node_id FROM Movies WHERE MovieId = 9), -- Spy Who Shagged Me
	'Dr.', 'Evil', 1, 1);

INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1004), -- Mike Myers
	(SELECT $node_id FROM Movies WHERE MovieId = 10), -- Spy Who Shagged Me
	'James', 'Bond', 1, 0);

SELECT * FROM acts_in;

/*******************************************************************************
	GRAPH QUERIES
*******************************************************************************/

SELECT M.MovieId, MovieTitle, FirstName, LastName
FROM Actors A, Movies M, acts_in
WHERE MATCH(A-(acts_in)->M)
ORDER BY SortableMovieTitle;

--SELECT * FROM Actors A INNER JOIN acts_in ai ON ai.$from_id = a.$node_id;

-- In which movie(s) did Pfeiffer have a role?
SELECT M.MovieTitle, ReleaseYear
-- "Old-style" JOIN...
FROM Actors A, Movies M, acts_in
WHERE MATCH (A-(acts_in)->M)
	AND A.LastName = 'Pfeiffer'
ORDER BY SortableMovieTitle;

-- In which movie(s) did Pfeiffer have a leading role?
SELECT M.MovieTitle, ReleaseYear
FROM Actors A, Movies M, acts_in
WHERE MATCH (A-(acts_in)->M)
	AND A.LastName = 'Pfeiffer'
	OR acts_in.IsLeadingRole = 1
ORDER BY SortableMovieTitle;

-- Who acted in Wizard of Lies?
SELECT A.*
FROM Actors A, Movies M, acts_in
WHERE MATCH(A-(acts_in)->M)
	AND M.MovieTitle = 'The Wizard of Lies';
-- Alternative (same query plan)
SELECT A.*
FROM Actors A, Movies M, acts_in
WHERE MATCH(M<-(acts_in)-A)
	AND M.MovieTitle = 'The Wizard of Lies';

-- Who played James Bond?
SELECT A.FirstName, A.LastName
FROM Actors A, Movies M, acts_in
WHERE MATCH (A-(acts_in)->M)
	AND acts_in.CharacterFirstName = 'James'
	AND acts_in.CharacterLastName = 'Bond'
GROUP BY A.FirstName, A.LastName;

-- Which movies did Pfeiffer act in where De Niro was also an actor?
SELECT M.MovieTitle
FROM Actors A1, Movies M, acts_in ai1, acts_in ai2, Actors A2
WHERE MATCH(A1-(ai1)->M<-(ai2)-A2) 
	AND A1.FirstName = 'Robert' AND A1.LastName = 'De Niro'
	AND A2.LastName = 'Pfeiffer';

-- Actors who played the same role multiple times
SELECT CharacterFirstName, CharacterLastName, FirstName, LastName
FROM Actors A, Movies M, acts_in
WHERE MATCH(A-(acts_in)->M)
GROUP BY CharacterFirstName, CharacterLastName, FirstName, LastName
HAVING COUNT(*) > 1;

/*******************************************************************************
	Relationships edge
*******************************************************************************/

CREATE TABLE is_related_to AS EDGE;

ALTER TABLE is_related_to
	ADD Relationship NVARCHAR(50) NOT NULL;

INSERT INTO is_related_to VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1002), -- Robert De Niro
	(SELECT $node_id FROM Actors WHERE ActorId = 1003), -- Raphael De Niro
	'Father');

SELECT * FROM is_related_to;

-- Who is related to who?
SELECT A1.FirstName + ' ' + A1.LastName + ' is the ' + Relationship + 
	' of ' + A2.FirstName + ' ' + A2.LastName + '.' 'Relationship'
FROM Actors A1, is_related_to, Actors A2
WHERE MATCH(A1-(is_related_to)->A2);

INSERT INTO is_related_to VALUES (
	(SELECT $node_id FROM Actors WHERE ActorId = 1003), -- Raphael De Niro
	(SELECT $node_id FROM Actors WHERE ActorId = 1002), -- Robert De Niro
	'Son');
	
-- Who is related to who?
SELECT $edge_id, A1.FirstName + ' ' + A1.LastName + ' is the ' + Relationship + 
	' of ' + A2.FirstName + ' ' + A2.LastName + '.' 'Relationship'
FROM Actors A1, is_related_to, Actors A2
WHERE MATCH(A1-(is_related_to)->A2);

-- UPDATE edge table internal column
UPDATE is_related_to
	SET $from_id = (SELECT $node_id FROM Actors 
	WHERE LastName = 'Connery')
	WHERE $edge_id = '{"type":"edge","schema":"dbo","table":"is_related_to","id":1}';

	UPDATE is_related_to
	SET Relationship = 'brother'
	WHERE $edge_id = '{"type":"edge","schema":"dbo","table":"is_related_to","id":1}';

/*******************************************************************************
	Television series
*******************************************************************************/

CREATE TABLE Series (
	SeriesId INT IDENTITY (1, 1) NOT NULL PRIMARY KEY CLUSTERED,
	SeriesTitle VARCHAR(100) NOT NULL
) AS NODE;

INSERT INTO Series VALUES ('Stitchers');
SELECT * FROM Series;

CREATE TABLE Episodes (
	SeriesId INT NOT NULL,
	EpisodeNumber VARCHAR(5) NOT NULL,

	CONSTRAINT PK_Episodes PRIMARY KEY CLUSTERED (SeriesId, EpisodeNumber),
	CONSTRAINT FK_Episodes_Series FOREIGN KEY (SeriesId) REFERENCES Series (SeriesId)
) AS NODE;

-- Add some more actors
INSERT INTO Actors VALUES ('Emma', 'Ishta');
INSERT INTO Actors VALUES ('J''aime', 'Spezzano');

-- Add series edge: Ishta is the start of the series
INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE LastName = 'Ishta'), 
	(SELECT $node_id FROM Series WHERE SeriesTitle = 'Stitchers'),
	'Kristen', 'Clark', 1, 0);

-- This could be solved better with polymorphism...
SELECT M.MovieId, MovieTitle, FirstName, LastName
FROM Actors A, Movies M, acts_in
WHERE MATCH(A-(acts_in)->M)
--ORDER BY SortableMovieTitle;
UNION ALL
SELECT S.SeriesId, S.SeriesTitle, FirstName, LastName
FROM Actors A, Series S, acts_in
WHERE MATCH(A-(acts_in)->S);

select id, title
from (select $node_id, seriesid, seriestitle from series union all select $node_id, movieid, movietitle from movies) S, 
	acts_in, actors a
where match(a-(acts_in)->S);

-- Add episode edge: Spezzano is a guest in one episode
INSERT INTO Episodes VALUES (1, '1-01');
SELECT * FROM Episodes;

-- Add episodes edge
INSERT INTO acts_in VALUES (
	(SELECT $node_id FROM Actors WHERE LastName = 'Spezzano'), 
	(SELECT $node_id FROM Episodes WHERE SeriesId = 1 AND EpisodeNumber = '1-01'),
	'Julie', 'Malarek', 0, 0);

SELECT S.SeriesId, S.SeriesTitle, E.EpisodeNumber, FirstName, LastName
FROM Series S
	INNER JOIN Episodes E ON E.SeriesId = S.SeriesId,
	acts_in, Actors A
WHERE MATCH(A-(acts_in)->E);

SELECT S.SeriesId, S.SeriesTitle, E.EpisodeNumber, FirstName, LastName
FROM Series S, Episodes E, acts_in, Actors A
WHERE MATCH(A-(acts_in)->E)
	AND E.SeriesId = S.SeriesId;

/*******************************************************************************
	Sequels
*******************************************************************************/

CREATE TABLE sequel_to AS EDGE;

INSERT INTO sequel_to VALUES (
	(SELECT $node_id FROM Movies WHERE MovieId = 8), -- Goldmember
	(SELECT $node_id FROM Movies WHERE MovieId = 9) -- Spy Who Shagged Me
);

INSERT INTO sequel_to VALUES (
	(SELECT $node_id FROM Movies WHERE MovieId = 10), -- Goldfinger
	(SELECT $node_id FROM Movies WHERE MovieId = 7) -- Dr. No
);

INSERT INTO sequel_to VALUES (
	(SELECT $node_id FROM Movies WHERE MovieId = 6), -- Casino Royale
	(SELECT $node_id FROM Movies WHERE MovieId = 10) -- Goldfinger
);

-- Trace sequels -- does it look funny spelled that way to you too?
SELECT S.MovieTitle 'Sequel Movie Title', S.ReleaseYear, M.MovieTitle, M.ReleaseYear
FROM Movies M, sequel_to, Movies S
WHERE MATCH (S-(sequel_to)->M)
ORDER BY M.ReleaseYear;

-- Sequel of a sequel
-- This could be solved better with transitive closures...
SELECT S2.MovieTitle, S2.ReleaseYear, M.MovieTitle, M.ReleaseYear, S.MovieTitle, S.ReleaseYear
FROM Movies M, sequel_to t1, Movies S, Movies S2, sequel_to t2
WHERE MATCH (S-(t1)->M-(t2)->S2)
ORDER BY M.ReleaseYear;

