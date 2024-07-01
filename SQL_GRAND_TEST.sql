--### Section 1: 1 mark each

--1. Write a query to calculate the price of 'Starry Night' plus 10% tax.

SELECT price*1.1 AS PricePLUSTax
FROM artworks
WHERE title='Starry Night'

--2. Write a query to display the artist names in uppercase.

SELECT UPPER(name)
FROM artists

--3. Write a query to extract the year from the sale date of 'Guernica'.

SELECT DATEPART(year,sale_date) as YEARR
FROM sales as s
JOIN artworks as arts ON arts.artwork_id=s.artwork_id
WHERE arts.title LIKE 'Guernica'

--4. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.

SELECT SUM(total_amount) AS MonalisaSalesAmount
FROM sales as s
JOIN artworks as arts ON arts.artwork_id=s.artwork_id
WHERE arts.artwork_id=( SELECT artwork_id 
						FROM artworks
						WHERE title LIKE 'Mona Lisa')

--### Section 2: 2 marks each

--5. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.


SELECT a.artist_id,AVG(quantity) as ArtistAvg
FROM artists as a 
JOIN artworks as arts ON arts.artist_id=a.artist_id
JOIN sales as s ON s.artwork_id=arts.artwork_id
GROUP BY a.artist_id

--6. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.

	SELECT country,AVG(birth_year) as AVGbirthyearbycountry
	FROM artists
	GROUP BY country
GO
With CTE_Avgbirthyear
AS
(
)
SELECT name 
FROM artists
WHERE birth_year<(SELECT AVGbirthyearbycountry)

--7. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.

CREATE NONCLUSTERED INDEX NonCIforsalesbyartwork_id ON sales(artwork_id)
EXEC sp_helpindex sales

--8. Write a query to display artists who have artworks in multiple genres.


INSERT INTO artworks VALUES(6,'The Chronicles of Narnia',4,'Cubism',1500000)


With CTE_differenntGenre
AS
(
	SELECT arts.artist_id,a.name,COUNT(DISTINCT genre) as difgenre
	FROM artworks as arts
	JOIN artists as a ON a.artist_id=arts.artist_id
	GROUP BY  arts.artist_id,a.name
)
SELECT *
FROM CTE_differenntGenre
WHERE difgenre>1

--9. Write a query to rank artists by their total sales amount and display the top 3 artists.

SELECT a.name,
	   SUM(total_amount) as ArtistSaleTotal,
	   RANK() OVER (ORDER BY SUM(total_amount) DESC) as RANKK
FROM artists as a
JOIN artworks as arts ON arts.artist_id=a.artist_id
JOIN sales as s ON s.artwork_id=arts.artwork_id
GROUP BY a.name

--10. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.

SELECT a.artist_id,
	   a.name
FROM artists as a
JOIN artworks as arts ON arts.artist_id=a.artist_id
WHERE genre LIKE 'Cubism'

INTERSECT

SELECT a.artist_id,
	   a.name
FROM artists as a
JOIN artworks as arts ON arts.artist_id=a.artist_id
WHERE genre LIKE 'Surrealism'


--11. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.


SELECT TOP(2)title,price,quantity
FROM artworks as arts
JOIN sales as s ON s.artwork_id=arts.artwork_id
ORDER BY price DESC

--12. Write a query to find the average price of artworks for each artist.

SELECT arts.artist_id,a.name,AVG(price) as AVGpriceforArtsforEachArtist
FROM artworks as arts
JOIN artists as a ON a.artist_id=arts.artist_id
GROUP BY arts.artist_id,a.name

--13. Write a query to find the artworks that have the highest sale total for each genre.

 
SELECT genre,MAX(total_amount) as genretotal
FROM artworks as arts
JOIN sales as s ON s.artwork_id=arts.artwork_id
GROUP BY genre
ORDER BY genretotal DESC

--14. Write a query to find the artworks that have been sold in both January and February 2024.

SELECT title,sale_date 
FROM artworks as arts
JOIN sales as s ON s.artwork_id=arts.artwork_id
WHERE DATEPART(year,sale_date) = 2024
	  AND
	  DATEPART(month,sale_date) = 01
	  OR
      DATEPART(month,sale_date) = 02


--15. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.

SELECT * FROM artists
SELECT * FROM artworks
SELECT * FROM sales
GO
With CTE_artistshigherthanRENAISSANCE
AS
(
SELECT name,avg(price) as artistavg
FROM artworks as arts
JOIN artists as a ON a.artist_id=arts.artist_id
GROUP BY name,arts.artist_id
)
SELECT *
FROM CTE_artistshigherthanRENAISSANCE
WHERE artistavg > ( SELECT MAX(price) 
					FROM artworks
					WHERE genre ='Renaissance')

--### Section 3: 3 Marks Questions

--16. Write a query to create a view that shows artists who have created artworks in multiple genres.
GO
CREATE VIEW vWartistsinmultiplegenre
AS
	With CTE_MultipleGenre
	AS
	(
		SELECT arts.artist_id,a.name,COUNT(DISTINCT genre) as multiplegenre
		FROM artworks as arts
		JOIN artists as a ON a.artist_id=arts.artist_id
		GROUP BY arts.artist_id,a.name
	)
	SELECT * FROM CTE_MultipleGenre
	WHERE multiplegenre>1
GO

SELECT * FROM vWartistsinmultiplegenre
--17. Write a query to find artworks that have a higher price than the average price of artworks by the same artist.
SELECT artist_id,AVG(price)
FROM artworks
GROUP BY artist_id

SELECT AVG(price)
FROM artworks
--18. Write a query to find the average price of artworks for each artist and only include artists 
-- whose average artwork price is higher than the overall average artwork price.
GO
With CTE_ArtistsWithHighPriceAvg
AS
(
	SELECT a.artist_id,a.name,AVG(price) as ArtistAvg
	FROM artworks as arts
	JOIN artists as a ON a.artist_id=arts.artist_id
	GROUP BY a.artist_id,a.name
)
SELECT * FROM CTE_ArtistsWithHighPriceAvg
WHERE ArtistAvg > ( SELECT AVG(price)
					FROM artworks)
--### Section 4: 4 Marks Questions

--19. Write a query to export the artists and their artworks into XML format.

SELECT a.artist_id as [@ArtistID],
	   a.name,
	   art.title
FROM artists as a
JOIN artworks as art ON art.artist_id=a.artist_id
FOR XML Path('ArtAndArtists'),Root('ARTS')
--20. Write a query to convert the artists and their artworks into JSON format.

SELECT a.artist_id as 'ArtANDArtists.ArtistID',
	   a.name as 'ArtANDArtists.ArtistName',
	   art.title as 'ArtANDArtists.ArtName'
FROM artists as a
JOIN artworks as art ON art.artist_id=a.artist_id
FOR JSON PATH,ROOT('Art_And_Artists')

--### Section 5: 5 Marks Questions

--21. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.

GO
CREATE FUNCTION dbo.TotalQuantityByGenre (@genre VARCHAR(50))
RETURNS @TotalQuantityByGenre TABLE
		(artgenre VARCHAR(50),
		 genre_quantity INT)
AS
BEGIN
			INSERT INTO @TotalQuantityByGenre
			SELECT arts.genre,SUM(quantity) as genre_quantity
			FROM artworks as arts
			JOIN sales as s ON s.artwork_id=arts.artwork_id
			WHERE arts.genre=@genre
			GROUP BY genre
RETURN
END
GO
SELECT * FROM dbo.TotalQuantityByGenre('Cubism');
GO

--22. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.
USE sql_grand_test
SELECT * FROM artists
SELECT * FROM artworks
SELECT * FROM sales
GO
ALTER FUNCTION dbo.AverageSaleForGenre (@genre VARCHAR(50))
RETURNS INT
AS 
BEGIN
	RETURN (
				SELECT SUM(total_amount) as genretotalsale
				FROM sales as s
				JOIN artworks as arts ON arts.artwork_id=s.artwork_id
				WHERE genre=@genre
				GROUP BY genre
)
END;
GO
SELECT dbo.AverageSaleForGenre ('Impressionism') as avgsalesamount
GO
--23. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.
SELECT * FROM artists
SELECT * FROM artworks
SELECT * FROM sales
--24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.
GO
CREATE TRIGGER trg_artworkidandtitleupdates
ON artworks
AFTER UPDATE 
AS
BEGIN

	INSERT INTO artworks_log
	SELECT 'artwork_id','title',artwork_id,GetDate()
	FROM inserted

END

UPDATE artworks
SET title='The Chronilce of Narnia'
WHERE artwork_id=6

--25. Create a stored procedure to add a new sale and update the total sales for the artwork. 
--  Ensure the quantity is positive, and use transactions to maintain data integrity.

GO
ALTER PROCEDURE Saleupdate
(
  @artwork_id VARCHAR(50),
  @total_amount INT
)
AS
BEGIN
	BEGIN TRANSACTION;
			
            UPDATE sales
            SET total_amount = @total_amount
            WHERE EmployeeID = @EmployeeID;
		COMMIT TRANSACTION;     
END
GO

EXEC Saleupdate @artwork_id=4,
				@total_amount=1000000
--### Normalization (5 Marks)

--26. **Question:**
--    Given the denormalized table `ecommerce_data` with sample data:

--| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
--| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
--| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
--| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
--| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
--| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

--Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.

--### ER Diagram (5 Marks)

--27. Using the normalized tables from Question 26, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.