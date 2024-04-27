# Famous Painting Exploratory Analysis

## Table of Contents
- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning/Preparation](#data-cleaning-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results/Findings](#resultsfindings)

### Project Overview

This project aims to delve into the world of famous paintings through an exploratory data analysis approach. By uncovering hidden patterns and trends, we can gain a deeper understanding of artistic styles, historical influences, and the evolution of art itself.

### Data Sources

The project leverages a public dataset on famous paintings which include;
- "artist.csv" file, containing detailed information about the artists
- "canvas_size.csv" file, containing detailed information about the size of the paintings
- "image_link.csv" file, containing internet-accessible links to the project
- "museum.csv" file, containing detailed information about the museums
- "museum_hours.csv" file, containing information of the days and hours the museum opens
- "product_size.csv" file, containing information about the asking price and sales price of the paintings
- "subject.csv" file, containing information about the subject type of the paintings
- "work.csv" file, containing detailed information about the paintings

### Tools
  - SQL Server - Data Analysis
 
### Data Cleaning/Preparation

In the data preparation phase, we performed the following tasks:
1. Data loading and inspection
2. Handling missing values
3. Data cleaning and formatting

### Exploratory Data Analysis

EDA involved exploring the datasets to answer key questions such as:

- Total Artists
- Total Paintings
- Total Museums
- Painting Subject Count
- Paintings which are not displayed in any museums
- Museums which have no paintings
- Paintings whose asking price is greater than the regular price
- Paintings whose asking price is 50% greater than the regular price
- The most expensive canvas size
- Museums with invalid city information
- Top painting subject
- Museums which are both open on Sunday's and Monday's
- Museums which are open everyday of the week
- Most popular museums
- Most popular artists
- Least popular canvas sizes
- Museum with the longest open hours
- Museum with the most number of popular paintings style
- Artists whose paintings are displayed in multiple countries
- Artist and museum where the most expensive and least expensive paintings is placed
- Countries with the highest number of paintings
- Most popular and least popular painting styles
- Artist with the most number of potrait paintngs outside USA

### Data Analysis

Included below is some of the code I worked in order to acheive accurate results in my analyis

To identify the country with the 5th highest number of painting:
```sql
WITH cte AS 
			(SELECT country, ROW_NUMBER() OVER(ORDER BY COUNT(work.name) DESC) row_no, COUNT(work.name) painting_count
			FROM museum
			JOIN work
				ON museum.museum_id = work.museum_id
			GROUP BY country
			)
SELECT country, painting_count
FROM cte
WHERE row_no = 5;
```

To identify artists whose paintings are displayed in multiple countries:
```sql
WITH cte AS
		(SELECT DISTINCT artist.full_name as artist
		--, work.name as painting, museum.name as museum
		, museum.country
		from work 
		join artist on artist.artist_id=work.artist_id
		join museum on museum.museum_id=work.museum_id)
	SELECT artist,count(1) no_of_countries
	FROM cte
	GROUP BY artist
	HAVING COUNT(1)>1
	ORDER BY 2 DESC;
```

To identify which museum has the most number of popular painting style:
```sql
WITH style_type AS 
				(SELECT style
				,RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
				FROM work
				GROUP BY style),
	cte AS
		(SELECT work.museum_id, museum.name museum_name, style_type.style, COUNT(1) painting_count
		,RANK() OVER(ORDER BY COUNT(1) desc) AS rnk
		FROM work
		JOIN museum
			ON museum.museum_id = work.museum_id
		JOIN style_type
			ON style_type.style = work.style
		WHERE museum.museum_id IS NOT NULL
		AND style_type.rnk = 1
		GROUP BY work.museum_id, museum.name, style_type.style)
	SELECT TOP 1 museum_name, style, painting_count
	FROM cte
	ORDER BY painting_count DESC;
```

### Results/Findings
The analysis results are summarized as follows;
1. Total artists were identified to be 421
2. Total paintings were identified to be 14,776
3. Total museums were identified to be 57
4. There were a total of 29 painting subjects, with Potraits being the most at 1,070
5. The total number of paintings not displayed in any museums are 10,223
6. No paintings had their asking price greater than the regualar price
7. A total of 58 paintings had thier asking price less than 50%  of its regular price
8. The most expensive canvas style was 48" x 96"(122 cm x 244 cm), at a sale price of 1055
9. A total of 28 museums were open both on Sunday and Monday
10. The most popular museum was The Metropolitan Museum of Art with 939 paintings
11. The most popular artsit was Pierre-Auguste Renoir with 469 paintings
12. There were 8 canvas size tied at least popular
13. Musée du Louvre, Paris had the longest open duration at 12 hours
14. The Metropolitan Museum of Art was the museum with the most popular painting style, Impressionism, at 244
15. 194 artists had thier paintings displayed in multiple coutries
16. Artist, Peter Paul Rubens, 	with canvas label, 48" x 96"(122 cm x 244 cm), with painting name, Fortuna	and a sale price of 1115	in the The Prado Museum, Madrid museum had the most expensive painting and artist, Adélaïde Labille-Guiard	with vanvas labels, 30" and 36" Long Edge, with painting name, Portrait of Madame Labille-Guyard and Her Pupils	and a sale price of 10 in The Metropolitan Museum of Art, New York was the least expensive painting
17. USA was identified as the country with the most number of painting at 2,672
18. Impressionism was identified as the most popular painting style while Japanese Art was identified as the least popular painting style
19. The artist Vincent Van Gogh with with Dutch nationality had the most number of potrait paintings, 14 outside USA

### Limitations
There were quite a few duplicates in some datasets which had to be taken care of to ensure accuracy of the analysis
