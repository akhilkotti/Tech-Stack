/*****************************************************************************************
-- +=====================================================================================+
-- |                         Macquarie (Hong Kong)                                       |
-- +=====================================================================================+
-- |                                                                                     |
-- |Application Name   :  Daily Commission Report                                        |
-- |Object Name        :  mq_rSP_Daily_Commission_report.sql                             |
-- |Author Name        :  Akhil benarji                                                  |
-- |Date of Creation   :  12 September, 2008                                             |
-- |Description        :  Procedure to get the daily commission report.                  |
-- |                      This procedure will get the COMMISSION rates for all the client|
-- |                      on that particular day. This procedure can also be run for the |
-- |                      given dates by the user. Apart from getting the commission     |
-- |                      this procedure also helps the data to be displayed in a table  |
-- |                      format.                                                        |
-- |Usage:-                                                                              |
-- |    	- This procedure will be called from the ClicOnn Web application.            |                                                                                   
-- |        - This procedure can also be run as a standalone application                 |
-- |                                                                                     |
-- |                                                                                     |
-- |Revision History   :                                                                 |
-- |-------------------------------------------------------------------------------------|
-- |Rno        Date Changed           Changed By        Change Details                   |
-- |-------------------------------------------------------------------------------------|
-- |1.0        12 Sep 2008            Akhil benarji.    Initial Creation                 |
-- |                                                                                     |
-- |-------------------------------------------------------------------------------------|
*****************************************************************************************/ 
CREATE PROCEDURE dbo.mq_rSP_Daily_Commission_report
		@From_Date		varchar(8) = NULL,
		@To_Date		varchar(8) = NULL
AS
    BEGIN
    	-- Declare Variables
    	DECLARE @From_Date_l	varchar(8),
    			@To_Date_l		varchar(8),
    			@ViewCode		varchar(30),
    			@CDBOID   		varchar(30),
    			@MarketID  		varchar(15),
    			@AUS      		float,
    			@NZD      		float,
    			@HKG      		float,
    			@IND      		float,
    			@IDR      		float,
    			@KRW      		float,
    			@MYR      		float,
    			@PHI      		float,
    			@SGD      		float,
    			@THD      		float,
    			@TW       		float,
    			@JP       		float,
    			@AUS_Last      		float,
    			@NZD_Last      		float,
    			@HKG_Last      		float,
    			@IND_Last      		float,
    			@IDR_Last      		float,
    			@KRW_Last      		float,
    			@MYR_Last      		float,
    			@PHI_Last      		float,
    			@SGD_Last      		float,
    			@THD_Last      		float,
    			@TW_Last       		float,
    			@JP_Last       		float 
    	
    	IF @From_Date IS NULL or @From_Date = ''
    		BEGIN
    			SELECT @From_Date_l = convert(varchar,getdate(),112)
    		END
    	ELSE
    		BEGIN
    			SELECT @From_Date_l = @From_Date
    		END
    		
    	IF @To_Date IS NULL or @To_Date = ''
    		BEGIN
    			SELECT @To_Date_l = convert(varchar,dateadd(dd,1,getdate()),112)
    		END
    	ELSE
    		BEGIN
    			SELECT @To_Date_l = @To_Date
    		END    	
    		
    	-- Initialize the Variables
    	SELECT @ViewCode = ''
    	SELECT @CDBOID = ''
    	SELECT @MarketID = ''    	
    	SELECT @AUS = null
    	SELECT @NZD = null
    	SELECT @HKG = null
    	SELECT @IND = null
    	SELECT @IDR = null
    	SELECT @KRW = null
    	SELECT @MYR = null
    	SELECT @PHI = null
    	SELECT @SGD = null
    	SELECT @THD = null
    	SELECT @TW = null
    	SELECT @JP = null
    	
		CREATE TABLE #comm_rep_tmp
		(	
    		Sno      int         IDENTITY,
    		ViewCode varchar(30) NULL,
    		CDBOID   varchar(30) NULL,
    		MarketID varchar(15) NULL,
    		AUS      float       NULL,
    		NZD      float       NULL,
    		HKG      float       NULL,
    		IND      float       NULL,
    		IDR      float       NULL,
    		KRW      float       NULL,
    		MYR      float       NULL,
    		PHI      float       NULL,
    		SGD      float       NULL,
    		THD      float       NULL,
    		TW       float       NULL,
    		JP       float       NULL
		)    
			
		CREATE TABLE #comm_rep
		(	
			Sno      int         NULL,
    		ViewCode varchar(30) NULL,
    		CDBOID   varchar(30) NULL,
    		AUS      float       NULL,
    		NZD      float       NULL,
    		HKG      float       NULL,
    		IND      float       NULL,
    		IDR      float       NULL,
    		KRW      float       NULL,
    		MYR      float       NULL,
    		PHI      float       NULL,
    		SGD      float       NULL,
    		THD      float       NULL,
    		TW       float       NULL,
    		JP       float       NULL
		) 		
		
		CREATE TABLE #error_tab
		(	
    		err_msg 		varchar(1000) NULL
		) 
    	
		INSERT INTO #comm_rep_tmp
        SELECT distinct 
               TBO.CL_COUNTERPARTY_CODE "View Code",
               (SELECT ACP2.COUNTERPARTY_CODE
                  FROM COUNTERPARTY CP, ALT_COUNTERPARTY_ID ACP2
                 WHERE CP.COUNTERPARTY_ID = ACP2.COUNTERPARTY_ID
                   AND CP.COUNTERPARTY_ID = TBO.CL_COUNTERPARTY_ID
                   AND CP.COUNTERPARTY_TYPE = 'C'
                   AND CP.STATUS = 'A'
                   AND ACP2.COUNTERPARTY_CODE IS NOT NULL
                   AND ACP2.ALTERNATE_TYPE = 'CDBO') "CDBOID",    
                   TBO.MARKET_ID,               
                   CASE
                   WHEN TBO.MARKET_ID IN('ASX-ITS') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "AU",
                   CASE
                   WHEN TBO.MARKET_ID IN('NZE-MAIN') THEN
                     TBO.CL_COMMISSION_PARAM 
                   END "NZ" ,   
                   CASE
                   WHEN TBO.MARKET_ID IN('HKD-ETS', 'HKG-GEM', 'HKG-MAIN', 'HKG-NASD') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "HK",   
                   CASE
                   WHEN TBO.MARKET_ID IN('BSE-MAIN', 'NSI-MAIN') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "IN",    
                   CASE
                   WHEN TBO.MARKET_ID IN('JKT-MAIN') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "IDR",   
                   CASE
                   WHEN TBO.MARKET_ID IN('KSQ-MAIN', 'KSC-MAIN', 'SEO-MAIN') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "KR",        
                   CASE
                   WHEN TBO.MARKET_ID IN('KLS-MAIN') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "MYR",      
                   CASE
                   WHEN TBO.MARKET_ID IN('MNL-MAIN') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "PH",    
                   CASE
                   WHEN TBO.MARKET_ID IN('SES-MAIN','SES-ODD') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "SG", 
                   CASE
                   WHEN TBO.MARKET_ID IN('BKK-MAIN') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "TH",   
                   CASE
                   WHEN TBO.MARKET_ID IN('TAI-MAIN','TOC-MAIN') THEN
                     TBO.CL_COMMISSION_PARAM
                   END "TW",                                                                                                                                            
                   CASE
                   WHEN TBO.MARKET_ID IN('JSD-MAIN', 'JSD-OTS', 'OSA-MAIN', 'TYO-MAIN') THEN
                     TBO.CL_COMMISSION_PARAM 
                   END "JP"                                                      
          FROM TB_ORDER TBO, TB_CURRENT_ORDER TCO, TB_ORDER_DETAIL TOD
         WHERE TBO.CL_ORDER_ID = TCO.CL_ORDER_ID
           AND TCO.CL_ORDER_ID = TOD.CL_ORDER_ID
           AND TBO.CL_VERSION = TCO.CL_VERSION
           AND TBO.CL_COUNTERPARTY_ID IS NOT NULL
           AND TBO.CL_COMMISSION_BASIS = 'BASI'
           AND EXISTS (SELECT 1 FROM TB_ORDER,COUNTERPARTY C1
                        WHERE CL_ORDER_ID = TBO.CL_ORDER_ID
                        AND CL_COUNTERPARTY_ID = C1.COUNTERPARTY_ID
                        AND CL_COUNTERPARTY_ID = (SELECT Z1.CL_COUNTERPARTY_ID 
                                                 FROM TB_ORDER Z1,TB_CURRENT_ORDER Z2 
                                                 WHERE Z1.CL_ORDER_ID = Z2.CL_ORDER_ID 
                                                 AND Z1.CL_VERSION = Z2.CL_VERSION 
                                                 AND Z1.CL_ORDER_ID = TBO.CL_ORDER_ID)                        
                        AND (CL_ENTERED_BY LIKE '%_PT' OR CL_ENTERED_BY LIKE 'PT.%'))  
           AND TBO.CL_COMMISSION_PARAM > 0
           AND TOD.CL_QUANTITY_FILLED > 0
           AND TBO.CL_ENTERED_DATETIME > @From_Date_l--'20080820'
           AND TBO.CL_ENTERED_DATETIME < @To_Date_l--'20080820'
           ORDER BY TBO.CL_COUNTERPARTY_CODE, TBO.MARKET_ID
               	
    	
    	declare @iNextRowId 			int,
    			@iCurrentRowId			int,
    			@iLoopControl			int,
    			@PrevViewCode 			varchar(30),
    			@iReturnMsg				varchar(100),
    			@rowid					varchar(20),
    			@rowid_new				int,
    			@rec_count				int,
    			@row_count				int,
    			@next_placeholder		int
    			
		-- Initialize variables!
		SELECT @iLoopControl = 1    	
		SELECT @rowid_new = 1		
    	
        SELECT   @iNextRowId = MIN(Sno)
        FROM     #comm_rep_tmp
        
        select @rowid = convert(varchar,@iNextRowId)
        --print @rowid
        
		-- Make sure the table has data.
		IF ISNULL(@iNextRowId,0) = 0
   			BEGIN
            	SELECT @iReturnMsg = 'Query returned no records for the period '+@From_Date+' to '+@To_Date
            
            	-- Insert error message in the error table
            	insert into #error_tab values(@iReturnMsg)            
            
   			END    
   		ELSE
   			BEGIN   
   		
   				-- Retrieve the first row
				SELECT  @iCurrentRowId  = Sno,
						@ViewCode		= ViewCode,
						@CDBOID			= CDBOID,
						@MarketID		= MarketID,
						@AUS			= AUS,
						@NZD			= NZD,
						@HKG			= HKG,
						@IND			= IND,
						@IDR			= IDR,
						@KRW			= KRW,
						@MYR			= MYR,
						@PHI			= PHI,
						@SGD			= SGD,
						@THD			= THD,
						@TW				= TW,
						@JP				= JP
				FROM    #comm_rep_tmp
				WHERE   Sno = @iNextRowId
				
				select @PrevViewCode = @ViewCode		
				insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
				SELECT @row_count = 1
		
    			SELECT @AUS_Last = @AUS
    			SELECT @NZD_Last = @NZD
    			SELECT @HKG_Last = @HKG
    			SELECT @IND_Last = @IND
    			SELECT @IDR_Last = @IDR
    			SELECT @KRW_Last = @KRW
    			SELECT @MYR_Last = @MYR
    			SELECT @PHI_Last = @PHI
    			SELECT @SGD_Last = @SGD
    			SELECT @THD_Last = @THD
    			SELECT @TW_Last  = @TW
    			SELECT @JP_Last  = @JP
	    							
				-- start the main processing loop.
				WHILE @iLoopControl = 1			
					BEGIN
						-- Reset looping variables
						SELECT  @iNextRowId = NULL  
						SELECT 	@rec_count = NULL
						SELECT	@next_placeholder = NULL
						
						-- get the next iRowId 
            			SELECT   @iNextRowId = MIN(Sno)
            			FROM     #comm_rep_tmp
            			WHERE    Sno > @iCurrentRowId		
            			
        				select @rowid = convert(varchar,@iNextRowId)
        				--print @rowid
            			
            			-- did we get a valid next row id?
            			IF ISNULL(@iNextRowId,0) = 0
            				BEGIN
            					BREAK
            				END
            			
            			-- get the next row.
						SELECT  @iCurrentRowId  = Sno,
								@ViewCode		= ViewCode,
								@CDBOID			= CDBOID,
								@MarketID		= MarketID,
								@AUS			= AUS,
								@NZD			= NZD,
								@HKG			= HKG,
								@IND			= IND,
								@IDR			= IDR,
								@KRW			= KRW,
								@MYR			= MYR,
								@PHI			= PHI,
								@SGD			= SGD,
								@THD			= THD,
								@TW				= TW,
								@JP				= JP
						FROM    #comm_rep_tmp
						WHERE   Sno = @iNextRowId	
						
						IF @PrevViewCode = @ViewCode
							BEGIN
								IF @MarketID IN('ASX-ITS') -- Australian Market
									BEGIN
										IF @AUS_Last IS NULL OR @AUS_Last = @AUS
											BEGIN
												IF @row_count > 1 AND @AUS_Last IS NULL
													BEGIN
														SELECT @AUS_Last = @AUS
														UPDATE #comm_rep SET AUS = @AUS WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @AUS_Last = @AUS
														UPDATE #comm_rep SET AUS = @AUS WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and AUS = @AUS
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = AUS from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @AUS_Last = @AUS
																UPDATE #comm_rep SET AUS = @AUS WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @AUS_Last = @AUS
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END										
													END							
											END 							
									END
								ELSE IF @MarketID IN('NZE-MAIN') -- Newzeland Market
									BEGIN
										IF @NZD_Last IS NULL OR @NZD_Last = @NZD
											BEGIN
												IF @row_count > 1 AND @NZD_Last IS NULL
													BEGIN
														SELECT @NZD_Last = @NZD
														UPDATE #comm_rep SET NZD = @NZD WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @NZD_Last = @NZD
														UPDATE #comm_rep SET NZD = @NZD WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and NZD = @NZD
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = NZD from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @NZD_Last = @NZD
																UPDATE #comm_rep SET NZD = @NZD WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @NZD_Last = @NZD
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END										
													END									
											END 							
									END
								ELSE IF @MarketID IN('HKD-ETS', 'HKG-GEM', 'HKG-MAIN', 'HKG-NASD') -- Hong Kong Market
									BEGIN
										IF @HKG_Last IS NULL OR @HKG_Last = @HKG
											BEGIN
												IF @row_count > 1 AND @HKG_Last IS NULL
													BEGIN
														SELECT @HKG_Last = @HKG
														UPDATE #comm_rep SET HKG = @HKG WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @HKG_Last = @HKG
														UPDATE #comm_rep SET HKG = @HKG WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and HKG = @HKG
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = HKG from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @HKG_Last = @HKG
																UPDATE #comm_rep SET HKG = @HKG WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @HKG_Last = @HKG
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END									
													END								
											END 							
									END
								ELSE IF @MarketID IN('BSE-MAIN', 'NSI-MAIN') -- Indian Market
									BEGIN
										IF @IND_Last IS NULL OR @IND_Last = @IND
											BEGIN
												IF @row_count > 1 AND @IND_Last IS NULL
													BEGIN
														SELECT @IND_Last = @IND
														UPDATE #comm_rep SET IND = @IND WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @IND_Last = @IND
														UPDATE #comm_rep SET IND = @IND WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and IND = @IND
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = IND from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @IND_Last = @IND
																UPDATE #comm_rep SET IND = @IND WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @IND_Last = @IND
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END										
													END									
											END 							
									END
								ELSE IF @MarketID IN('JKT-MAIN') -- Indonesia Market
									BEGIN
										IF @IDR_Last IS NULL OR @IDR_Last = @IDR
											BEGIN
												IF @row_count > 1 AND @IDR_Last IS NULL
													BEGIN
														SELECT @IDR_Last = @IDR
														UPDATE #comm_rep SET IDR = @IDR WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @IDR_Last = @IDR
														UPDATE #comm_rep SET IDR = @IDR WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and IDR = @IDR
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = IDR from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @IDR_Last = @IDR
																UPDATE #comm_rep SET IDR = @IDR WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @IDR_Last = @IDR
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END									
													END									
											END 							
									END
								ELSE IF @MarketID IN('KSQ-MAIN', 'KSC-MAIN', 'SEO-MAIN') -- Korea Market
									BEGIN
										IF @KRW_Last IS NULL OR @KRW_Last = @KRW
											BEGIN
												IF @row_count > 1 AND @KRW_Last IS NULL
													BEGIN
														SELECT @KRW_Last = @KRW
														UPDATE #comm_rep SET KRW = @KRW WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @KRW_Last = @KRW
														UPDATE #comm_rep SET KRW = @KRW WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and KRW = @KRW
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = KRW from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @KRW_Last = @KRW
																UPDATE #comm_rep SET KRW = @KRW WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @KRW_Last = @KRW
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END									
													END									
											END 
									END
								ELSE IF @MarketID IN('KLS-MAIN') -- Malaysia Market
									BEGIN
										IF @MYR_Last IS NULL OR @MYR_Last = @MYR
											BEGIN
												IF @row_count > 1 AND @MYR_Last IS NULL
													BEGIN
														SELECT @MYR_Last = @MYR
														UPDATE #comm_rep SET MYR = @MYR WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @MYR_Last = @MYR
														UPDATE #comm_rep SET MYR = @MYR WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and MYR = @MYR
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = MYR from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @MYR_Last = @MYR
																UPDATE #comm_rep SET MYR = @MYR WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @MYR_Last = @MYR
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END									
													END									
											END 								
									END
								ELSE IF @MarketID IN('MNL-MAIN') -- Phillipines Market
									BEGIN
										IF @PHI_Last IS NULL OR @PHI_Last = @PHI
											BEGIN
												IF @row_count > 1 AND @PHI_Last IS NULL
													BEGIN
														SELECT @PHI_Last = @PHI
														UPDATE #comm_rep SET PHI = @PHI WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @PHI_Last = @PHI
														UPDATE #comm_rep SET PHI = @PHI WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and PHI = @PHI
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = PHI from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @PHI_Last = @PHI
																UPDATE #comm_rep SET PHI = @PHI WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @PHI_Last = @PHI
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END										
													END								
											END 							
									END
								ELSE IF @MarketID IN('SES-MAIN','SES-ODD') -- Sinagpore Market
									BEGIN
										IF @SGD_Last IS NULL OR @SGD_Last = @SGD
											BEGIN
												IF @row_count > 1 AND @SGD_Last IS NULL
													BEGIN
														SELECT @SGD_Last = @SGD
														UPDATE #comm_rep SET SGD = @SGD WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @SGD_Last = @SGD
														UPDATE #comm_rep SET SGD = @SGD WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and SGD = @SGD
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = SGD from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @SGD_Last = @SGD
																UPDATE #comm_rep SET SGD = @SGD WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @SGD_Last = @SGD
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END										
													END									
											END 							
									END
								ELSE IF @MarketID IN('BKK-MAIN') -- Thailand Market
									BEGIN
										IF @THD_Last IS NULL OR @THD_Last = @THD
											BEGIN
												IF @row_count > 1 AND @THD_Last IS NULL
													BEGIN
														SELECT @THD_Last = @THD
														UPDATE #comm_rep SET THD = @THD WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @THD_Last = @THD
														UPDATE #comm_rep SET THD = @THD WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and THD = @THD
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = THD from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @THD_Last = @THD
																UPDATE #comm_rep SET THD = @THD WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @THD_Last = @THD
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END										
													END								
											END 							
									END
								ELSE IF @MarketID IN('TAI-MAIN','TOC-MAIN') -- Taiwan Market
									BEGIN
										IF @TW_Last IS NULL OR @TW_Last = @TW
											BEGIN
												IF @row_count > 1 AND @TW_Last IS NULL
													BEGIN
														SELECT @TW_Last = @TW
														UPDATE #comm_rep SET TW = @TW WHERE Sno = (@rowid_new - 1)										
													END
												ELSE
													BEGIN
														SELECT @TW_Last = @TW
														UPDATE #comm_rep SET TW = @TW WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and TW = @TW
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = TW from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @TW_Last = @TW
																UPDATE #comm_rep SET TW = @TW WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @TW_Last = @TW
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1									
															END										
													END									
											END 							
									END
								ELSE IF @MarketID IN('JSD-MAIN', 'JSD-OTS', 'OSA-MAIN', 'TYO-MAIN') -- Japan Market 
									BEGIN
										IF @JP_Last IS NULL OR @JP_Last = @JP
											BEGIN
												IF @row_count > 1 AND @JP_Last IS NULL
													BEGIN
														SELECT @JP_Last = @JP
														UPDATE #comm_rep SET JP = @JP WHERE Sno = (@rowid_new - 1)											
													END
												ELSE
													BEGIN
														SELECT @JP_Last = @JP
														UPDATE #comm_rep SET JP = @JP WHERE Sno = @rowid_new
													END
											END
										ELSE
											BEGIN
												SELECT @rec_count = count(*) from #comm_rep where ViewCode = @ViewCode and CDBOID = @CDBOID and JP = @JP
												IF @rec_count = 0
													BEGIN
														IF @row_count > 1
															BEGIN
																SELECT @next_placeholder = JP from #comm_rep where Sno = @rowid_new
															END
															
														IF @next_placeholder IS NULL AND @row_count > 1
															BEGIN
																SELECT @JP_Last = @JP
																UPDATE #comm_rep SET JP = @JP WHERE Sno = @rowid_new
															END
														ELSE
															BEGIN
																SELECT @JP_Last = @JP
																SELECT @rowid_new = @rowid_new+1		
																insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)
																SELECT @row_count = @row_count + 1											
															END
													END
											END 							
									END
								ELSE
									BEGIN
										SELECT @iReturnMsg = 'Market ID - '+@MarketID+' not found for the Client - '+@ViewCode
										
										-- Insert error message in the error table
            							insert into #error_tab values(@iReturnMsg)
									END																																																																						
							END		
						ELSE
							BEGIN
								-- Initialize the values
								select @PrevViewCode = @ViewCode	
								
    							SELECT @AUS_Last = @AUS
    							SELECT @NZD_Last = @NZD
    							SELECT @HKG_Last = @HKG
    							SELECT @IND_Last = @IND
    							SELECT @IDR_Last = @IDR
    							SELECT @KRW_Last = @KRW
    							SELECT @MYR_Last = @MYR
    							SELECT @PHI_Last = @PHI
    							SELECT @SGD_Last = @SGD
    							SELECT @THD_Last = @THD
    							SELECT @TW_Last  = @TW
    							SELECT @JP_Last  = @JP						
								
								SELECT @rowid_new = @rowid_new+1	
								
								-- Insert a new record	
								insert into #comm_rep values(@rowid_new,@ViewCode,@CDBOID,@AUS,@NZD,@HKG,@IND,@IDR,@KRW,@MYR,@PHI,@SGD,@THD,@TW,@JP)		
								SELECT @row_count = 1						
								
							END
					END -- End of While loop
			END -- End of Else Condition

		select @row_count = NULL
		
		select @row_count = count(*) from #comm_rep
		
		IF @row_count > 0
			BEGIN		
				select  #comm_rep.ViewCode, 
						#comm_rep.CDBOID, 
						isnull(convert(varchar,#comm_rep.AUS),'') "AUS", 
						isnull(convert(varchar,#comm_rep.NZD),'') "NZD", 
						isnull(convert(varchar,#comm_rep.HKG),'') "HKG", 
						isnull(convert(varchar,#comm_rep.IND),'') "IND", 
						isnull(convert(varchar,#comm_rep.IDR),'') "IDR", 
						isnull(convert(varchar,#comm_rep.KRW),'') "KRW", 
						isnull(convert(varchar,#comm_rep.MYR),'') "MYR", 
						isnull(convert(varchar,#comm_rep.PHI),'') "PHI", 
						isnull(convert(varchar,#comm_rep.SGD),'') "SGD", 
						isnull(convert(varchar,#comm_rep.THD),'') "THD", 
						isnull(convert(varchar,#comm_rep.TW),'') "TW", 
						isnull(convert(varchar,#comm_rep.JP),'') "JP" 
				from #comm_rep
				order by #comm_rep.Sno
			END
			
		select @row_count = NULL		
		select @row_count = count(*) from #error_tab	
		IF @row_count > 0
			BEGIN		
				select  #error_tab.err_msg
				from #error_tab
			END				
		
		--Drop the temp tables
		drop table #comm_rep_tmp
		drop table #comm_rep
		drop table #error_tab
    END

