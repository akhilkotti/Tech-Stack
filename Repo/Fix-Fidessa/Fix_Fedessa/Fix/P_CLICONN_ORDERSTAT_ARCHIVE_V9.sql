IF OBJECT_ID('dbo.P_CLICONN_ORDERSTAT_ARCHIVE') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.P_CLICONN_ORDERSTAT_ARCHIVE
    IF OBJECT_ID('dbo.P_CLICONN_ORDERSTAT_ARCHIVE') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.P_CLICONN_ORDERSTAT_ARCHIVE >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.P_CLICONN_ORDERSTAT_ARCHIVE >>>'
END
go
/*****************************************************************************************
-- +=====================================================================================+
-- |                         Macquarie (Hong Kong)                                       |
-- +=====================================================================================+
-- |                                                                                     |
-- |Application Name   :  Order Statistics Report                                        |
-- |Object Name        :  P_CLICONN_ORDERSTAT_ARCHIVE.sql                                |
-- |Author Name        :  Akhil benarji                                                  |
-- |Date of Creation   :  28 August, 2008                                                |
-- |Description        :  Procedure to archive all the day GTC, GTD and Day Orders.      |
-- |                      This procedure will be scheduled to run from Monday - Friday at|
-- |                      8p.m to process the Day orders and also will be run on every   |
-- |                      Saturday at 8a.m to process the GTC, GTD and other Day orders  |
-- |                      which are not processed, from last thursday(Last Week) to this |
-- |                      thursday(Current Week).                                        |
-- |Scenarios:-                                                                          |
-- |	WEEKDAY:                                                                         |
-- |    	- Archive all those records where the order status is DONE FOR DAY, FILL,    |                                                                                   
-- |          CANCELED, REJECTED and EXPIRED. Ensure the CC_FIX_MAPPING table has the    |
-- |          required entries and FixAttribute1 column set to 1                         |
-- |                                                                                     |
-- |    WEEKEND:                                                                         |
-- |        - Archive GTC orders where the order status is CANCELED.(Handled by WEEKDAY) |
-- |        - Archive GTD orders where the order status is EXPIRED.(Handled by WEEKDAY)  |
-- |        - Archive GTC orders that are pending for 1 month and not CANCELED           |
-- |        - Archive GTD orders that are Expired and the Order Status not updated to    |
-- |          EXPIRED.                                                                   |
-- |        - Archive any Day Orders that are lasting for a week that are still not      |
-- |          processed.(Except Fridays orders which may be processed on monday)         |
-- |        - Delete the tracking table records which are older than 1 week              |
-- |                                                                                     |
-- |                                                                                     |
-- |Revision History   :                                                                 |
-- |-------------------------------------------------------------------------------------|
-- |Rno        Date Changed           Changed By        Change Details                   |
-- |-------------------------------------------------------------------------------------|
-- |1.0        28 Aug 2008            Akhil benarji.    Initial Creation                 |
-- |1.5        09 Oct 2008            Akhil benarji.    Added new Column Target Id       |
-- |                                                    Added new order status in the    |
-- |                                                    where condition PENDING CANCEL,  |
-- |                                                    TRADE                            |
-- |1.6        03 Oct 2008            Akhil benarji.    For handling GD_CLIENTS like INAB|
-- |                                                    and ITGA                         |
-- |1.7        24 Oct 2008            Akhil benarji.    New Column Currency Added in     |
-- |                                                    CC_FIX_ORDER_STAT Table          |
-- |1.8		   18 Nov 2008			  Akhil Benarji     Changes made as new columns added|
-- |                                                    into OrderStat and Archive tables|
-- |                                                                                     |
-- |-------------------------------------------------------------------------------------|
*****************************************************************************************/ 
CREATE PROCEDURE dbo.P_CLICONN_ORDERSTAT_ARCHIVE
    @TO_DAY             VARCHAR(8) = NULL,--these parameters are used when run manually for a particular date
    @DAY_OF_THE_WEEK    VARCHAR(7) = NULL --these parameters are used when run manually for a particular date
AS
    BEGIN
    	DECLARE @DAYOFTHEWEEK		varchar(7),
				@INS_ERR_CODE 		int, 
				@INS_ROW_COUNT 		int,
				@DEL_ERR_CODE 		int, 
				@DEL_ROW_COUNT 		int,
				@INS_ERR_MSG		varchar(500),
				@DEL_ERR_MSG		varchar(500),
				@ERRORMSG			varchar(1000),			
				@FROM_DATE			char(19),
				@TO_DATE			char(19),
				@TODAY  			char(8)

		-- set the variables with default values
		select @INS_ERR_CODE = 0, @INS_ROW_COUNT = 0, @DEL_ERR_CODE = 0, @DEL_ROW_COUNT = 0
		
		select @INS_ERR_MSG 	= NULL	
		select @DEL_ERR_MSG 	= NULL	  
	
        	
        IF 	@TO_DAY IS NULL OR @TO_DAY = ''
            BEGIN
		        SELECT @TODAY			= convert(varchar, getdate(), 112)
            END
        ELSE
            BEGIN
                 SELECT @TODAY			= @TO_DAY
            END
		
    	-- set the @CURRENTDAY based on todays date
        IF 	@DAY_OF_THE_WEEK IS NULL OR @DAY_OF_THE_WEEK = ''
            BEGIN
		        select @DAYOFTHEWEEK = case
         		        when (datepart(weekday, getdate()) = 7) then
          		        "WEEKEND"
         		        when (datepart(weekday, getdate()) = 2 OR
              		        datepart(weekday, getdate()) = 3 OR
              		        datepart(weekday, getdate()) = 4 OR
              		        datepart(weekday, getdate()) = 5 OR
              		        datepart(weekday, getdate()) = 6) then
          		        "WEEKDAY"
       		        end
            END
        ELSE
            BEGIN
                select @DAYOFTHEWEEK = @DAY_OF_THE_WEEK
            END

        --PRINT @DAYOFTHEWEEK
        
        -- If @CURRENTDAY is WEEKDAY archive todays orders and deleete all those records that are archived.
        IF @DAYOFTHEWEEK = "WEEKDAY"
        	BEGIN
        		
        		-- Initialize the variables fromdate and todate
				select @FROM_DATE 	= convert(varchar, dateadd(dd, -1, CONVERT(DATETIME,@TODAY)), 112) + ' 20:00:00'						 	
				select @TO_DATE		= @TODAY + ' 20:00:00'     

        		--Set the transaction mode
        		Begin transaction weekday_archive
       		
              		-- Insert into archive table today orders that are completed, filled,cancelled,rejected or expired
					INSERT INTO CC_FIX_ORDER_STAT_ARCHIVE
  					SELECT CC_FIX_ORDER_STAT.ClOrdID, CC_FIX_ORDER_STAT.ClientID, CC_FIX_ORDER_STAT.Market, CC_FIX_ORDER_STAT.Currency, CC_FIX_ORDER_STAT.Symbol, CC_FIX_ORDER_STAT.Side, CC_FIX_ORDER_STAT.OrderQty, CC_FIX_ORDER_STAT.Price, CC_FIX_ORDER_STAT.OrderType, CC_FIX_ORDER_STAT.ExpireTime, CC_FIX_ORDER_STAT.OrderIncomeDate, CC_FIX_ORDER_STAT.LastUpdateTime, CC_FIX_ORDER_STAT.OrderStatus, CC_FIX_ORDER_STAT.OrderID, CC_FIX_ORDER_STAT.CumQty, CC_FIX_ORDER_STAT.AvgPx, CC_FIX_ORDER_STAT.HandInst, CC_FIX_ORDER_STAT.Remark, CC_FIX_ORDER_STAT.SessID, CC_FIX_ORDER_STAT.TargetID, CC_FIX_ORDER_STAT.SecurityType, CC_FIX_ORDER_STAT.CreateDate                                                                                                                                                              
    					FROM CC_FIX_ORDER_STAT
   					WHERE (
                            UPPER(OrderStatus) IN
         					(SELECT FixValue FROM CC_FIX_MAPPING WHERE FixTagType='OrderStatus' and FixAttribute1=1)
                            OR
                            SessID IN(SELECT fix_value from CC_FIX_VALID_VALUES WHERE fix_key='GFD_CLIENT' AND fix_status='A')--by Akhil on 13 Oct 2008 for GFD_CLIENTS
                          )
     					AND LastUpdateTime between @FROM_DATE and @TO_DATE
                	
                	-- Saving system global variables as the other operations will clear them
                	select @INS_ERR_CODE=@@error, @INS_ROW_COUNT=@@rowcount
                	               		                	
                	-- Delete from the main table today orders that are archived
					DELETE FROM CC_FIX_ORDER_STAT
   					WHERE (
                            UPPER(OrderStatus) IN
         					(SELECT FixValue FROM CC_FIX_MAPPING WHERE FixTagType='OrderStatus' and FixAttribute1=1)--After Change by Akhil on 09 Oct 2008
                            OR
                            SessID IN(SELECT fix_value from CC_FIX_VALID_VALUES WHERE fix_key='GFD_CLIENT' AND fix_status='A')--by Akhil on 13 Oct 2008 for GFD_CLIENTS
                          )
   					AND LastUpdateTime between @FROM_DATE and @TO_DATE
       					   					
                	-- Saving system global variables
                	select @DEL_ERR_CODE=@@error, @DEL_ROW_COUNT=@@rowcount
                	

                	-- Rollback if any errors
                	IF (@INS_ERR_CODE != 0 OR @DEL_ERR_CODE != 0)
						BEGIN
	  						ROLLBACK transaction weekend_archive
     					END        					       	       					
       			commit transaction weekday_archive        			
    			                        			
        	END -- End of WEEKDAY process
        -- If @CURRENTDAY is WEEKEND archive records from last thursday(last week) to this thursday(this week).
        ELSE IF @DAYOFTHEWEEK = "WEEKEND"
        	BEGIN
        	
        		-- Initialize the variables fromdate and todate
				select @FROM_DATE = convert(varchar, dateadd(dd, -9, CONVERT(DATETIME,@TODAY)), 112) + ' 20:00:00'						 	
				select @TO_DATE	  = convert(varchar, dateadd(dd, -2, CONVERT(DATETIME,@TODAY)), 112) + ' 20:00:00'	        
					
        		--Set the transaction mode
        		Begin transaction weekend_archive
        			-- Insert into archive table GTC, GTD or Day orders which are pending for 1 week.
					INSERT INTO CC_FIX_ORDER_STAT_ARCHIVE
  					SELECT CC_FIX_ORDER_STAT.ClOrdID, CC_FIX_ORDER_STAT.ClientID, CC_FIX_ORDER_STAT.Market, CC_FIX_ORDER_STAT.Currency, CC_FIX_ORDER_STAT.Symbol, CC_FIX_ORDER_STAT.Side, CC_FIX_ORDER_STAT.OrderQty, CC_FIX_ORDER_STAT.Price, CC_FIX_ORDER_STAT.OrderType, CC_FIX_ORDER_STAT.ExpireTime, CC_FIX_ORDER_STAT.OrderIncomeDate, CC_FIX_ORDER_STAT.LastUpdateTime, CC_FIX_ORDER_STAT.OrderStatus, CC_FIX_ORDER_STAT.OrderID, CC_FIX_ORDER_STAT.CumQty, CC_FIX_ORDER_STAT.AvgPx, CC_FIX_ORDER_STAT.HandInst, CC_FIX_ORDER_STAT.Remark, CC_FIX_ORDER_STAT.SessID, CC_FIX_ORDER_STAT.TargetID, CC_FIX_ORDER_STAT.SecurityType, CC_FIX_ORDER_STAT.CreateDate                                               
    				FROM CC_FIX_ORDER_STAT
         			WHERE (
                        	(
                            	UPPER(OrderStatus) IN(SELECT FixValue FROM CC_FIX_MAPPING WHERE FixTagType='OrderStatus')--After Change by Akhil on 09 Oct 2008
                            	and
                            	(
                                	ExpireTime in('GFD','')
                                	or
                                	@TODAY > ExpireTime 
                                	or
                                	(@TODAY > convert(varchar, dateadd(mm, 1, LastUpdateTime), 112)) -- GTC orders that are pending for 1 month
                            	)
                            	and
                            	(LastUpdateTime between @FROM_DATE and @TO_DATE)
                        	)
                        	or
                        	SessID IN(SELECT fix_value from CC_FIX_VALID_VALUES WHERE fix_key='GFD_CLIENT' AND fix_status='A')--by Akhil on 13 Oct 2008 for GFD_CLIENTS
                      	) 
            
               	    -- Saving system global variables as the other operations will clear them
                	select @INS_ERR_CODE=@@error, @INS_ROW_COUNT=@@rowcount
                	
               		-- Delete from the main table GTC, GTD or Day archived orders which are pending for 1 week.
					DELETE FROM CC_FIX_ORDER_STAT
         			WHERE (
                        	(
                            	UPPER(OrderStatus) IN(SELECT FixValue FROM CC_FIX_MAPPING WHERE FixTagType='OrderStatus')--After Change by Akhil on 09 Oct 2008
                            	and
                            	(
                                	ExpireTime in('GFD','')
                                	or
                                	@TODAY > ExpireTime 
                                	or
                                	(@TODAY > convert(varchar, dateadd(mm, 1, LastUpdateTime), 112)) -- GTC orders that are pending for 1 month
                            	)
                            	and
                            	(LastUpdateTime between @FROM_DATE and @TO_DATE)
                        	)
                        	or
                        	SessID IN(SELECT fix_value from CC_FIX_VALID_VALUES WHERE fix_key='GFD_CLIENT' AND fix_status='A')--by Akhil on 13 Oct 2008 for GFD_CLIENTS
                      	)  
         			  	
                	-- Saving system global variables
                	select @DEL_ERR_CODE=@@error, @DEL_ROW_COUNT=@@rowcount     
                	
                	-- Rollback if any errors
                	IF (@INS_ERR_CODE != 0 OR @DEL_ERR_CODE != 0)
						BEGIN
	  						ROLLBACK transaction weekend_archive
     					END       			
       			commit transaction weekend_archive
       			
       			-- Delete the data from the tracking table which are older than 1 week
				DELETE FROM CC_FIX_ORD_STAT_TRACKING
				WHERE TRAN_DATETIME <= CONVERT(DATETIME,CONVERT(VARCHAR,DATEADD(DD,-5,GETDATE()),112))         			
         			  
        	END -- End of WEEKEND process
        	
            -- Handling insert error
            IF @INS_ERR_CODE != 0
				BEGIN
					
					select @INS_ERR_MSG = description from master.dbo.sysmessages where error = @INS_ERR_CODE
				
					INSERT INTO CC_FIX_ORD_STAT_TRACKING
					VALUES
  					('P_CLICONN_ORDERSTAT_ARCHIVE',
                    getdate(),
   					'ERROR',
   					'Insert to CC_FIX_ORDER_STAT_ARCHIVE failed.',
   					'F',
   					@DAYOFTHEWEEK,
   					convert(varchar, @INS_ERR_CODE),
   					null,
   					@INS_ERR_MSG)
     			END   	    	
			
			-- Handling delete error
            IF @DEL_ERR_CODE != 0
				BEGIN
				
					select @DEL_ERR_MSG = description from master.dbo.sysmessages where error = @DEL_ERR_CODE
					
                    INSERT INTO CC_FIX_ORD_STAT_TRACKING
                    VALUES
                      ('P_CLICONN_ORDERSTAT_ARCHIVE',
                      getdate(),
                       'ERROR',
                       'Delete to CC_FIX_ORDER_STAT failed.',
                       'F',
                       @DAYOFTHEWEEK,
                       convert(varchar, @DEL_ERR_CODE),
                       null,
                       @DEL_ERR_MSG)
     			END  
     			
     		-- Raise error
     		IF (@INS_ERR_CODE != 0 OR @DEL_ERR_CODE != 0)
     			BEGIN
     				SELECT @ERRORMSG = @INS_ERR_MSG + @DEL_ERR_MSG
	  				RAISERROR 36661 @ERRORMSG
	  				RETURN 36661     			
     			END
     			
            -- Log the record count for those inserted and deleted if no errors
			IF (@INS_ERR_CODE = 0 AND @DEL_ERR_CODE = 0)      
				BEGIN
				
                    INSERT INTO CC_FIX_ORD_STAT_TRACKING
                    VALUES
                      ('P_CLICONN_ORDERSTAT_ARCHIVE',
                       getdate(),
                       'INFO',
                       'Records Inserted:' + convert(varchar,@INS_ROW_COUNT),
                       'S',
                       @DAYOFTHEWEEK,
                       null,
                       null,
                       null)   
                		
                    INSERT INTO CC_FIX_ORD_STAT_TRACKING
                    VALUES
                      ('P_CLICONN_ORDERSTAT_ARCHIVE',
                      getdate(),
                       'INFO',
                       'Records Deleted:' + convert(varchar,@DEL_ROW_COUNT),
                       'S',
                       @DAYOFTHEWEEK,
                       null,
                       null,
                       null)
				END    
						       	
    END
go
IF OBJECT_ID('dbo.P_CLICONN_ORDERSTAT_ARCHIVE') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.P_CLICONN_ORDERSTAT_ARCHIVE >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.P_CLICONN_ORDERSTAT_ARCHIVE >>>'
go
GRANT EXECUTE ON dbo.P_CLICONN_ORDERSTAT_ARCHIVE TO select_all
go
GRANT EXECUTE ON dbo.P_CLICONN_ORDERSTAT_ARCHIVE TO update_all
go
