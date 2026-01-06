/********************************************************************************************
-- +========================================================================================+
-- |                         Macquarie (Hong Kong)                                          |
-- +========================================================================================+
-- |                                                                                        |
-- |Application Name   :  Order report Statistics                                           |
-- |Object Name        :  P_CLICONN_FX_ORDR_STAT_CNT_REP.sql                                |
-- |Author Name        :  Akhil benarji                                                     |
-- |Date of Creation   :  08 August, 2008                                                   |
-- |Description        :  Procedure to get the No of orders, account managers and other data|
-- |                      for each Client													|
-- |Revision History   :                                                                    |
-- |----------------------------------------------------------------------------------------|
-- |Rno        Date Changed           Changed By        Change Details                      |
-- |----------------------------------------------------------------------------------------|
-- |1.0        08 Aug 2008            Akhil benarji.    Initial Creation                    |
-- |1.4        09 Oct 2008            Akhil benarji.    a)Changes made inorder to get the   |         
-- |                                                      records from the archive table if |
-- |                                                      if the current date is > from date|
-- |1.5        13 Oct 2008            Akhil benarji.    Joined orderstat and archive tables |         
-- |                                                                                        |
-- |                                                                                        |
-- |                                                                                        |
-- |----------------------------------------------------------------------------------------|
********************************************************************************************/ 
CREATE PROCEDURE dbo.P_CLICONN_FX_ORDR_STAT_CNT_REP
	@REPORT_ID 			VARCHAR(50),
	@INPARAMS			VARCHAR(1000),
	@FROM_DATE			VARCHAR(10)	= NULL,
	@TO_DATE			VARCHAR(10)  = NULL,
	@RETURN_CODE		INT		OUTPUT,
	@RETURN_MSG			VARCHAR(255) OUTPUT
AS
    BEGIN
    
    	DECLARE @l_fromDate		varchar(8),
    			@l_toDate		varchar(8),
        		@ERRORCODE				INT,
        		@ERRORMSG				VARCHAR(1000)         			
    			
		SELECT @RETURN_CODE = 0 		
		SELECT @RETURN_MSG = NULL	
		SELECT @ERRORCODE = 0
		SELECT @ERRORMSG = NULL		
    
    	-- Check the in parameter @FROM_DATE is null		
    	-- If null get todays date in the format yyyymmdd
        IF @FROM_DATE IS NULL OR @FROM_DATE = ''
        	BEGIN
        		SELECT @l_fromDate = convert(varchar,getdate(),112)
        	END
        ELSE
        	BEGIN
        		IF CHARINDEX('/',@FROM_DATE) > 0
        			BEGIN
        				SELECT @l_fromDate = convert(varchar,CONVERT(datetime,@FROM_DATE,103),112)
        			END
        		ELSE
        			BEGIN
        				SELECT @l_fromDate = @FROM_DATE
        			END
        	END
        
        --Check the in parameter @TO_DATE is null
        -- If null get tomorrow date in the format yyyymmdd
        IF @TO_DATE IS NULL OR @TO_DATE = ''
        	BEGIN
        		SELECT @l_toDate = convert(varchar,dateadd(dd,1,getdate()),112)
        	END
        ELSE
        	BEGIN        		
        		IF CHARINDEX('/',@TO_DATE) > 0
        			BEGIN
        				SELECT @l_toDate = convert(varchar,CONVERT(datetime,@TO_DATE,103),112)
        			END
        		ELSE
        			BEGIN
        				SELECT @l_toDate = @TO_DATE
        			END        		
        	END      
        	
        --Declare variables
    	declare @iNextRowId 			int,
    			@iCurrentRowId			int,
    			@iLoopControl			int,        	
				@INS_ERR_CODE 			int, 
				@INS_ROW_COUNT 			int,
				@INS_ERR_MSG			varchar(1000),
				@FidessaID				varchar(50),
				@PrevFidessaID			varchar(50),
				@AccountMgr 			varchar(30),
				@AccountMgrs 			varchar(1000),
				@rec_count				int
			
		-- set the variables with default values
		select @INS_ERR_CODE = 0, @INS_ROW_COUNT = 0, @iNextRowId = 0, @iCurrentRowId = 0,@iLoopControl = 1 
		select @INS_ERR_MSG = NULL
		
		/*****************************************************************************
		--Step 1 : Insert all the account managers into #accntMgrsTmp for processing.
		--Step 2 : Process all the records from the temp table and insert the processed
		--		   records into the temp table #accntMgrs for execution.
		*****************************************************************************/
							
        --Create temp tables #accntMgrsTmp,#accntMgrs to process the Account managers
		CREATE TABLE #accntMgrsTmp
		(	Sno      int         			IDENTITY,
    		FidessaID 		varchar(50)		NULL,
    		AccountManager	varchar(30) 	NULL
		)      
		
		CREATE TABLE #accntMgrs
		(	
			FidessaID 		varchar(50)		NULL,
    		AccountManagers	varchar(1000) 	NULL
		)  		     

        --Insert the Account managers in the temp table #accntMgrsTmp        
		INSERT INTO #accntMgrsTmp
		select C1.FidessaID,C1.AccManager 
		from CC_FIX_ACCOUNT_MANAGER C1
		group by C1.FidessaID
		order by C1.FidessaID
        
        -- Saving system global variables as the other operations will clear them
        select @INS_ERR_CODE=@@error, @INS_ROW_COUNT=@@rowcount        
   
        -- Rollback if any errors
        IF @INS_ERR_CODE = 0
			BEGIN
				IF @INS_ROW_COUNT = 0
					BEGIN
						select @INS_ERR_MSG = 'No Records to insert'
					END
				ELSE
					BEGIN
						select @INS_ERR_MSG = 'Records Inserted:' + convert(varchar,@INS_ROW_COUNT)
					END
					
                INSERT INTO CC_FIX_ORD_STAT_TRACKING
                VALUES
                  ('P_CLICONN_FX_ORDR_STAT_CNT_REP',
                  getdate(),
                   'INFO',
                   @INS_ERR_MSG,
                   'S',
                   @REPORT_ID,
                   null,
                   null,
                   null)   	  			
     		END    
     	ELSE      
     		BEGIN
     			select @INS_ERR_MSG = description from master.dbo.sysmessages where error = @INS_ERR_CODE
     			
                INSERT INTO CC_FIX_ORD_STAT_TRACKING
                VALUES
                  ('P_CLICONN_FX_ORDR_STAT_CNT_REP',
                  getdate(),
                   'ERROR',
                   'Insert failed.',
                   'F',
                   @REPORT_ID,
                   convert(varchar, @INS_ERR_CODE),
                   null,
                   @INS_ERR_MSG)   	     		
     		END
	
        --Process the Account managers and group it by Fidessa ID
		IF (@INS_ROW_COUNT > 0)
			BEGIN   
        		--get the first rowid
        		SELECT   @iNextRowId = MIN(Sno)
        		FROM     #accntMgrsTmp	      
        		
   				-- Retrieve the first row
				SELECT  @iCurrentRowId  = Sno,
						@FidessaID		= FidessaID,
						@AccountMgr 	= AccountManager
				FROM    #accntMgrsTmp
				WHERE   Sno = @iNextRowId        
				
				select @PrevFidessaID = @FidessaID   	
				select @AccountMgrs = @AccountMgr
				select @rec_count = 1
				
				--Insert a record in the #accntMgrs temp table
				insert into #accntMgrs values(@FidessaID,@AccountMgr)	
				
				-- start the main processing loop.
				WHILE @iLoopControl = 1	
					BEGIN
						-- Reset looping variables
						SELECT  @iNextRowId = NULL  
						
						-- get the next iRowId 
            			SELECT   @iNextRowId = MIN(Sno)
            			FROM     #accntMgrsTmp
            			WHERE    Sno > @iCurrentRowId	
            			
            			-- did we get a valid next row id?
            			IF ISNULL(@iNextRowId,0) = 0
            				BEGIN
            					BREAK
            				END
            				
            			-- get the next row.
						SELECT  @iCurrentRowId  = Sno,
								@FidessaID		= FidessaID,
								@AccountMgr 	= AccountManager
						FROM    #accntMgrsTmp
						WHERE   Sno = @iNextRowId     
						
						IF 	@PrevFidessaID = @FidessaID 
							BEGIN		
								--Add the new account manager to the account managers list		
								IF CHARINDEX(@AccountMgr,@AccountMgrs) = 0
									BEGIN			
										IF @rec_count = 5
											BEGIN										
												select @AccountMgrs = @AccountMgrs+' / '+char(10)+@AccountMgr
												select @rec_count = 0
											END
										ELSE
											BEGIN
												select @AccountMgrs = @AccountMgrs+' / '+@AccountMgr													
											END
										select @rec_count = @rec_count +1
									END								
							END
						ELSE
							BEGIN
							   --Update the previous record
							   update #accntMgrs set AccountManagers = @AccountMgrs
							   where FidessaID = @PrevFidessaID		
							   	
							   	-- Reset the values					
								select @PrevFidessaID = @FidessaID   	
								select @AccountMgrs = @AccountMgr
								select @rec_count = 1
								
								--Insert a record in the #accntMgrs temp table
								insert into #accntMgrs values(@FidessaID,@AccountMgr)									
							END		
					END	--End of while loop
					
					--Update the last record
					update #accntMgrs set AccountManagers = @AccountMgrs
					where FidessaID = @PrevFidessaID		
								
			END -- End of processing the Account managers         
   
		
		declare @MAIN_SLCT_CLAUSE 		VARCHAR(600),
				@TBL1_SLCT_CLAUSE 		VARCHAR(900),
				@TBL1_FROM_CLAUSE 		VARCHAR(100),
				@TBL1_WHERE_CLAUSE 		VARCHAR(600),
				@TBL1_GROUPBY_CLAUSE	VARCHAR(120),
				@T1						VARCHAR(10),
				@JOIN					VARCHAR(20),	
				@TBL_ORD_STAT			VARCHAR(500),
				@TBL_ORD_ARCHIVE 		VARCHAR(500),	
				@TBL_ORD_STAT_ARCHIVE	VARCHAR(1000),		
				@TBL2_SLCT_CLAUSE 		VARCHAR(100),
				@TBL2_FROM_CLAUSE 		VARCHAR(100),
				@TBL2_WHERE_CLAUSE 		VARCHAR(100),
				@TBL2_GROUPBY_CLAUSE	VARCHAR(100),
				@T2						VARCHAR(10),
				@JOIN_COND				VARCHAR(70),
				@MAIN_ORDER_BY			VARCHAR(50),
				@MAIN_WHERE_CLAUSE		VARCHAR(100),
				@PARAMETER_STR 			VARCHAR(1000),
				@SPLITSTRING 			VARCHAR(100),
        		@KEYSTRING 				VARCHAR(100),
        		@VALSTRING 				VARCHAR(100),
        		@OUTSTRING				VARCHAR(1000),
        		@RETCODE				INT,
        		@RETMSG					VARCHAR(255)
        		
        --Modified by Akhil on 09 Oct 2008 inorder to acces the archive table if current date  >  from date
 /*       IF convert(datetime,convert(varchar,getdate(),103),103) > CONVERT(datetime,@FROM_DATE,103)
        	BEGIN
        		SELECT @TBL2_FROM_CLAUSE   = " FROM CC_FIX_ORDER_STAT_ARCHIVE"
        	END
       	ELSE
       		BEGIN
       			SELECT @TBL2_FROM_CLAUSE   = " FROM CC_FIX_ORDER_STAT"
       		END        		
*/				
		SELECT  @PARAMETER_STR = @INPARAMS				
				
		SELECT 	@MAIN_SLCT_CLAUSE = "SELECT  DISTINCT T1.[Client] 'Client Name'"+			
									",T1.[ClientID] 'FIX Client CompID'"+	
									",CASE"+
									" WHEN T2.[NoOfOrders]=NULL THEN"+
									" 0"+
									" ELSE"+
									" CASE"+
									" WHEN (T1.[ClientID]=T2.[ClientID] AND (T2.[SessID] = T1.[SessID] OR T2.[SessID] = T1.[ClientID]))  THEN"+
									" T2.[NoOfOrders]"+
									" ELSE"+
									" 0"+
									" END"+
									" END 'Number Of FIX Orders'"+
									",T1.[ConnectivityFee] 'FIX COnnectivity Fee'"+
									",T1.[Satatus] 'Connection Status'"+
									",T1.[OmsProduct] 'OMS Product'"+
									",T1.[NetworkProduct] 'Network Product'"+
									",ISNULL(T1.[AccountManager/s],'N/A') 'AccountManager/s'"+
									" FROM ("
				
		SELECT 	@TBL1_SLCT_CLAUSE = "SELECT CON.CLIENT_NAME 'Client',"+
									"MAP.COMP_ID 'ClientID',"+
									"CON.COMP_ID 'SessID',"+
									"CON.FIDESSA_ID 'FidessaID',"+
									"CASE"+
									" WHEN CON.ACTIVE = 1 THEN"+
									" 'Active'"+
									" ELSE"+
									" 'InActive'"+
									" END 'Satatus',"+
									"CASE"+
									" WHEN CON.OMS_PRODUCT_ID = 0 THEN"+
									" 'UNDEFINED'"+
									" ELSE"+
									" (SELECT PRODUCT_NAME FROM CC_PRODUCT WHERE PRODUCT_ID = CON.OMS_PRODUCT_ID)"+
									" END 'OmsProduct',"+
									" CASE"+
									" WHEN CON.NETWORK_PRODUCT_ID = 0 THEN"+
									" 'UNDEFINED'"+
									" ELSE"+
									" (SELECT PRODUCT_NAME FROM CC_PRODUCT WHERE PRODUCT_ID = CON.NETWORK_PRODUCT_ID)"+
									" END 'NetworkProduct',"+
									" (Select AccountManagers from #accntMgrs where FidessaID = CON.FIDESSA_ID) 'AccountManager/s',"+
									" 0 'ConnectivityFee'"
		SELECT 	@TBL1_FROM_CLAUSE   = " FROM V_CLICONN_CONNECTION CON, CC_FIXTAGMAPPING MAP"
		SELECT  @TBL1_WHERE_CLAUSE  = " WHERE (CON.CONNECTION_ID = MAP.CONNECTION_ID OR CON.COMP_ID = MAP.COMP_ID)"+
									  " AND MAP.FIX_TAG_TYPE='COMP_ID'"+
									  " AND CON.CREATED_DATETIME =(SELECT MAX(CREATED_DATETIME) FROM V_CLICONN_CONNECTION"+
									  " WHERE COMP_ID=CON.COMP_ID"+
									  " AND FIDESSA_ID=CON.FIDESSA_ID)"
		SELECT @TBL1_GROUPBY_CLAUSE = "	GROUP BY CON.CLIENT_NAME,CON.COMP_ID,MAP.COMP_ID,CON.FIDESSA_ID,CON.ACTIVE,CON.OMS_PRODUCT_ID,CON.NETWORK_PRODUCT_ID"	
		
		SELECT @T1					= ") T1"
		SELECT @JOIN				= " LEFT JOIN("		
		/*	
		SELECT @TBL2_SLCT_CLAUSE	= "SELECT ClientID 'ClientID',"+
									  "SessID  'SessID',"+
									  "count(*) 'NoOfOrders'"
		--SELECT @TBL2_FROM_CLAUSE	= " FROM CC_FIX_ORDER_STAT"									  
		SELECT @TBL2_WHERE_CLAUSE	= "	WHERE OrderIncomeDate > '"+@l_fromDate+"'"+
									  "	AND OrderIncomeDate < '"+@l_toDate+"'"
		SELECT @TBL2_GROUPBY_CLAUSE	= " GROUP BY ClientID,SessID"
		*/
		--Changes done on 13 Oct 2008 by Akhil - Begin
        SELECT @TBL_ORD_STAT_ARCHIVE	= "select T1.[ClientID] 'ClientID',T1.[SessID] 'SessID',sum(T1.[NoOfOrders]) 'NoOfOrders'"+
        							  " from"+
        								"("+
        								"SELECT ClientID 'ClientID',SessID  'SessID',count(*) 'NoOfOrders' "+
        								" FROM CC_FIX_ORDER_STAT_ARCHIVE"+
        								" WHERE OrderIncomeDate > '"+@l_fromDate+"'"+
        								" AND OrderIncomeDate < '"+@l_toDate+"'"+
        								" GROUP BY ClientID,SessID"+
        								" UNION "+
        								"SELECT ClientID 'ClientID',SessID  'SessID',count(*) 'NoOfOrders'"+ 
        								" FROM CC_FIX_ORDER_STAT"+
        								" WHERE OrderIncomeDate > '"+@l_fromDate+"'"+
        								" AND OrderIncomeDate < '"+@l_toDate+"'"+
        								" GROUP BY ClientID,SessID"+     
        								") T1"+
        								" group by T1.[ClientID],T1.[SessID]"		
		--Changes done on 13 Oct 2008 by Akhil - End        								
		SELECT @T2				    = ") T2"
		SELECT @JOIN_COND			= " ON T1.[ClientID] = T2.[ClientID] AND T1.[SessID] = T2.[SessID]"
		SELECT @MAIN_WHERE_CLAUSE	= ""		
		SELECT @MAIN_ORDER_BY		= " ORDER BY T2.[NoOfOrders]"

		
        WHILE LEN(@PARAMETER_STR) >0
        BEGIN
        	IF (CHARINDEX(',',@PARAMETER_STR) != 0)
        		BEGIN
        			SELECT @SPLITSTRING= SUBSTRING(@PARAMETER_STR,1,CHARINDEX(',',@PARAMETER_STR)-1 )
        			SELECT @PARAMETER_STR = SUBSTRING(@PARAMETER_STR,LEN(@SPLITSTRING)+2,LEN(@PARAMETER_STR))
        		END
        	ELSE
				BEGIN
					SELECT @SPLITSTRING = @PARAMETER_STR
					SELECT @PARAMETER_STR =NULL
				END    
				
        	IF (CHARINDEX('=',@SPLITSTRING) > 0)
        	BEGIN
				
        		SELECT @KEYSTRING = SUBSTRING(@SPLITSTRING,1,CHARINDEX('=',@SPLITSTRING)-1 )
        		SELECT @VALSTRING = SUBSTRING(@SPLITSTRING,LEN(@KEYSTRING)+2,LEN(@SPLITSTRING))
        		
       			IF @KEYSTRING = "Client Name" -- OK
       				BEGIN
       					EXEC P_CLICONN_REPORTS_VALIDATION 'STAR_MOD', @VALSTRING, @OUTSTRING OUTPUT, @RETCODE OUTPUT, @RETMSG OUTPUT
       					IF @RETCODE = 0
       						BEGIN
       							SELECT @TBL1_WHERE_CLAUSE = @TBL1_WHERE_CLAUSE + " AND UPPER(CON.CLIENT_NAME) LIKE '"+ UPPER(@OUTSTRING) + "'"
       						END
       					ELSE
       						BEGIN
       							SELECT @RETURN_CODE = @RETCODE
       							SELECT @RETURN_MSG  = @RETMSG
       							RETURN
       						END       						
       				END      
       			ELSE IF @KEYSTRING = "Comp ID/FIX Tag" -- OK
       				BEGIN
       					EXEC P_CLICONN_REPORTS_VALIDATION 'STAR_MOD', @VALSTRING, @OUTSTRING OUTPUT, @RETCODE OUTPUT, @RETMSG OUTPUT
       					IF @RETCODE = 0
       						BEGIN       				
       							SELECT @TBL1_WHERE_CLAUSE = @TBL1_WHERE_CLAUSE + " AND UPPER(MAP.COMP_ID) LIKE '"+ UPPER(@OUTSTRING) + "'"
       						END
       					ELSE
       						BEGIN
       							SELECT @RETURN_CODE = @RETCODE
       							SELECT @RETURN_MSG  = @RETMSG
       							RETURN
       						END       						
       				END        	
       			ELSE IF @KEYSTRING = "Fidessa ID" -- PENDING
       				BEGIN
       					EXEC P_CLICONN_REPORTS_VALIDATION 'STAR_MOD', @VALSTRING, @OUTSTRING OUTPUT, @RETCODE OUTPUT, @RETMSG OUTPUT
       					IF @RETCODE = 0
       						BEGIN         				
      							SELECT @TBL1_WHERE_CLAUSE = @TBL1_WHERE_CLAUSE + " AND UPPER(CON.FIDESSA_ID) LIKE '"+ UPPER(@OUTSTRING) + "'"
       						END
       					ELSE
       						BEGIN
       							SELECT @RETURN_CODE = @RETCODE
       							SELECT @RETURN_MSG  = @RETMSG
       							RETURN
       						END       						
       				END       
       			ELSE IF @KEYSTRING = "OMS Product" -- OK
       				BEGIN
       					SELECT @TBL1_WHERE_CLAUSE = @TBL1_WHERE_CLAUSE + " AND CON.OMS_PRODUCT_ID="+ @VALSTRING     					
       				END         
       			ELSE IF @KEYSTRING = "Network Product" -- OK
       				BEGIN
       					SELECT @TBL1_WHERE_CLAUSE = @TBL1_WHERE_CLAUSE + " AND CON.NETWORK_PRODUCT_ID="+ @VALSTRING     					
       				END   
       			ELSE IF @KEYSTRING = "Account Manager" -- OK
       				BEGIN
       					EXEC P_CLICONN_REPORTS_VALIDATION 'STAR_MOD', @VALSTRING, @OUTSTRING OUTPUT, @RETCODE OUTPUT, @RETMSG OUTPUT
       					IF @RETCODE = 0
       						BEGIN
       							SELECT @MAIN_WHERE_CLAUSE = @MAIN_WHERE_CLAUSE + " WHERE UPPER(T1.[AccountManager/s]) LIKE '"+ UPPER(@OUTSTRING) + "'"
       						END
       					ELSE
       						BEGIN
       							SELECT @RETURN_CODE = @RETCODE
       							SELECT @RETURN_MSG  = @RETMSG
       							RETURN
       						END       						
       				END          				       								 							  		
        	END	
		END	-- End of while loop	
		--INSERT INTO CC_TEST VALUES(@MAIN_SLCT_CLAUSE+@TBL1_SLCT_CLAUSE+@TBL1_FROM_CLAUSE+@TBL1_WHERE_CLAUSE+@TBL1_GROUPBY_CLAUSE+@T1+@JOIN+@TBL_ORD_STAT_ARCHIVE+@T2+@JOIN_COND+@MAIN_WHERE_CLAUSE+@MAIN_ORDER_BY)				
		EXEC (@MAIN_SLCT_CLAUSE+@TBL1_SLCT_CLAUSE+@TBL1_FROM_CLAUSE+@TBL1_WHERE_CLAUSE+@TBL1_GROUPBY_CLAUSE+@T1+@JOIN+@TBL_ORD_STAT_ARCHIVE+@T2+@JOIN_COND+@MAIN_WHERE_CLAUSE+@MAIN_ORDER_BY)
		
		select @ERRORCODE = @@ERROR

		IF @ERRORCODE != 0
   			BEGIN
   				select @ERRORMSG = description from master.dbo.sysmessages where error = @ERRORCODE
   				
                INSERT INTO CC_FIX_ORD_STAT_TRACKING
                VALUES
                  ('P_CLICONN_FX_ORDR_STAT_CNT_REP',
                   getdate(),
                   'ERROR',
                   'Execution of FIX Order Statistics failed for period :'+@l_fromDate+' To '+@l_toDate,
                   'F',
                   @REPORT_ID,
                   convert(varchar, @ERRORCODE),
                   null,
                   @ERRORMSG)  
                      			
   				SELECT @RETURN_MSG = 'P_CLICONN_FX_ORDR_STAT_CNT_REP - Execution of FIX Order Statistics failed.'
   				SELECT @RETURN_CODE = @ERRORCODE
   				return
     		END 	
     	ELSE
     		BEGIN
                INSERT INTO CC_FIX_ORD_STAT_TRACKING
                VALUES
                  ('P_CLICONN_FX_ORDR_STAT_CNT_REP',
                   getdate(),
                   'INFO',
                   'Execution of FIX Order Statistics Success for period :'+@l_fromDate+' To '+@l_toDate,
                   'S',
                   @REPORT_ID,
                   null,
                   null,
                   null)       		
     		END			
	 		
        --Drop the temp tables #ordrStatTmp, #ordrStat
		drop table #accntMgrsTmp
		drop table #accntMgrs
    END

