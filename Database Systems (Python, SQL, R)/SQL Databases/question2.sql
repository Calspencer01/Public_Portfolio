-- Deliverable #2

SELECT X.lastname, 
	   X.firstname, 
	   COALESCE(Y.absences, 0) AS absences
FROM 
	senator AS X

	LEFT JOIN

	(SELECT S.id, S.lastname, S.firstname, COUNT(*) AS absences
	FROM 
		voted AS V
	
		LEFT JOIN 
	
		senator AS S
	
		ON S.id = V.sen_id
		
	WHERE vote = "A"
	GROUP BY sen_id
	ORDER BY absences DESC) AS Y
	
	ON X.id = Y.id
	
ORDER BY absences DESC;