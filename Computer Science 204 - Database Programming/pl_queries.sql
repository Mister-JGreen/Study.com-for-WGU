/* Part C - List of query Questions */

/* Select the database that we need to use for all query questions  */
USE public_library;

/*  QUESTION 1  */
SELECT *
FROM tblClient;

/*  QUESTION 2  */
# Used NOW() to enable the current year and then subtracted that from the ClientDoB
SELECT ClientFirstName, ClientLastName, (YEAR(NOW())-ClientDoB) AS Age, Occupation
FROM tblClient;

/*  QUESTION 3  */
# Used an INNER JOIN to merge the Client table to the Borrower table using the Primary Key from tblClient and the Foreign Key from tblBorrower
# The WHERE statement pulls data from dates only in March, 2018
SELECT ClientFirstName, ClientLastName
FROM tblClient
INNER JOIN tblBorrower
ON tblClient.ClientID = tblBorrower.ClientID
WHERE BorrowDate BETWEEN '2018-03-01' AND '2018-03-31'
GROUP BY tblClient.ClientID;

/*  QUESTION 4  */
# Used INNER JOIN to combine the Author table with the Book table; and then again to combine the Book table to the Borrower table
# A WHERE statement was used to find borrow dates only in 2017
# ORDERed the data by BookID usage in descending order, limiting count to 5 to get the 5 most popular authors in the year 2017
SELECT AuthorFirstName, AuthorLastName
FROM tblAuthor
INNER JOIN tblBook
ON tblAuthor.AuthorID = tblBook.BookAuthor
INNER JOIN tblBorrower
ON tblBook.BookID = tblBorrower.BookID
WHERE YEAR(BorrowDate) = 2017
GROUP BY tblBorrower.BookID
ORDER BY COUNT(tblBorrower.BookId) DESC LIMIT 5;

/* Create a Index for the Borrowers Table for quicker queries */
CREATE INDEX BorrowerIndex
ON tblBorrower (BorrowID, ClientID, BookID, BorrowDate);

/*  QUESTION 5  */
# Used INNER JOIN to combine the Author table with the Book table; and then again to combine the Book table to the Borrower table
# A WHERE YEAR statement was used to find borrow dates between the years 2015 and 2017
# Used a GROUP BY to group results by the Author's Nationality
# ORDERed the data by BookID usage in ascending order, limiting count to 5 to get the 5 least popular nationalities in the years 2015-2017
SELECT AuthorNationality
FROM tblAuthor
INNER JOIN tblBook
ON tblAuthor.AuthorID = tblBook.BookAuthor
INNER JOIN tblBorrower
ON tblBook.BookID = tblBorrower.BookID
WHERE YEAR(BorrowDate) BETWEEN 2015 AND 2017
GROUP BY AuthorNationality
ORDER BY COUNT(tblBorrower.BookID);

/*  QUESTION 6  */
# The formatting of this query was very similar to the previous 3 questions
# COUNT needed to be in Descending order to prodcure the most popular Book Title in the given time frame (2015-2017)
# Also included a subquery SQL that resulted in the same table for the purpose of practice
SELECT BookTitle
FROM tblBook
INNER JOIN tblBorrower
ON tblBook.BookID = tblBorrower.BookID
WHERE YEAR(BorrowDate) BETWEEN 2015 AND 2017
GROUP BY tblBook.BookID
ORDER BY COUNT(tblBook.BookID) DESC LIMIT 1;
/*  Using Subquery  */
SELECT BookTitle
FROM (
	SELECT BookID, COUNT(BookID) AS BookCount
	FROM tblBorrower
	WHERE YEAR(BorrowDate) BETWEEN 2015 AND 2017
	GROUP BY BookID
) AS tmpBookCount
INNER JOIN tblBook
ON tblBook.BookID = tmpBookCount.BookID
ORDER BY BookCount DESC LIMIT 1;

/*  QUESTION 7  */
# Similar to above queries; combined tables PRIMARY KEYS and FOREIGN KEYS using INNER JOIN statements
# Used a WHERE statement on the Client table to filter out Date of Births between 1970 and 1980
# Used an ORDER statement on the Borrower table to show table in order of most popular first
# Decided to add a second column to table as a COUNT statement to show how many times each Genre was Borrowed because I thought it added more clarity to the query
SELECT Genre, COUNT(tblBorrower.BookID) AS BorrowCount
FROM tblBook
INNER JOIN tblBorrower
ON tblBook.BookID = tblBorrower.BookID	
INNER JOIN tblClient
ON tblBorrower.ClientID = tblClient.ClientID
WHERE tblClient.ClientDOB BETWEEN 1970 AND 1980
GROUP BY tblBook.Genre
ORDER BY BorrowCount DESC;

/*  QUESTION 8  */
# Almost the exact same format as the above query
# Ordered by newly create column "BorrowCount" and limited to 5 to show the top 5 occupations that borrowed in the year 2016
SELECT Occupation, COUNT(tblBorrower.BookID) AS BorrowCount
FROM tblClient
INNER JOIN tblBorrower
ON tblClient.ClientID = tblBorrower.ClientID
WHERE YEAR(tblBorrower.BorrowDate) = 2016
GROUP BY tblClient.Occupation
ORDER BY BorrowCount DESC LIMIT 5;

/*  QUESTION 9  */
# To get average borrowed per occupation I first accessed the Occupation date from the Client table
# I got the average by counting the number of people per occupation and dividing that by the Distinct count of books borrowed by ClientID
# The average was rounded for ease of reading
# The average was given an alias of 'AverageBorrowed'
# The two tables used were INNER JOINed through the ClientID; Data was GROUP BY Occupation 
SELECT tblClient.Occupation, ROUND(COUNT(tblClient.Occupation) / COUNT(DISTINCT tblBorrower.ClientID)) AS AverageBorrowed
FROM tblClient
INNER JOIN tblBorrower
ON tblClient.ClientID = tblBorrower.ClientID
GROUP BY tblClient.Occupation;

/*  QUESTION 10  */
# I created a view with the CREATE VIEW statement and gave it the name 'Titles_viewed_by_20_percent_of_Clients' to preserve the view table
# I use SELECT to identify the existing column I wish to pull into the view, which is 'BookTitle' column from the Books table
# I used a INNER JOIN to connect values from the Books table and the selected Borrowers table
# I used a GROUP BY statement to group the result-set by the 'BookTitle' column
# I then used the HAVING clause to specify filter conditions for a group of rows or aggregates; This condition is applied after the GROUP BY clause in the SQL query
# Used the DISTINCT constraint because we were interested in the unique ClientIDs that borrowed each book
# Used a SELECT subquery
# This query will create a view that includes the titles borrowed by at least 20% of the clients
CREATE VIEW Titles_viewed_by_20_percent_of_Clients AS (
	SELECT tblBook.BookTitle
	FROM tblBook
	INNER JOIN tblBorrower
	ON tblBook.BookID = tblBorrower.BookID
	GROUP BY tblBook.BookTitle
	HAVING COUNT(DISTINCT tblBorrower.ClientID) >= (0.2 * (SELECT COUNT(DISTINCT tblBorrower.ClientID) FROM tblBorrower))
);
# Query to show newly established VIEW
SELECT * FROM Titles_viewed_by_20_percent_of_Clients;

/*  QUESTION 11  */
# This query first uses the MONTH() function to extract the month from the BorrowDate column, and then assigns it to an alias month
# I then uses the COUNT() function to count the number of borrows for each month, and assigns it to an alias Number_of_Borrows
# The WHERE clause filters the results to only include borrows that occurred in 2017
# The GROUP BY clause groups the results by month, so that the COUNT() function is applied to each individual month
# The ORDER BY clause sorts the results by Number_of_Borrows in descending order, so that the month with the most borrows is first
# The LIMIT clause had to be used with 3, because there were 3 months with the same amount of borrowed books in a month
SELECT MONTH(BorrowDate) AS Month, COUNT(*) AS Number_of_Borrows
FROM tblBorrower
WHERE YEAR(BorrowDate) = 2017
GROUP BY Month
ORDER BY Number_of_Borrows DESC LIMIT 3;

/*  QUESTION 12  */
# The first line selects the age of each borrower by subtracting their date of birth (ClientDoB) from the current year (YEAR(NOW())). The DISTINCT keyword ensures that each age is only calculated once
# The next column calculates the average number of times a borrower has borrowed from the library. I did this by dividing the total number of borrowers by the number of distinct borrowers. The ROUND function is used to round the result to the nearest whole number
# I used INNER JOIN to join the Client table with the Borrowers table through there common ClientID
# Grouped the results by the age of each borrower
SELECT DISTINCT (YEAR(NOW())-tblClient.ClientDoB) AS Age_of_Borrower, ROUND(COUNT(tblClient.ClientID)/ COUNT(DISTINCT tblBorrower.ClientID)) AS Average_Borrowed
FROM tblClient
INNER JOIN tblBorrower
ON tblClient.ClientID = tblBorrower.ClientID
GROUP BY Age_of_Borrower;

/*  QUESTION 13  */
# All information needed was from the Client table
# Selected the Clients First Name, Last Name, and Age from the tblClient to be queried; Age of each client was calculated by subtracting their date of birth (ClientDoB) from the current year (YEAR(NOW()))
# A WHERE clause was used to get the results to only include clients whose age is equal to the minimum age in the table
# The WHERE clause compares the calculated age of each client with the minimum age, which is calculated using a subquery
# The subquery uses the MIN() function to find the minimum value of YEAR(NOW())-ClientDoB in the tblClient table
SELECT ClientFirstName, ClientLastName, (YEAR(NOW()) - ClientDoB) AS Age
FROM tblClient
WHERE YEAR(NOW()) - ClientDoB = (SELECT MIN(YEAR(NOW())-ClientDoB) FROM tblClient);

# Same as above except we use a MAX() function to find the oldest clients of the library
SELECT ClientFirstName, ClientLastName, (YEAR(NOW()) - ClientDoB) AS Age
FROM tblClient
WHERE YEAR(NOW()) - ClientDoB = (SELECT MAX(YEAR(NOW())-ClientDoB) FROM tblClient);

/*  QUESTION 14  */
# Used a SELECT on the tblAuthor table to get the First and Last name of the Authors; used an Alias to better represent the new table
# Joined the Author table with the Book table using an INNER JOIN in order to compare Authors with Genres written
# Grouped results by AuthorID
# I used a HAVING clause to count the number of distinct genres in the tblBook table, and then filtering the results to only include authors who have more than 1 genre
# Results were that no Author on the current database has written more than 1 Genre of books
SELECT tblAuthor.AuthorFirstName AS FirstName, tblAuthor.AuthorLastName AS LastName 
FROM tblAuthor
INNER JOIN tblBook
ON tblAuthor.AuthorID = tblBook.BookAuthor
GROUP BY tblAuthor.AuthorID
HAVING COUNT(DISTINCT tblBook.Genre) > 1;
