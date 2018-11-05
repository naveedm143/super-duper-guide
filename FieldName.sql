IF OBJECT_ID('tempdb..#temp') IS NOT NULL 
BEGIN
	DROP TABLE #temp;
END

IF OBJECT_ID('tempdb..#control_table1') IS NOT NULL 
BEGIN
	DROP TABLE #control_table1;
END

IF OBJECT_ID('tempdb..#control_table2') IS NOT NULL 
BEGIN
	DROP TABLE #control_table2;
END

CREATE TABLE #control_table1
(newFieldName VARCHAR(500))

CREATE TABLE #control_table2
(newFieldName VARCHAR(500), CorrectFieldname VARCHAR(500))

INSERT #control_table1
(
    newFieldName
)
SELECT FieldName
FROM [Forms].[dbo].[Dsh9220Fileupload]

INSERT #control_table2
(
    newFieldName
)
SELECT newfieldname
FROM #control_table1


WHILE EXISTS (SELECT * FROM #control_table1)

BEGIN 

		DECLARE @str VARCHAR(MAX) 
		declare @i INT = 0
		declare @j INT = 0
		declare @returnval nvarchar(max)

		SET @str = ''
		
		
		SELECT @str = MIN(newFieldName)
		FROM #control_table1

		
	


		set @returnval = ''
		SET @i = 0
		set @j = 0
		select @i = 1, @j = len(@str)

		declare @w nvarchar(max)

		while @i <= @j
		begin
		 if substring(@str,@i,1) = UPPER(substring(@str,@i,1)) collate Latin1_General_CS_AS
		 begin
		  if @w is not null
		  set @returnval = @returnval + ' ' + @w
		  set @w = substring(@str,@i,1)
		 end
		 else
		  set @w = @w + substring(@str,@i,1)
		 set @i = @i + 1
		end
		if @w is not null
		 set @returnval = @returnval + ' ' + @w

		--select @str, LTRIM(@returnval)

		UPDATE ct2
		SET CorrectFieldname = ltrim(@returnval)
		FROM #control_table2 ct2
		WHERE newFieldName = @str

		DELETE ct1
		FROM #control_table1 ct1
		WHERE newFieldName = @str
		
		SET @w = ''
END


SELECT REPLACE(CorrectFieldname, 'Upload File', 'Attach') Fieldname
INTO #temp
FROM #control_table2

DECLARE @sql VARCHAR(MAX)
DECLARE @MIN_fieldname VARCHAR(MAX)

SELECT @MIN_FIELDNAME = MIN(fieldname)
FROM #temp

	SET QUOTED_IDENTIFIER OFF

	SELECT @sql = "Select MAX(case when t.Fieldname = "
					+ "'" + fieldname + "'" 
						+ " THEN " + "''" + " END) AS "
						+ "[" + fieldname + "]"
	FROM #temp
	WHERE fieldname = @MIN_fieldname

	SELECT @sql = @sql + CHAR(10) + CHAR(13)
						+ " , MAX(Case when t.Fieldname = " 
						+ "'" + fieldname + "'" 
						+ " THEN " + "''" + " END) AS "
						+ "[" + fieldname + "]" 
	FROM #temp
	WHERE fieldname <> @MIN_fieldname

	SELECT @sql = @sql + CHAR(10) + CHAR(13) + " FROM #temp t"
			

	SET QUOTED_IDENTIFIER ON

EXEC (@sql)
 







