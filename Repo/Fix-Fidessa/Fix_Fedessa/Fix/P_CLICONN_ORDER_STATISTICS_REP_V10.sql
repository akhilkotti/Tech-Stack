IF OBJECT_ID('dbo.P_CLICONN_ORDER_STATISTICS_REP') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.P_CLICONN_ORDER_STATISTICS_REP
    IF OBJECT_ID('dbo.P_CLICONN_ORDER_STATISTICS_REP') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.P_CLICONN_ORDER_STATISTICS_REP >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.P_CLICONN_ORDER_STATISTICS_REP >>>'
END
go
/********************************************************************************************
-- +========================================================================================+
-- |                         Macquarie (Hong Kong)                                          |
-- +========================================================================================+
-- |                                                                                        |
-- |Application Name   :  Order report Statistics                                           |
-- |Object Name        :  P_CLICONN_ORDER_STATISTICS_REP.sql                                |
-- |Author Name        :  Akhil benarji                                                     |
-- |Date of Creation   :  08 August, 2008                                                   |
-- |Description        :  Procedure to get the data for CC_FIX_ORDER_STAT based             |
-- |                      on the search criteria                                            |
-- |Revision History   :                                                                    |
-- |----------------------------------------------------------------------------------------|
-- |Rno        Date Changed           Changed By        Change Details                      |
-- |----------------------------------------------------------------------------------------|
-- |1.0        08 Aug 2008            Akhil benarji.    Initial Creation                    |
-- |1.0        21 Aug 2008            Akhil benarji.    a)Changes done based on the         |
-- |                                                      addition of new column SessID     |
-- |                                                      in the CC_FIX_ORDER_STAT Table    |
-- |													b)Changes done based on the         |
-- |                                                      addition of new search criteria   |
-- |                                                      in the Front-End interface        |
-- |1.1        01 Sep 2008            Akhil benarji.    a)Query recreated inorder to avoid  |
-- |                                                      the using of ClicOnn set-up tables|
-- |                                                      for some user search criteria like|
-- |                                                      CompId, Market,OrderStaus, orderid|
-- |                                                      and orderType. Cliconn Tables are |
-- |                                                      not used when search criteria has |
-- |                                                      only these.                       |
-- |1.5        09 Oct 2008            Akhil benarji.    a)Changes made inorder to get the   |
-- |                                                      records from the archive table if |
-- |                                                      if the current date is > from date|
-- |1.6        24 Oct 2008            Akhil benarji.    a)Changes made inorder to display   |
-- |                                                      the client names retrieved by     |
-- |                                                      V_CLICONN_CONNECTION C2,          |
-- |                                                      V_CLICONN_SEARCHCLIENT            |
-- |1.6        24 Oct 2008            Cookie       .    b)USD Order Consideration, USD done,|
-- |                                                      Volume % new columns added        |
-- |1.7        20 Nov 2008            Akhil        .    a)Changes done based on the new cols|
-- |                                                      added to the OrderStat and Archive|
-- |                                                          								|
-- |                                                      						            |
-- |                                                      						            |
-- |----------------------------------------------------------------------------------------|
********************************************************************************************/
CREATE PROCEDURE dbo.P_CLICONN_ORDER_STATISTICS_REP
	@REPORT_ID 			VARCHAR(50),
	@INPARAMS			VARCHAR(1000),
	@FROM_DATE			VARCHAR(10),
	@TO_DATE			VARCHAR(10),
	@RETURN_CODE 		INT       		OUTPUT,
	@RETURN_MSG  		VARCHAR(255)  	OUTPUT
AS
BEGIN

		DECLARE @PARAMETER_STR 		VARCHAR(1000),
        		@SPLITSTRING 		VARCHAR(100),
        		@KEYSTRING 			VARCHAR(100),
        		@VALSTRING 			VARCHAR(100),
        		@OUTSTRING			VARCHAR(1000),
        		@RETCODE			INT,
        		@RETMSG				VARCHAR(255),
        		@TMPFROMDT			VARCHAR(10),
        		@TMPTODT			VARCHAR(10),
        		@SELECT_CLAUSE 		VARCHAR(2000),
        		@FROM_CLAUSE_TMP	VARCHAR(255),
        		@FROM_CLAUSE 		VARCHAR(255),
        		@WHERE_CLAUSE 		VARCHAR(1000),
        		@ERRORCODE			INT,
        		@ERRORMSG			VARCHAR(1000),
        		@UNION_EXIST		CHAR(1),
        		@DATA_FROM_CONN_TBL CHAR(1)

        SELECT	@RETURN_CODE 		= 0,
        		@RETURN_MSG 		= NULL
        SELECT  @PARAMETER_STR 		= @INPARAMS
		SELECT 	@SELECT_CLAUSE 		= ""
		SELECT 	@FROM_CLAUSE_TMP 	= ""
		SELECT 	@FROM_CLAUSE   		= ""
		SELECT 	@WHERE_CLAUSE  		= ""
		SELECT 	@UNION_EXIST  		= "N"
        SELECT  @DATA_FROM_CONN_TBL = 'F'

        --Modified by Akhil on 09 Oct 2008 inorder to acces the archive table if current date  >  from date
        IF CONVERT(datetime,@FROM_DATE,103) < convert(datetime,convert(varchar,getdate(),103),103)
        	BEGIN
        		SELECT @FROM_CLAUSE   = " FROM CC_FIX_ORDER_STAT_ARCHIVE C4"
        		IF CONVERT(datetime,@TO_DATE,103) >= convert(datetime,convert(varchar,getdate(),103),103)
        			BEGIN
        				SELECT @UNION_EXIST  	= "Y"
        			END
        	END
       	ELSE
       		BEGIN
       			SELECT @FROM_CLAUSE   = " FROM CC_FIX_ORDER_STAT C4"
       		END


    	-- Check the in parameter @FROM_DATE is null
    	-- If null get todays date in the format yyyymmdd
        IF @FROM_DATE IS NULL OR @FROM_DATE = ''
        	BEGIN
        		SELECT @TMPFROMDT = CONVERT(varchar,GETDATE(),112)
        	END
        ELSE
        	BEGIN
        		IF CHARINDEX('/',@FROM_DATE) > 0
        			BEGIN
        				SELECT @TMPFROMDT = CONVERT(varchar,CONVERT(datetime,@FROM_DATE,103),112)
        			END
        		ELSE
        			BEGIN
        				SELECT @TMPFROMDT = @FROM_DATE
        			END
        	END

        --Check the in parameter @TO_DATE is null
        -- If null get tomorrow date in the format yyyymmdd
        IF @TO_DATE IS NULL OR @TO_DATE = ''
        	BEGIN
        		SELECT @TMPTODT = CONVERT(varchar,DATEADD(dd,1,GETDATE()),112)
        	END
        ELSE
        	BEGIN
        		SELECT @TMPTODT = convert(varchar,dateadd(dd,1,CONVERT(datetime,@TO_DATE,103)),112)
        	END

		SELECT @SELECT_CLAUSE = "SELECT C4.ClOrdID, C4.ClientID, C4.Market, C4.Currency, C4.Symbol, (SELECT FixValueDesc FROM CC_FIX_MAPPING WHERE FixTagType='Side' AND FixValue=C4.Side) Side, C4.OrderQty, (case when C4.OrderType='1' then 'Market' else convert(varchar,C4.Price) end) Price, (SELECT FixValueDesc FROM CC_FIX_MAPPING WHERE FixTagType='OrderType' AND FixValue=C4.OrderType) OrderType, C4.ExpireTime, C4.OrderIncomeDate, C4.LastUpdateTime, (SELECT FixValueDesc FROM CC_FIX_MAPPING WHERE FixTagType='OrderStatus' AND FixValue=C4.OrderStatus) OrderStatus, C4.OrderID, C4.CumQty, C4.AvgPx, (SELECT FixValueDesc FROM CC_FIX_MAPPING WHERE FixTagType='HandInst' AND FixValue=C4.HandInst) 'Service Line', C4.Remark, C4.SessID, C4.TargetID, C4.SecurityType,C4.AlgoStrategy"

		SELECT @SELECT_CLAUSE = @SELECT_CLAUSE + ",round(isnull(C4.OrderQty * (SELECT EXCHANGE_RATE FROM CC_FIX_EXCHANGE_RATE  WHERE LOCAL_CURRENCY_ID  = C4.Currency) * CASE WHEN C4.OrderType='1' THEN C4.AvgPx ELSE C4.Price END,0),6) 'USD Order Consideration'"

		SELECT @SELECT_CLAUSE = @SELECT_CLAUSE + ",round(isnull(C4.CumQty * (SELECT EXCHANGE_RATE FROM CC_FIX_EXCHANGE_RATE  WHERE LOCAL_CURRENCY_ID  = C4.Currency) * C4.AvgPx,0),6) 'USD Done'"

		SELECT @SELECT_CLAUSE = @SELECT_CLAUSE + ",case when C4.OrderQty = 0 then 'N/A' when C4.CumQty is null then 'N/A' else convert(varchar,convert(decimal(20,3),(convert(float,C4.CumQty)/convert(float,C4.OrderQty)*100))) end 'Volume Done %'"

		SELECT @WHERE_CLAUSE  = " WHERE C4.OrderIncomeDate >='"+@TMPFROMDT+"'"+
								" AND C4.OrderIncomeDate <'"+@TMPTODT+"'"



		-- process search criteria - begin
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
       							IF @DATA_FROM_CONN_TBL = 'F'
       								BEGIN
										SELECT @DATA_FROM_CONN_TBL = 'T'
									END
       							SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND UPPER(C2.CLIENT_NAME) LIKE '"+ UPPER(@OUTSTRING) + "'"
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
       							SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND UPPER(C4.ClientID) LIKE '"+ UPPER(@OUTSTRING) + "'"
       						END
       					ELSE
       						BEGIN
       							SELECT @RETURN_CODE = @RETCODE
       							SELECT @RETURN_MSG  = @RETMSG
       							RETURN
       						END
       				END
       			ELSE IF @KEYSTRING = "Market" -- OK
       				BEGIN
       					SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND UPPER(C4.Market) = '"+ UPPER(@VALSTRING) + "'"
       				END
       			ELSE IF @KEYSTRING = "FIX Engine" -- OK
       				BEGIN
       					IF @DATA_FROM_CONN_TBL = 'F'
       						BEGIN
								SELECT @DATA_FROM_CONN_TBL = 'T'
							END
       					SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  ",C2.PROD_HUB_NAME HUB_NAME"
       					SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND UPPER(C2.PROD_HUB_NAME) = '"+ UPPER(@VALSTRING) + "'"
       				END
       			ELSE IF @KEYSTRING = "Network Product" -- PENDING
       				BEGIN
       					IF @DATA_FROM_CONN_TBL = 'F'
       					BEGIN
							SELECT @DATA_FROM_CONN_TBL = 'T'
						END
       					SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  ",C2.NETWORK_PRODUCT_NAME Network_Name"
       					SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C2.NETWORK_PRODUCT_ID = "+ @VALSTRING
       				END
       			ELSE IF @KEYSTRING = "OMS Product" -- PENDING
       				BEGIN
       					IF @DATA_FROM_CONN_TBL = 'F'
       						BEGIN
								SELECT @DATA_FROM_CONN_TBL = 'T'
							END
       					SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  ",C2.OMS_PRODUCT_NAME Oms_Name"
       					SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C2.OMS_PRODUCT_ID="+ @VALSTRING
       				END
       			ELSE IF @KEYSTRING = "FIX Version" -- PENDING
       				BEGIN
       					EXEC P_CLICONN_REPORTS_VALIDATION 'STAR_MOD', @VALSTRING, @OUTSTRING OUTPUT, @RETCODE OUTPUT, @RETMSG OUTPUT
       					IF @RETCODE = 0
       						BEGIN
       							IF @DATA_FROM_CONN_TBL = 'F'
       								BEGIN
										SELECT @DATA_FROM_CONN_TBL = 'T'
									END
       							SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  ",C2.FIX_VERSION"
       							SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C2.FIX_VERSION LIKE '"+ @OUTSTRING+ "'"
       						END
       					ELSE
       						BEGIN
       							SELECT @RETURN_CODE = @RETCODE
       							SELECT @RETURN_MSG  = @RETMSG
       							RETURN
       						END
       				END
       			ELSE IF @KEYSTRING = "Order Status" -- OK
       				BEGIN
       					SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND UPPER(C4.OrderStatus) = '"+ UPPER(@VALSTRING)+ "'"
       				END
       			ELSE IF @KEYSTRING = "Fidessa ID" -- PENDING
       				BEGIN
       					EXEC P_CLICONN_REPORTS_VALIDATION 'STAR_MOD', @VALSTRING, @OUTSTRING OUTPUT, @RETCODE OUTPUT, @RETMSG OUTPUT
       					IF @RETCODE = 0
       						BEGIN
       							IF @DATA_FROM_CONN_TBL = 'F'
       								BEGIN
										SELECT @DATA_FROM_CONN_TBL = 'T'
									END
       							SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  ",C2.FIDESSA_ID"
       							SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C2.FIDESSA_ID LIKE '"+ @OUTSTRING+ "'"
       						END
       					ELSE
       						BEGIN
       							SELECT @RETURN_CODE = @RETCODE
       							SELECT @RETURN_MSG  = @RETMSG
       							RETURN
       						END
       				END
       			ELSE IF @KEYSTRING = "Order ID" -- OK
       				BEGIN
       					EXEC P_CLICONN_REPORTS_VALIDATION 'STAR_MOD', @VALSTRING, @OUTSTRING OUTPUT, @RETCODE OUTPUT, @RETMSG OUTPUT
       					IF @RETCODE = 0
       						BEGIN
       							SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C4.OrderID LIKE '"+ UPPER(@OUTSTRING) + "'"
       						END
       					ELSE
       						BEGIN
       							SELECT @RETURN_CODE = @RETCODE
       							SELECT @RETURN_MSG  = @RETMSG
       							RETURN
       						END
       				END
       			ELSE IF @KEYSTRING = "Service Line" --DMA or CASH
       				BEGIN
       					IF UPPER(@VALSTRING) = 'DMA'
       					   SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C4.HandInst = '1'"
       					ELSE
       					   SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C4.HandInst IN('2','3')"
       				END
       			ELSE IF @KEYSTRING = "Security Type" --CS or FUT
       				BEGIN
       					SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C4.SecurityType ='"+@VALSTRING+"'"
       				END
       		END
        END
        -- process search criteria - end

        --Check whether to use the views V_CLICONN_CONNECTION and V_CLICONN_SEARCHCLIENT
       	IF @DATA_FROM_CONN_TBL = 'T'
       		BEGIN
       			SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  ",C2.CLIENT_NAME"
       			SELECT @FROM_CLAUSE = @FROM_CLAUSE + ",V_CLICONN_CONNECTION C2,V_CLICONN_SEARCHCLIENT C3"
       			SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C2.CONNECTION_ID = C3.CONNECTION_ID AND C2.CLIENT_ID = C3.CLIENT_ID"
       			SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " AND C3.FIXTAGMAPPING_COMP_ID = C4.ClientID AND C2.COMP_ID = C4.SessID  AND C3.FIX_TAG_TYPE LIKE 'COMP%' AND C3.CONNECTION_ACTIVE=1"
       		END
     	ELSE
       		BEGIN       		
       			--SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  ",(SELECT DISTINCT C2.CLIENT_NAME FROM V_CLICONN_CONNECTION C2,V_CLICONN_SEARCHCLIENT C3"
       			--SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  " WHERE C2.CONNECTION_ID = C3.CONNECTION_ID AND C2.CLIENT_ID = C3.CLIENT_ID"
       			--SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  " AND C3.FIXTAGMAPPING_COMP_ID = C4.ClientID  AND C2.COMP_ID = C4.SessID AND C3.FIX_TAG_TYPE = 'COMP_ID' AND C3.CONNECTION_ACTIVE=1 AND C2.ACTIVE = 1) CLIENT_NAME"
       			SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  ",case when (SELECT DISTINCT count(*) FROM V_CLICONN_CONNECTION C2,V_CLICONN_SEARCHCLIENT C3"
       			SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  " WHERE C2.CONNECTION_ID = C3.CONNECTION_ID AND C2.CLIENT_ID = C3.CLIENT_ID"
       			SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  " AND C3.FIXTAGMAPPING_COMP_ID = C4.ClientID  AND C2.COMP_ID = C4.SessID AND C3.FIX_TAG_TYPE = 'COMP_ID' AND C3.CONNECTION_ACTIVE=1 AND C2.ACTIVE = 1) > 1 then '' else"
       			SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  "(SELECT DISTINCT C2.CLIENT_NAME FROM V_CLICONN_CONNECTION C2,V_CLICONN_SEARCHCLIENT C3"
       			SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  " WHERE C2.CONNECTION_ID = C3.CONNECTION_ID AND C2.CLIENT_ID = C3.CLIENT_ID"
       			SELECT @SELECT_CLAUSE = @SELECT_CLAUSE +  " AND C3.FIXTAGMAPPING_COMP_ID = C4.ClientID  AND C2.COMP_ID = C4.SessID AND C3.FIX_TAG_TYPE = 'COMP_ID' AND C3.CONNECTION_ACTIVE=1 AND C2.ACTIVE = 1) end 'CLIENT_NAME'"
       		END

        --Check whether to use the both the tables CC_FIX_ORDER_STAT_ARCHIVE and CC_FIX_ORDER_STAT or just a single table
       	IF @UNION_EXIST = "Y"
       		BEGIN
       			SELECT @FROM_CLAUSE_TMP 	= STR_REPLACE(@FROM_CLAUSE,'CC_FIX_ORDER_STAT_ARCHIVE','CC_FIX_ORDER_STAT')
       			EXEC (@SELECT_CLAUSE+@FROM_CLAUSE+@WHERE_CLAUSE+" UNION "+ @SELECT_CLAUSE+@FROM_CLAUSE_TMP+@WHERE_CLAUSE+ " ORDER BY C4.ClientID,C4.LastUpdateTime")
       		END
       	ELSE
       		BEGIN
       			SELECT @WHERE_CLAUSE = @WHERE_CLAUSE + " ORDER BY C4.ClientID,C4.LastUpdateTime"
       			--print @SELECT_CLAUSE
       			--print @FROM_CLAUSE
       			--print @WHERE_CLAUSE
       			EXEC (@SELECT_CLAUSE+@FROM_CLAUSE+@WHERE_CLAUSE)

       		END

		SELECT @ERRORCODE = @@ERROR

		IF @ERRORCODE != 0
   			BEGIN
   				SELECT @ERRORMSG = description FROM master.dbo.sysmessages WHERE error = @ERRORCODE

                INSERT INTO CC_FIX_ORD_STAT_TRACKING
                VALUES
                  ('P_CLICONN_ORDER_STATISTICS_REP',
                   GETDATE(),
                   'ERROR',
                   'Execution of FIX Order failed for period :'+@TMPFROMDT+' To '+@TMPTODT,
                   'F',
                   @REPORT_ID,
                   CONVERT(varchar, @ERRORCODE),
                   NULL,
                   @ERRORMSG)

   				SELECT @RETURN_MSG = 'P_CLICONN_ORDER_STATISTICS_REP - Execution of FIX Order failed.'
   				SELECT @RETURN_CODE = @ERRORCODE
   				RETURN
     		END
     	ELSE
     		BEGIN
                INSERT INTO CC_FIX_ORD_STAT_TRACKING
                VALUES
                  ('P_CLICONN_ORDER_STATISTICS_REP',
                   GETDATE(),
                   'INFO',
                   'Execution of FIX Order Success for period :'+@TMPFROMDT+' To '+@TMPTODT,
                   'S',
                   @REPORT_ID,
                   NULL,
                   NULL,
                   NULL)
     		END
END

IF OBJECT_ID('dbo.P_CLICONN_ORDER_STATISTICS_REP') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.P_CLICONN_ORDER_STATISTICS_REP >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.P_CLICONN_ORDER_STATISTICS_REP >>>'
go
USE cliconn_dev
go
GRANT EXECUTE ON dbo.P_CLICONN_ORDER_STATISTICS_REP TO select_all
go
GRANT EXECUTE ON dbo.P_CLICONN_ORDER_STATISTICS_REP TO update_all
go
