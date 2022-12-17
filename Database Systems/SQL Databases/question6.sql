-- Deliverable #6

SELECT lastname, 
	   firstname,
	   party,
	   disagreements, 
	   agreements,
	   (agreements - disagreements) / (agreements + disagreements) AS agreement_index
FROM
	
	(SELECT *
	FROM
	
		(SELECT A.id, A.lastname, A.firstname, A.party, COALESCE(B.disagreements, 0) AS disagreements
		FROM senator AS A
		
		LEFT JOIN
		
		(SELECT Y.sen_id, COUNT(*) AS disagreements
		FROM (
			(SELECT *
			FROM voted
			WHERE sen_id = "S293") AS X -- Lindsey Graham
		
		LEFT JOIN 
		
		(SELECT *
		FROM voted) AS Y
		
		ON Y.congress = X.congress AND Y.session = X.session AND Y.number = X.number)
		
		WHERE Y.vote != X.vote AND Y.vote != "A" AND X.vote != "A"
		GROUP BY Y.sen_id) AS B
		
		ON A.id = B.sen_id)
		
	AS disagreements) AS disagreements2
	
	NATURAL JOIN
	
	(SELECT *
	FROM
	
		(SELECT A.id, A.lastname, A.firstname, A.party, COALESCE(B.agreements, 0) AS agreements
		FROM senator AS A
		
		LEFT JOIN
		
		(SELECT Y.sen_id, COUNT(*) AS agreements
		FROM (
			(SELECT *
			FROM voted
			WHERE sen_id = "S293") AS X -- Lindsey Graham
		
		LEFT JOIN 
		
		(SELECT *
		FROM voted) AS Y
		
		ON Y.congress = X.congress AND Y.session = X.session AND Y.number = X.number)
		
		WHERE Y.vote = X.vote AND Y.vote != "A" AND X.vote != "A"
		GROUP BY Y.sen_id) AS B
		
		ON A.id = B.sen_id)

	AS agreements) AS agreements2
	
ORDER BY agreement_index DESC;

-- There is very clear divide with the senators we have experimented with; their party members will 
-- have a positive agreement index and the opposing party will have a negative agreement index.

