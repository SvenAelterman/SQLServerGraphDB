-- VS Enterprise 3 sub - db2017.database.windows.net
USE GraphSample;
GO

/*
	CLEANUP
*/
DROP TABLE IF EXISTS MovieActors;
DROP TABLE IF EXISTS T_Actors;
DROP TABLE IF EXISTS T_Movies;
GO

/*
	START AGAIN
*/
CREATE TABLE T_Actors (
	ActorID INT PRIMARY KEY CLUSTERED IDENTITY (1000, 1) NOT NULL, 
	FirstName NVARCHAR(50) NOT NULL, 
	LastName NVARCHAR(50) NOT NULL	
);

CREATE TABLE T_Movies (
	MovieId INT PRIMARY KEY CLUSTERED IDENTITY (1, 1) NOT NULL,
	MovieTitle NVARCHAR(100) NOT NULL,
	SortableMovieTitle NVARCHAR(102) NOT NULL,
	ReleaseYear SMALLINT NOT NULL
);

INSERT INTO T_Actors VALUES ('Michelle', 'Pfeiffer');
INSERT INTO T_Actors VALUES ('Dustin', 'Hoffman');
INSERT INTO T_Actors VALUES ('Robert', 'De Niro');
INSERT INTO T_Actors VALUES ('Raphael', 'De Niro');
INSERT INTO T_Actors VALUES ('Sean', 'Connery');
INSERT INTO T_Actors VALUES ('Daniel', 'Craig');
INSERT INTO T_Actors VALUES ('John', 'Malkovich');
INSERT INTO T_Actors VALUES ('Mike', 'Myers');

INSERT INTO T_Movies VALUES ('The Wizard of Lies', 'Wizard of Lies, The', 2017);
INSERT INTO T_Movies VALUES ('Being John Malkovich', 'Being John Malkovich', 1999);
INSERT INTO T_Movies VALUES ('Coolio Feat. L.V.: Gangsta''s Paradise', 'Coolio Feat. L.V.: Gangsta''s Paradise', 1995);
INSERT INTO T_Movies VALUES ('Little Fockers', 'Little Fockers', 2010);
INSERT INTO T_Movies VALUES ('Love Streams', 'Love Streams', 1984);
INSERT INTO T_Movies VALUES ('Casino Royale', 'Casino Royale', 2006);
INSERT INTO T_Movies VALUES ('Dr. No', 'Dr. No', 1962);
INSERT INTO T_Movies VALUES ('Austin Powers in Goldmember', 'Austin Powers in GoldMember', 2002);
INSERT INTO T_Movies VALUES ('Austin Powers: The Spy Who Shagged Me', 'Austin Powers: The Spy Who Shagged Me', 1999);
INSERT INTO T_Movies VALUES ('Goldfinger', 'Goldfinger', 1964);

CREATE TABLE MovieActors (
	ActorId INT NOT NULL,
	MovieId INT NOT NULL,
	CharacterFirstName NVARCHAR(50) NULL,
	CharacterLastName NVARCHAR(50) NULL,
	IsLeadingRole BIT NOT NULL DEFAULT 0,
	WasAwarded BIT NOT NULL DEFAULT 0,

	--CONSTRAINT PK_MovieActors PRIMARY KEY CLUSTERED (MovieId, ActorId),
	CONSTRAINT FK_MovieActors_Movies FOREIGN KEY (MovieId) REFERENCES T_Movies (MovieId),
	CONSTRAINT FK_MovieActors_Actors FOREIGN KEY (ActorId) REFERENCES T_Actors (ActorId)
);

INSERT INTO MovieActors VALUES (
	1000, -- Pfeiffer
	1, -- Wizard of Lies
	'Ruth', 'Madoff', 1, 0);

INSERT INTO MovieActors VALUES (
	1002, -- De Niro
	1, -- Wizard of Lies
	'Bernie', 'Madoff', 1, 0);	

INSERT INTO MovieActors VALUES (
	1000, -- Pfeiffer
	3, -- Coolio
	NULL, NULL, 0, 0);

INSERT INTO MovieActors VALUES (
	1002, -- De Niro
	4, -- Little Fockers
	'Jack', 'Byrnes', 1, 0);

INSERT INTO MovieActors VALUES (
	1004, -- Connery
	7, -- Dr. No
	'James', 'Bond', 1, 0);

INSERT INTO MovieActors VALUES (
	1005, -- Craig
	6, -- Casino Royale
	'James', 'Bond', 1, 0);

INSERT INTO MovieActors VALUES (
	1003, -- Raphael De Niro
	5, -- Love Streams
	'Billy', NULL, 0, 0);

INSERT INTO MovieActors VALUES (
	1006, -- John Malkovich
	2, -- Being John Malkovich
	'John', 'Malkovich', 0, 0);

INSERT INTO MovieActors VALUES (
	1001, -- Dustin Hoffman
	2, -- Being John Malkovich
	'Willy', 'Loman', 0, 0);

INSERT INTO MovieActors VALUES (
	1007, -- Mike Myers
	8, -- Goldmember
	'Austin', 'Powers', 1, 1);

INSERT INTO MovieActors VALUES (
	1007, -- Mike Myers
	8, -- Goldmember
	'Dr.', 'Evil', 1, 1);

INSERT INTO MovieActors VALUES (
	1007, -- Mike Myers
	9, -- Spy Who Shagged Me
	'Austin', 'Powers', 1, 1);

INSERT INTO MovieActors VALUES (
	1007, -- Mike Myers
	9, -- Sphy Who Shagged Me
	'Dr.', 'Evil', 1, 1);

INSERT INTO MovieActors VALUES (
	1004, -- Connery
	10, -- Goldfinger
	'James', 'Bond', 1, 0);

SELECT M.MovieId, MovieTitle, FirstName, LastName
	, CharacterFirstName, CharacterLastName
FROM T_Movies M
	INNER JOIN MovieActors MA ON MA.MovieId = M.MovieId
	INNER JOIN T_Actors A ON A.ActorId = MA.ActorId
ORDER BY SortableMovieTitle;

/*******************************************************************************
	QUERIES
*******************************************************************************/

-- In which movie(s) did Pfeiffer have a role?
SELECT M.MovieTitle, ReleaseYear
FROM T_Actors A
	INNER JOIN MovieActors MA ON MA.ActorId = A.ActorId
	INNER JOIN T_Movies M ON M.MovieId = MA.MovieId
WHERE A.LastName = 'Pfeiffer'
ORDER BY SortableMovieTitle;

-- In which movie(s) did Pfeiffer have a leading role?
SELECT M.MovieTitle, ReleaseYear
FROM T_Actors A
	INNER JOIN MovieActors MA ON MA.ActorId = A.ActorId
	INNER JOIN T_Movies M ON M.MovieId = MA.MovieId
WHERE A.LastName = 'Pfeiffer'
	AND MA.IsLeadingRole = 1
ORDER BY SortableMovieTitle;

-- Who acted in Wizard of Lies?
SELECT A.*
FROM T_Actors A
	INNER JOIN MovieActors MA ON MA.ActorId = A.ActorId
	INNER JOIN T_Movies M ON M.MovieId = MA.MovieId
WHERE M.MovieTitle = 'The Wizard of Lies';

-- Who played James Bond?
SELECT A.FirstName, A.LastName
FROM T_Actors A
	INNER JOIN MovieActors MA ON MA.ActorId = A.ActorId
WHERE MA.CharacterFirstName = 'James'
	AND MA.CharacterLastName = 'Bond'
GROUP BY A.FirstName, A.LastName;

-- Which movies did Pfeiffer act in where De Niro was also an actor?
SELECT M.MovieTitle
FROM T_Actors A1
	INNER JOIN MovieActors MA1 ON MA1.ActorId = A1.ActorID
	INNER JOIN MovieActors MA2 ON MA1.MovieId = MA2.MovieId
	INNER JOIN T_Actors A2 ON A2.ActorID = MA2.ActorId
	INNER JOIN T_Movies M ON M.MovieId = MA1.MovieId
WHERE A2.LastName = 'Pfeiffer'
	AND A1.FirstName = 'Robert' AND A1.LastName = 'De Niro';