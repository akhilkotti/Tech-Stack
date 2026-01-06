===================================================================================================
--get all the exchnage accounts
===================================================================================================

SELECT  SE.EXCHANGE_ACCOUNT_ID,
        SE.DESCRIPTION,
        SE.STATUS,
        SE.EXCHANGE_ACCOUNT_TYPE,
        SE.COUNTRY_CODE
FROM STB_EXCHANGE_ACCOUNT SE

-- 10392 record(s) selected [Fetch MetaData: 0/ms] [Fetch Data: 5345/ms] 

===================================================================================================
--get all the exchnage mapping records
===================================================================================================

SELECT  SC.EXCHANGE_ACCOUNT_ID,
        SC.COUNTERPARTY_ID
FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
WHERE SC.EXCHANGE_ACCOUNT_ID <>'DUMMY'

-- 12569 record(s) selected [Fetch MetaData: 0/ms] [Fetch Data: 3407/ms] 

===================================================================================================
--get all the excahange accounts that do not have parents or subaccounts
===================================================================================================
 SELECT SE.EXCHANGE_ACCOUNT_ID,SE.DESCRIPTION
 FROM STB_EXCHANGE_ACCOUNT SE
 WHERE NOT EXISTS(SELECT SC.EXCHANGE_ACCOUNT_ID 
                 FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
                 WHERE SE.EXCHANGE_ACCOUNT_ID=SC.EXCHANGE_ACCOUNT_ID)
                 
--3574 record(s) selected [Fetch MetaData: 0/ms] [Fetch Data: 969/ms]    

SET ROWCOUNT 50000
SELECT DISTINCT SE.EXCHANGE_ACCOUNT_ID,
--SA.ALTERNATE_TYPE,
--SA.EXCHANGE_ACCOUNT_CODE,
SE.DESCRIPTION,SE.STATUS,SE.EXCHANGE_ACCOUNT_TYPE,SE.COUNTRY_CODE
FROM STB_EXCHANGE_ACCOUNT SE,STB_ALT_EXCH_ACCOUNT_ID SA
WHERE NOT EXISTS(SELECT SC.EXCHANGE_ACCOUNT_ID 
                     FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
                     WHERE SE.EXCHANGE_ACCOUNT_ID=SC.EXCHANGE_ACCOUNT_ID) 
AND SE.EXCHANGE_ACCOUNT_ID = SA.EXCHANGE_ACCOUNT_ID
AND (SA.EXCHANGE_ACCOUNT_CODE NOT LIKE 'CLOSED%' OR SE.STATUS='A')
--AND SE.EXCHANGE_ACCOUNT_ID IN('17548','17549')                          



===================================================================================================
--get all the excahange accounts that have parents or subaccounts
===================================================================================================
 SELECT SE.EXCHANGE_ACCOUNT_ID,SE.DESCRIPTION
 FROM STB_EXCHANGE_ACCOUNT SE
 WHERE EXISTS(SELECT SC.EXCHANGE_ACCOUNT_ID 
                 FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
                 WHERE SE.EXCHANGE_ACCOUNT_ID=SC.EXCHANGE_ACCOUNT_ID)
                 
--6818 record(s) selected [Fetch MetaData: 0/ms] [Fetch Data: 1563/ms]  

===================================================================================================
--get all the parents
===================================================================================================
SELECT  CP.COUNTERPARTY_ID
FROM ALT_COUNTERPARTY_ID ACI,COUNTERPARTY CP
WHERE ACI.COUNTERPARTY_ID = CP.COUNTERPARTY_ID
AND CP.COUNTERPARTY_TYPE='C' 
--AND ACI.ALTERNATE_TYPE='VIEW'
--ORDER BY CP.COUNTERPARTY_ID


===================================================================================================
--get all the subaccounts
===================================================================================================
SELECT C1.COUNTERPARTY_ID 
FROM COUNTERPARTY C1
WHERE C1.COUNTERPARTY_TYPE = 'S'
--AND C1.STATUS='A'



===================================================================================================

===================================================================================================
SELECT  RTRIM(SUBSTRING(SC.EXCHANGE_ACCOUNT_CODE,7,20))
FROM STB_ALT_EXCH_ACCOUNT_ID SC
WHERE SC.EXCHANGE_ACCOUNT_CODE like 'CLOSED%'


===================================================================================================

===================================================================================================
SELECT * FROM iTB_audit
WHERE SEQUENCE_NUM IN(SELECT SEQUENCE_NUM FROM iTB_audit)
--AND WORKSTATION = 'test'
ORDER BY SEQUENCE_NUM DESC


===================================================================================================

===================================================================================================

SET ROWCOUNT 10
SELECT          TOR.ORDER_DATETIME,
        TOR.CL_ENTERED_DATETIME
FROM TB_ORDER TOR,TB_ORDER_DETAIL TOD
WHERE TOR.CL_ORDER_ID=TOD.CL_ORDER_ID
AND TOR.MARKET_ID IN('SEO-MAIN','KSQ-MAIN')
AND TOR.CL_ORDER_ID='00000216802ORHK1'


SET ROWCOUNT 100
SELECT  TOR.CL_ORDER_ID,
        TOR.CL_QUANTITY,
        TOD.CL_QUANTITY_FILLED,
        TOR.CL_ORDER_PRICE,
        TOR.MARKET_ID,
        TOR.ORDER_DATETIME,
        TOR.CL_ENTERED_DATETIME
FROM TB_ORDER TOR,TB_ORDER_DETAIL TOD
WHERE TOR.CL_ORDER_ID=TOD.CL_ORDER_ID
AND TOR.MARKET_ID IN('SEO-MAIN','KSQ-MAIN')
AND CONVERT( VARCHAR(8), TOR.ORDER_DATETIME, 101 )= '20080327'
AND TOR.CL_ENTERED_DATETIME IN(SELECT MAX(CL_ENTERED_DATETIME) 
                           FROM TB_ORDER 
                           WHERE TOR.CL_ORDER_ID = CL_ORDER_ID 
                           GROUP BY CL_ORDER_ID)
--ORDER BY TOR.CL_ORDER_ID


SET ROWCOUNT 100
SET ROWCOUNT 10
SELECT  *
FROM TB_ORDER_DETAIL TOD
WHERE TOD.CL_ORDER_ID='00000001601ORHK1'


set rowcount 10
SELECT *--TBO.CL_ORDER_ID,TBTS.CL_ENTERED_DATETIME,CONVERT( VARCHAR(8), TBTS.CL_ENTERED_DATETIME, 101 )
FROM TB_ORDER TBO, 
    TB_ORDER_EXECUTION TBOE, 
    TB_TRADE TBT, 
    TB_CURRENT_ORDER TBCO, 
    TB_TRADE_SET TBTS
WHERE TBO.CL_ORDER_ID = TBCO.CL_ORDER_ID AND
      TBO.CL_VERSION = TBCO.CL_VERSION AND
      TBO.CL_ORDER_ID = TBOE.CL_ORDER_ID AND 
      TBOE.CL_TRADE_SET_ID = TBT.CL_TRADE_SET_ID AND
      TBT.CL_TRADE_SET_ID = TBTS.CL_TRADE_SET_ID AND 
      TBT.CL_VERSION = TBTS.CL_VERSION AND
      --TBTS.CL_ENTERED_DATETIME = '20080312'
      CONVERT( VARCHAR(10), TBTS.CL_ENTERED_DATETIME, 101 )= '02/27/2008'
      and TBO.CL_ORDER_ID='00000196547ORHK1'
      
      
SELECT CL_ORDER_ID
FROM TB_ORDER TOR
WHERE TOR.CL_ORDER_ID = CL_ORDER_ID 
GROUP BY CL_ORDER_ID
HAVING CONVERT( VARCHAR(8), MAX(TOR.ORDER_DATETIME), 101 )= '20080327'       

SELECT TARGET_INSTRUMENT,COUNT(*)
FROM MTB_INSTRUMENT
WHERE TARGET_INSTRUMENT IS NOT NULL
AND MARKET_ID LIKE 'HKG%'--IN('HKG-ETS','HKG-GEM','HKG-MAIN','HKG-NASD','HKG-MKC1','HKG-MKC2')
--AND CURRENCY_CODE = 'HKD'
GROUP BY TARGET_INSTRUMENT
HAVING COUNT(*) > 1

/*===================================================================================================
  get all the subaccounts for the client aberdeen.as and ssga.au showing the exchange accounts for
  each subaccount
===================================================================================================*/
SELECT  "SubAccountDescription"= C1.fDESCRIPTION,
        "ParentDescription"=
        (SELECT C2.fDESCRIPTION
         FROM COUNTERPARTY C2
         WHERE C2.COUNTERPARTY_ID = C1.PARENT_COUNTERPARTY_ID),
        "ViewCode"=
        (SELECT COUNTERPARTY_CODE 
         FROM ALT_COUNTERPARTY_ID 
         WHERE ALTERNATE_TYPE='VIEW' 
         AND COUNTERPARTY_ID=C1.COUNTERPARTY_ID),
         "Remarks"=
         CASE
            WHEN (SELECT COUNT(*)
                  FROM STB_EXCHANGE_ACCOUNT SE
                  WHERE EXISTS(SELECT SC.EXCHANGE_ACCOUNT_ID 
                               FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
                               WHERE SE.EXCHANGE_ACCOUNT_ID=SC.EXCHANGE_ACCOUNT_ID 
                               AND SC.COUNTERPARTY_ID=C1.COUNTERPARTY_ID)
                  AND SE.STATUS = 'A'
                  ) = 0  THEN
              'None Exist'
            WHEN (SELECT COUNT(*)
                  FROM STB_EXCHANGE_ACCOUNT SE
                  WHERE EXISTS(SELECT SC.EXCHANGE_ACCOUNT_ID 
                               FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
                               WHERE SE.EXCHANGE_ACCOUNT_ID=SC.EXCHANGE_ACCOUNT_ID 
                               AND SC.COUNTERPARTY_ID=C1.COUNTERPARTY_ID)
                  AND SE.STATUS = 'A'
                  ) = 2  
               THEN
              'Both Exist'   
            WHEN (
                  (SELECT COUNT(*)
                   FROM STB_EXCHANGE_ACCOUNT SE
                   WHERE EXISTS(SELECT SC.EXCHANGE_ACCOUNT_ID 
                                FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
                                WHERE SE.EXCHANGE_ACCOUNT_ID=SC.EXCHANGE_ACCOUNT_ID 
                                AND SC.COUNTERPARTY_ID=C1.COUNTERPARTY_ID)
                   AND SE.STATUS = 'A'
                  ) = 1 
                  AND 
                  (SELECT SE.COUNTRY_CODE
                   FROM STB_EXCHANGE_ACCOUNT SE
                   WHERE EXISTS(SELECT SC.EXCHANGE_ACCOUNT_ID 
                                FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
                                WHERE SE.EXCHANGE_ACCOUNT_ID=SC.EXCHANGE_ACCOUNT_ID 
                                AND SC.COUNTERPARTY_ID=C1.COUNTERPARTY_ID)  
                   AND SE.STATUS = 'A'
                   ) = 'KR'
                  )
               THEN
              'Only Korea Exist'    
            WHEN (
                  (SELECT COUNT(*)
                   FROM STB_EXCHANGE_ACCOUNT SE
                   WHERE EXISTS(SELECT SC.EXCHANGE_ACCOUNT_ID 
                                FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
                                WHERE SE.EXCHANGE_ACCOUNT_ID=SC.EXCHANGE_ACCOUNT_ID 
                                AND SC.COUNTERPARTY_ID=C1.COUNTERPARTY_ID)
                   AND SE.STATUS = 'A'
                  ) = 1 
                  AND 
                  (SELECT SE.COUNTRY_CODE
                   FROM STB_EXCHANGE_ACCOUNT SE
                   WHERE EXISTS(SELECT SC.EXCHANGE_ACCOUNT_ID 
                                FROM STB_CPTY_EXCH_ACCOUNT_MAP SC
                                WHERE SE.EXCHANGE_ACCOUNT_ID=SC.EXCHANGE_ACCOUNT_ID 
                                AND SC.COUNTERPARTY_ID=C1.COUNTERPARTY_ID)  
                   AND SE.STATUS = 'A'
                   ) = 'TW'
                  )
               THEN
              'Only Taiwan Exist'                                        
            ELSE
              'Unidentified'
            END
FROM COUNTERPARTY C1
WHERE C1.COUNTERPARTY_TYPE = 'S'
AND C1.STATUS = 'A'
AND C1.PARENT_COUNTERPARTY_ID IN('81224','87210')
ORDER BY C1.PARENT_COUNTERPARTY_ID,ViewCode,Remarks

===================================================================================================
Get Program Trade Fix Clients who has traded with macquarie till now
===================================================================================================
SELECT  DISTINCT 
        CP.COUNTERPARTY_ID,
        CP.fDESCRIPTION Description,
        (SELECT COUNTERPARTY_CODE 
         FROM ALT_COUNTERPARTY_ID 
         WHERE ALTERNATE_TYPE='VIEW' 
         AND COUNTERPARTY_ID=ACP.COUNTERPARTY_ID) ViewCode,
         "Remarks"=
         case 
         when CP.MQ_PT_FIX_TAG IS NOT NULL then
            'PT FIX Client'
         else
            'Others'
         end
FROM COUNTERPARTY CP, ALT_COUNTERPARTY_ID ACP
WHERE CP.COUNTERPARTY_ID = ACP.COUNTERPARTY_ID
AND CP.STATUS = 'A'
AND CP.MQ_PT_FIX_TAG IS NOT NULL AND CP.MQ_PT_FIX_VALUE IS NOT NULL
AND EXISTS(SELECT COUNTERPARTY_CODE 
                FROM ALT_COUNTERPARTY_ID 
                WHERE ALTERNATE_TYPE='FIX' 
                AND COUNTERPARTY_ID=ACP.COUNTERPARTY_ID)
AND EXISTS(SELECT DISTINCT TBO.CL_COUNTERPARTY_ID 
            FROM TB_ORDER TBO 
            WHERE  CP.COUNTERPARTY_ID=TBO.CL_COUNTERPARTY_ID
            AND TBO.CL_ENTERED_BY like '%_PT') 

===================================================================================================
Get Program trade Non Fix clients who has traded with maquarie
===================================================================================================
SELECT  DISTINCT 
        CP.COUNTERPARTY_ID,
        CP.fDESCRIPTION Description,
        (SELECT COUNTERPARTY_CODE 
         FROM ALT_COUNTERPARTY_ID 
         WHERE ALTERNATE_TYPE='VIEW' 
         AND COUNTERPARTY_ID=ACP.COUNTERPARTY_ID) ViewCode,
         "Remarks"=
         case 
         when CP.MQ_PT_FIX_TAG IS NOT NULL then
            'PT FIX Client'
         else
            'Others'
         end
FROM COUNTERPARTY CP, ALT_COUNTERPARTY_ID ACP
WHERE CP.COUNTERPARTY_ID = ACP.COUNTERPARTY_ID
AND CP.STATUS = 'A'
AND NOT EXISTS(SELECT COUNTERPARTY_CODE 
                FROM ALT_COUNTERPARTY_ID 
                WHERE ALTERNATE_TYPE='FIX' 
                AND COUNTERPARTY_ID=ACP.COUNTERPARTY_ID)
AND EXISTS(SELECT DISTINCT TBO.CL_COUNTERPARTY_ID 
            FROM TB_ORDER TBO 
            WHERE  CP.COUNTERPARTY_ID=TBO.CL_COUNTERPARTY_ID
            AND TBO.CL_ENTERED_BY like '%_PT') 


===================================================================================================
Get all the clients who has View code and Fix code
===================================================================================================

SELECT CP.fDESCRIPTION        Description,
       ACP.COUNTERPARTY_CODE  ViewCode,
       ACP1.COUNTERPARTY_CODE FixCode
  FROM COUNTERPARTY CP, ALT_COUNTERPARTY_ID ACP, ALT_COUNTERPARTY_ID ACP1
 WHERE CP.COUNTERPARTY_ID = ACP.COUNTERPARTY_ID
   AND ACP.COUNTERPARTY_ID = ACP1.COUNTERPARTY_ID
   AND CP.COUNTERPARTY_TYPE = 'C'
   AND CP.STATUS = 'A'
   AND (ACP.COUNTERPARTY_CODE IS NOT NULL AND
       ACP1.COUNTERPARTY_CODE IS NOT NULL)
   AND (ACP.ALTERNATE_TYPE = 'VIEW' AND ACP1.ALTERNATE_TYPE = 'FIX')

===================================================================================================
get all the market instruments which are inactive for the Singapore market(SES-MAIN,SES-ODD,SES-BUYIN)
===================================================================================================
SELECT S.INSTRUMENT_ID Instrument,
       A.MARKET_ID Market,
       A.INSTRUMENT_CODE RicCode,
       S1.STATUS
FROM STB_INSTRUMENT S,ALT_INSTRUMENT_ID A, STB_MARKET_INSTRUMENT S1
WHERE S.INSTRUMENT_ID = A.INSTRUMENT_ID
AND S.INSTRUMENT_ID = S1.INSTRUMENT_ID
AND A.MARKET_ID = S1.MARKET_ID
AND A.ALTERNATE_TYPE ='RIC'
AND S1.STATUS = 'I'
and A.MARKET_ID IN('SES-MAIN','SES-ODD','SES-BUYIN')


===================================================================================================
Get all the Exchanges with Reuters Subscriber turn on
===================================================================================================

SELECT DISTINCT 
       EX.EXCHANGE_ID ExchangeID,
       EX.fDESCRIPTION ExDescription,
       SM.MARKET_ID MarketID,
       SM.DESCRIPTION MktDescription,
       S1.STATUS,
       S1.REUTERS_SUBSCRIBER             
FROM   STB_INSTRUMENT S,
       ALT_INSTRUMENT_ID A, 
       STB_MARKET_INSTRUMENT S1,
       STB_MARKET SM,
       EXCHANGE EX 
WHERE S.INSTRUMENT_ID = A.INSTRUMENT_ID
AND S.INSTRUMENT_ID = S1.INSTRUMENT_ID
AND A.MARKET_ID = S1.MARKET_ID
AND S1.MARKET_ID = SM.MARKET_ID
AND SM.EXCHANGE_ID = EX.EXCHANGE_ID
AND S1.STATUS = 'A'
AND S1.REUTERS_SUBSCRIBER='Y'

===================================================================================================
same as the above query with individual count for each market
===================================================================================================
Example:
ExchangeID	ExDescription			MarketID	MktDescription				ReutersSubscriber With Y	ReutersSubscriber With N	ReutersSubscriber With NULL
ASE		American Stock Exchange (AMEX)	ASE-MAIN	American Stock Exchange (AMEX)		1				0				0
ASX		Australian Stock Exchange	ASX-ITS		Australian Stock Exchange (ITS)		19227				817				15874
ASX		Australian Stock Exchange	ASX-MAIN	Australian Stock Exchange (SEATS)	4108				2				779

SELECT  T1.[ExchangeID],
        T1.[ExDescription],
        T1.[MarketID],
        T1.[MktDescription],
        CASE
        WHEN T2.[Y] IS NULL THEN
          '0'
        ELSE
          CONVERT(VARCHAR,T2.[Y])
        END "ReutersSubscriber With Y",
        CASE
        WHEN T3.[N] IS NULL THEN
          '0'
        ELSE
          CONVERT(VARCHAR,T3.[N])
        END "ReutersSubscriber With N",
        CASE
        WHEN T4.[EMPTY] IS NULL THEN
          '0'
        ELSE
          CONVERT(VARCHAR,T4.[EMPTY])
        END "ReutersSubscriber With NULL"
FROM
(
SELECT EX.EXCHANGE_ID "ExchangeID",
       EX.fDESCRIPTION "ExDescription",
       SM.MARKET_ID "MarketID",
       SM.DESCRIPTION "MktDescription"
FROM   STB_INSTRUMENT S,
       ALT_INSTRUMENT_ID A, 
       STB_MARKET_INSTRUMENT S1,
       STB_MARKET SM,
       EXCHANGE EX 
WHERE S.INSTRUMENT_ID = A.INSTRUMENT_ID
AND S.INSTRUMENT_ID = S1.INSTRUMENT_ID
AND A.MARKET_ID = S1.MARKET_ID
AND S1.MARKET_ID = SM.MARKET_ID
AND SM.EXCHANGE_ID = EX.EXCHANGE_ID
AND S1.STATUS = 'A'
GROUP BY  EX.EXCHANGE_ID,
          SM.MARKET_ID
) T1      
LEFT JOIN
(
SELECT EX.EXCHANGE_ID "ExchangeID",
       SM.MARKET_ID "MarketID",
       COUNT(*) "Y"
FROM   STB_INSTRUMENT S,
       ALT_INSTRUMENT_ID A, 
       STB_MARKET_INSTRUMENT S1,
       STB_MARKET SM,
       EXCHANGE EX 
WHERE S.INSTRUMENT_ID = A.INSTRUMENT_ID
AND S.INSTRUMENT_ID = S1.INSTRUMENT_ID
AND A.MARKET_ID = S1.MARKET_ID
AND S1.MARKET_ID = SM.MARKET_ID
AND SM.EXCHANGE_ID = EX.EXCHANGE_ID
AND S1.STATUS = 'A'
AND S1.REUTERS_SUBSCRIBER ='Y'
GROUP BY  EX.EXCHANGE_ID,
          SM.MARKET_ID
) T2   
ON  T1.[ExchangeID] = T2.[ExchangeID] AND T1.[MarketID] = T2.[MarketID]
LEFT JOIN
(
SELECT EX.EXCHANGE_ID "ExchangeID",
       SM.MARKET_ID "MarketID",
       COUNT(*) "N"
FROM   STB_INSTRUMENT S,
       ALT_INSTRUMENT_ID A, 
       STB_MARKET_INSTRUMENT S1,
       STB_MARKET SM,
       EXCHANGE EX 
WHERE S.INSTRUMENT_ID = A.INSTRUMENT_ID
AND S.INSTRUMENT_ID = S1.INSTRUMENT_ID
AND A.MARKET_ID = S1.MARKET_ID
AND S1.MARKET_ID = SM.MARKET_ID
AND SM.EXCHANGE_ID = EX.EXCHANGE_ID
AND S1.STATUS = 'A'
AND S1.REUTERS_SUBSCRIBER ='N'
GROUP BY  EX.EXCHANGE_ID,
          SM.MARKET_ID
) T3
ON  T1.[ExchangeID] = T3.[ExchangeID] AND T1.[MarketID] = T3.[MarketID]
LEFT JOIN
(
SELECT EX.EXCHANGE_ID "ExchangeID",
       SM.MARKET_ID "MarketID",
       COUNT(*) "EMPTY"
FROM   STB_INSTRUMENT S,
       ALT_INSTRUMENT_ID A, 
       STB_MARKET_INSTRUMENT S1,
       STB_MARKET SM,
       EXCHANGE EX 
WHERE S.INSTRUMENT_ID = A.INSTRUMENT_ID
AND S.INSTRUMENT_ID = S1.INSTRUMENT_ID
AND A.MARKET_ID = S1.MARKET_ID
AND S1.MARKET_ID = SM.MARKET_ID
AND SM.EXCHANGE_ID = EX.EXCHANGE_ID
AND S1.STATUS = 'A'
AND S1.REUTERS_SUBSCRIBER IS NULL
GROUP BY  EX.EXCHANGE_ID,
          SM.MARKET_ID
) T4
ON  T1.[ExchangeID] = T4.[ExchangeID] AND T1.[MarketID] = T4.[MarketID]


===================================================================================================
getting constraints in sql server
===================================================================================================

USE ODIN49;
GO
SELECT OBJECT_NAME(OBJECT_ID) AS NameofConstraint,
            SCHEMA_NAME(schema_id) AS SchemaName,
            OBJECT_NAME(parent_object_id) AS TableName,
            type_desc AS ConstraintType,object_id
    FROM sys.objects
    WHERE type_desc LIKE '%CONSTRAINT'
and OBJECT_NAME(parent_object_id)='tbl_LogTrades'
order by OBJECT_NAME(parent_object_id)
GO

===================================================================================================
getting source in sql server
===================================================================================================

sp_helptext <object name>

select top 10 text from sys.syscomments where id=<sys.objects object id>

===================================================================================================
Trades and average price from ODIN
===================================================================================================

select T1.[Stock],T1.[No Of Trades],T1.[Total]/T1.[No Of Trades] "Average price(IND Rs)",
(T1.[Total]/T1.[No Of Trades])*0.023 "Average price(US $)"
from 
( 
select nOMSId "Oms Id", 
sSymbol "Stock", 
(sum(cast(nQuantityTraded as money)) * (avg(cast(nTradedPrice as bigint))/100)) "Total",
count(*) "No Of Trades" 
from tbl_LogTrades 
where convert(varchar,dCurrentTime,112) between '20080108' and '20080109' 
group by nOMSId,sSymbol
) T1 
order by T1.[Stock] 




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================
