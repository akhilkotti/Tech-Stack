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
Extract the programme trades and DMA trades from all (international and domestic) trades for the period from Jan 2008 to May 2008
===================================================================================================

SELECT A1. ORDER_ID "Order Id",
       A1. ENTERED_BY "Order Type",
       A1. TOTAL_QTY "Total Quantity",
       case
         when TBT.CL_BUY_SELL = 'B' then
          'Buy'
         else
          'Sell'
       end "Buy/Sell",
       TBT.CL_COUNTERPARTY_ID "Counterparty Id",
       TBT.CL_COUNTERPARTY_CODE "View Code",
       TBT.CL_MARKET_ID "Market",
       CONVERT(varchar, TBT.TIMESTAMP_1, 112) "Trade Time",
       SUM(TBT.CL_QUANTITY) "Executed Quantity",
       AVG(CAST(TBT.CL_TRADE_PRICE AS MONEY)) "Average Price"
  FROM (SELECT T1.CL_ORDER_ID   "ORDER_ID",
               T2.CL_VERSION    "VERSION",
               T1.CL_QUANTITY   "TOTAL_QTY",
               T1.CL_ENTERED_BY "ENTERED_BY"
          FROM TB_ORDER T1 RIGHT JOIN TB_CURRENT_ORDER T2 ON T1.CL_ORDER_ID =
                                                             T2.CL_ORDER_ID
                                                         AND T1.CL_VERSION =
                                                             T2.CL_VERSION) A1,
       TB_ORDER_EXECUTION T3,
       TB_TRADE TBT,
       TB_TRADE_SET TBTS
 WHERE A1. ORDER_ID = T3.CL_ORDER_ID
   AND T3.CL_TRADE_SET_ID = TBTS.CL_TRADE_SET_ID
   AND TBTS.CL_TRADE_SET_ID = TBT.CL_TRADE_SET_ID
   AND (A1. ENTERED_BY like 'DMA%' OR A1. ENTERED_BY like '%_PT')
   AND TBT.TIMESTAMP_1 > '20080101'
   AND TBT.TIMESTAMP_1 < '20080601'
 GROUP BY A1. ORDER_ID,
          A1. ENTERED_BY,
          A1. TOTAL_QTY,
          TBT.CL_BUY_SELL,
          TBT.CL_COUNTERPARTY_ID,
          TBT.CL_COUNTERPARTY_CODE,
          TBT.CL_MARKET_ID,
          CONVERT(varchar, TBT.TIMESTAMP_1, 112)
 ORDER BY A1. ENTERED_BY



===================================================================================================
Please run a Fidessa database query ASAP to find the following trade for ABN Amro Belgium from June 24th: 

Side: Sell 
Stock: LCY.AX 
Qty: 4000 
View code is ABNAMRBEL.EU 
we need to know who booked the trade down... -- JIRA:OMSREQ-122
===================================================================================================
SELECT RTB.*
FROM TB_ORDER TBO, 
    TB_ORDER_DETAIL TOD,
    TB_CURRENT_ORDER TBCO,
    RTB_ORDER_AUDIT_TRAIL RTB
WHERE TBO.CL_ORDER_ID = TBCO.CL_ORDER_ID AND
      TBO.CL_ORDER_ID = TOD.CL_ORDER_ID AND
      TBO.CL_VERSION = TBCO.CL_VERSION AND
      TBO.CL_ORDER_ID = RTB.ORDER_ID AND 
      TBO.CL_VERSION = RTB.VERSION AND
      TOD.CL_QUANTITY_FILLED=4000 AND 
      TBO.CL_BUY_SELL='S' AND
      TBO.CL_INSTRUMENT_CODE='LCY.AX' AND
      TBO.CL_COUNTERPARTY_CODE='ABNAMRBEL.EU' AND
      TBO.CL_COUNTERPARTY_CODE_TYPE='VIEW' AND
      CONVERT( VARCHAR(10), TBO.CL_ENTERED_DATETIME, 101 )= '06/24/2008' AND
      RTB.EVENT_TYPE = 'AGYE'


===================================================================================================
get all the duplicate isincodes for asian market
===================================================================================================

SELECT *
FROM STB_INSTRUMENT 
WHERE ISIN_CODE='JP3762600009'


SELECT * FROM ALT_INSTRUMENT_ID WHERE INSTRUMENT_ID IN('46369','47437','80693')

SELECT DISTINCT MARKET_ID,TRADED_CURRENCY,PRIMARY_BOOK FROM STB_MARKET_INSTRUMENT ORDER BY MARKET_ID



SELECT T1.[ISIN Code],T2.[Country],T2.[View Code]
FROM
(
SELECT S.ISIN_CODE "ISIN Code"
FROM STB_INSTRUMENT S,ALT_INSTRUMENT_ID A
WHERE S.INSTRUMENT_ID = A.INSTRUMENT_ID
AND (S.COUNTRY_OF_REGISTER IN('CN','HK','ID','ZA','TW','TH','SG','PH','NZ','MY','JP','AU') OR (S.COUNTRY_OF_REGISTER='IN' AND S.PRIMARY_EXCHANGE IN('BSE','NSI')))
AND A.ALTERNATE_TYPE ='ISIN'
AND A.MARKET_ID='INSTRUMENT'
GROUP BY S.ISIN_CODE
HAVING COUNT(*)>1
) T1
LEFT JOIN
(
SELECT S.ISIN_CODE "ISIN Code",
       S.INSTRUMENT_ID "Instrument",
       A.INSTRUMENT_CODE "View Code",
       S.COUNTRY_OF_REGISTER "Country"
FROM STB_INSTRUMENT S,ALT_INSTRUMENT_ID A, STB_MARKET_INSTRUMENT S1
WHERE S.INSTRUMENT_ID = A.INSTRUMENT_ID
AND S.INSTRUMENT_ID = S1.INSTRUMENT_ID
AND (S.COUNTRY_OF_REGISTER IN('CN','HK','ID','ZA','TW','TH','SG','PH','NZ','MY','JP','AU') OR (S.COUNTRY_OF_REGISTER='IN' AND S.PRIMARY_EXCHANGE IN('BSE','NSI')))
AND A.MARKET_ID='INSTRUMENT'
AND A.ALTERNATE_TYPE ='VIEW'
AND S1.STATUS = 'A'
AND A.INSTRUMENT_CODE NOT LIKE 'OLDSDM%'
group by S.ISIN_CODE,S.INSTRUMENT_ID,A.INSTRUMENT_CODE,S.COUNTRY_OF_REGISTER

) T2
ON T1.[ISIN Code]=T2.[ISIN Code]
GROUP BY T1.[ISIN Code],T2.[Country],T2.[View Code]



===================================================================================================
all basket orders with basket flag(BSK) status
===================================================================================================

SELECT DISTINCT 
       MBO.ORDER_ID "Order Id",
       TBO.CL_ENTERED_DATETIME"Entered Date",       
       MBA.ENTERED_BY_ID "User Id",
       TBO.CL_ENTERED_BY "User Name",
       TBO.CL_INSTRUMENT_CODE "Stock Code",
       TBO.CL_QUANTITY "Total Quantity",
       TOD.CL_QUANTITY_FILLED "Filled Quantity",
       TBO.CL_ORDER_FLAGS "Basket Flag",
       CASE
       WHEN TBO.CL_ORDER_FLAGS = 'BSK' OR TBO.CL_ORDER_FLAGS = 'BSK PTC' THEN
         'Yes'
       ELSE
         'No'
       END "BSK Flag Set",
       CASE
       WHEN TBO.CL_ORDER_FLAGS = 'PTC' OR TBO.CL_ORDER_FLAGS = 'BSK PTC' THEN
         'Yes'
       ELSE
         'No'
       END "PTC Flag Set",       
       CASE
       WHEN TBO.CL_ORDER_FLAGS = 'ARB' THEN
         'Yes'
       ELSE
         'No'
       END "ARB Flag Set"       
FROM TB_ORDER TBO,TB_ORDER_DETAIL TOD,MQ_BASKET_ORDER MBO,MQ_BASKET_AUDIT MBA
WHERE TBO.CL_ORDER_ID=TOD.CL_ORDER_ID
AND TBO.CL_ORDER_ID=MBO.ORDER_ID
AND MBO.BASKET_ID=MBA.BASKET_ID
AND MBA.VERSION =(SELECT MAX(MBA1.VERSION) FROM MQ_BASKET_AUDIT MBA1 WHERE MBA.BASKET_ID=MBA1.BASKET_ID)
AND TBO.CL_ORDER_CURRENCY='KRW'
AND MBA.ENTERED_DATETIME >'20080612 14:50:00'
AND MBA.ENTERED_DATETIME <'20080612 15:01:00'
ORDER BY TBO.CL_ORDER_ID,TBO.CL_VERSION


===================================================================================================
Audit FDA changes
===================================================================================================

SELECT case when ia.OPERATION='D' then case when ia.ENTITY='USER' then 'Deleted from STB_USER' else 'Deleted from '||ia.ENTITY end--'Record Deleted' 
            when ia.OPERATION='U' then case when ia.ENTITY='USER' then 'Updated from STB_USER' else 'Updated from '||ia.ENTITY end--'Record Updated' 
            when ia.OPERATION='I' then case when ia.ENTITY='USER' then 'Added to STB_USER' else 'Added to '||ia.ENTITY end--'Record Inserted' 
            else
              'Unknown User Action'
       end  "User Operation",
       ia.KEY_1 "User Id",
       (select USER_NAME from STB_USER where USER_ID=convert(int,ia.KEY_1)) "Group/User Name",
       case
       when (select PRIMARY_GROUP from STB_USER where USER_ID=convert(int,ia.KEY_1)) = null then
         (select DESCRIPTION from STB_USER where USER_ID=convert(int,ia.KEY_1))
       else
         (select FIRST_NAME||' '||LAST_NAME from STB_USER where USER_ID=convert(int,ia.KEY_1))
       end as "Description",
       isnull(ia.KEY_2,'') "Rights Type",
       isnull((select fDESCRIPTION from VALID_VALUES 
        WHERE CODE=ia.KEY_2
        AND FIELD='FUNCTION'),'') as "Rights Type Description",
       isnull(ia.KEY_3,'') "Rights Code",
        "Rights Code Description"=
        isnull(CASE --STB_RIGHTS.OMAR_FUNCTION - CASE 1
        WHEN(SELECT VV.fDESCRIPTION 
            FROM VALID_VALUES VV
            WHERE VV.CODE=ia.KEY_3 AND 
                  VV.FIELD=ia.KEY_2) 
        IS NULL THEN 
            (CASE --GROUP_ACCESS: STB_USER.USER_ID - CASE 2
             WHEN(SELECT SU.USER_NAME 
                FROM STB_USER SU
                WHERE SU.USER_TYPE='G' AND 
                convert(VARCHAR(10),SU.USER_ID)=ia.KEY_3) 
             IS NULL THEN 
                (CASE --BOOK_READ,BOOK_READ_GRANTED,BOOK_WRITE,BOOK_WRITE_GRANTED: BOOK.BOOK_ID - CASE 3
                 WHEN(SELECT B.fDESCRIPTION 
                    FROM BOOK B
                    WHERE B.BOOK_ID = ia.KEY_3 AND B.STATUS='A') 
                 IS NULL THEN
                    (CASE --ENTITY_VIEW: TRADING_ENTITY.TRADING_ENTITY_ID -- CASE 4
                     WHEN(SELECT TE.fDESCRIPTION 
                         FROM TRADING_ENTITY TE
                         WHERE TE.TRADING_ENTITY_ID=ia.KEY_3) 
                     IS NULL THEN
                        (CASE --ENTITY_VIEW: TRADING_ENTITY.TRADING_ENTITY_ID -- CASE 4a
                         WHEN(SELECT MKT.DESCRIPTION 
                             FROM STB_MARKET MKT
                             WHERE MKT.MARKET_ID=ia.KEY_3) 
                         IS NULL THEN                     
                            (CASE --EXECUTION_SERVICE: SERVICE.SERVICE_ID - CASE 5
                             WHEN(SELECT SER.fDESCRIPTION 
                                 FROM SERVICE SER
                                 WHERE SER.SERVICE_ID=ia.KEY_3) 
                             IS NULL THEN --BUSINESS_SECTOR: SECTOR.SECTOR_ID
                                (SELECT SEC.fDESCRIPTION 
                                 FROM SECTOR SEC
                                 WHERE SEC.SECTOR_ID=ia.KEY_3)
                             ELSE
                               (SELECT fDESCRIPTION FROM SERVICE WHERE SERVICE_ID=ia.KEY_3)
                             END
                            )-- CASE 5 - END
                         ELSE
                           (SELECT DESCRIPTION 
                             FROM STB_MARKET 
                             WHERE MARKET_ID=ia.KEY_3)
                         END
                        )-- CASE 4a - END                            
                     ELSE
                       (SELECT fDESCRIPTION 
                         FROM TRADING_ENTITY 
                         WHERE TRADING_ENTITY_ID=ia.KEY_3)
                     END
                    )-- CASE 4 - END
                 ELSE
                   (SELECT fDESCRIPTION FROM BOOK WHERE BOOK_ID = ia.KEY_3)
                 END
                )-- CASE 3 - END
             ELSE
               (SELECT USER_NAME FROM STB_USER WHERE USER_TYPE='G' AND convert(varchar(4),USER_ID)=ia.KEY_3)
             END
            )-- CASE 2 - END
        ELSE
        (SELECT fDESCRIPTION 
            FROM VALID_VALUES 
              WHERE CODE=ia.KEY_3 AND 
                FIELD=ia.KEY_2)
        END,''),-- CASE 1 - END
       ia.UPDATE_USER "FDA User",
       (SELECT FIRST_NAME||' '||LAST_NAME FROM STB_USER WHERE USER_NAME=ia.UPDATE_USER) "User Description",
       ia.UPDATE_DATE "Last Modified Date"
FROM iTB_audit ia
WHERE ia.ENTITY IN('STB_RIGHTS','USER')
AND ia.UPDATE_DATE >DATEADD(DD,-1,CONVERT(DATETIME,CONVERT(VARCHAR,GETDATE(),103)))
AND (1-sign( patindex( '%[^0-9.-]%', ia.KEY_1 ))) * (sign( patindex( '%[0-9]%', ia.KEY_1 ))) = 1
/*AND KEY_2 IN
(
	SELECT CODE FROM VALID_VALUES
	WHERE CODE IN
	(
		SELECT DISTINCT RIGHTS_TYPE
		FROM STB_RIGHTS
	)
	AND FIELD='FUNCTION'
)*/



===================================================================================================
For Production3 - table: PROD3_30_JUNE_LOGS
===================================================================================================

select TAG_52 "Date",
case when TAG_54 = "1" then 'Buy' 
else case when TAG_54 = "2" then 'Sell' 
else case when TAG_54 = "5" then 'Sell short' 
else "BLANK" end end end "Side", 
TAG_55 "Symbol",
TAG_38 "Quantity", TAG_15 "Currency",TAG_44 "Price",
TAG_14 "Executed Quantity", TAG_6 "Avg Price", 
case when TAG_39 = "0" then 'New Order' 
else case when TAG_39 = "1" then 'Partial Filled' 
else case when TAG_39 = "2" then 'Filled' 
else case when TAG_39 = "3" then 'Done for day' 
else case when TAG_39 = "4" then 'Canceled' 
else case when TAG_39 = "5" then 'Replaced' 
else case when TAG_39 = "8" then 'Rejected' 
else "BLANK" end end end end end end end "Order Status", 
case when TAG_39 = "0" then 'New Order' 
else case when TAG_35 = "8" then 'Execution Report' 
else case when TAG_35 = "9" then 'Order Cancel Reject' 
else case when TAG_35 = "F" then 'Order Cancel Request' 
else case when TAG_35 = "G" then 'Order Cancel/Replace Request' 
else case when TAG_35 = "J" then 'Allocation' 
else case when TAG_35 = "Q" then 'Don''t Know Trade' 
else "BLANK" end end end end end end end "Message Type", 
TAG_11 "ClientOrderID", TAG_37 "OrderID", 
TAG_109 "ClientID_109",
(SELECT CP.fDESCRIPTION
FROM ALT_COUNTERPARTY_ID ACI,COUNTERPARTY CP
WHERE ACI.COUNTERPARTY_ID = CP.COUNTERPARTY_ID
AND CP.COUNTERPARTY_TYPE='C' 
AND CP.STATUS='A'
AND ACI.ALTERNATE_TYPE='FIX' 
AND COUNTERPARTY_CODE=A.TAG_109) "ClientDescr1_109",
TAG_57 "ClientID_57",
(SELECT CP.fDESCRIPTION
FROM ALT_COUNTERPARTY_ID ACI,COUNTERPARTY CP
WHERE ACI.COUNTERPARTY_ID = CP.COUNTERPARTY_ID
AND CP.COUNTERPARTY_TYPE='C' 
AND CP.STATUS='A'
AND ACI.ALTERNATE_TYPE='FIX' 
AND COUNTERPARTY_CODE=A.TAG_57) "ClientDescr2_57",
TAG_128 "ClientID_128",
(SELECT CP.fDESCRIPTION
FROM ALT_COUNTERPARTY_ID ACI,COUNTERPARTY CP
WHERE ACI.COUNTERPARTY_ID = CP.COUNTERPARTY_ID
AND CP.COUNTERPARTY_TYPE='C' 
AND CP.STATUS='A'
AND ACI.ALTERNATE_TYPE='FIX' 
AND COUNTERPARTY_CODE=A.TAG_128) "ClientDescr3_128",
TAG_56 "ClientID_56",
(SELECT CP.fDESCRIPTION
FROM ALT_COUNTERPARTY_ID ACI,COUNTERPARTY CP
WHERE ACI.COUNTERPARTY_ID = CP.COUNTERPARTY_ID
AND CP.COUNTERPARTY_TYPE='C' 
AND CP.STATUS='A'
AND ACI.ALTERNATE_TYPE='FIX' 
AND COUNTERPARTY_CODE=A.TAG_56) "ClientDescr3_56",
TAG_58 'Remarks',
* from PROD3_30_JUNE_LOGS A where PKEY in 
(select max(PKEY) from PROD3_30_JUNE_LOGS B where B.TAG_37 = A.TAG_37)
and TAG_37 in (select distinct TAG_37 from PROD3_30_JUNE_LOGS where TAG_37 <> '')
and TAG_35 = '8'
and (
TAG_115 in ('ANDRINTL','ARTHINTL','BLKSIN40','BOSTINTL','BOSTINTL','BRCINTL','BROOINTL','FARANYFX',
'FRNKINTL','GEOSINTL','INDSIN42','INGINT42','KINGINTL','LBTYINTL','MERCINTL','NRTHINTL','OSPRINTL',
'PARTINTL','PEQTINTL','PERYIN42','SAVAINTL','TDJINTL','TORYINTL42','TRBCINTL','WESINT42','WILLIAM')
or TAG_109 in('ANDRINTL','ARTHINTL','BLKSIN40','BOSTINTL','BOSTINTL','BRCINTL','BROOINTL','FARANYFX',
'FRNKINTL','GEOSINTL','INDSIN42','INGINT42','KINGINTL','LBTYINTL','MERCINTL','NRTHINTL','OSPRINTL',
'PARTINTL','PEQTINTL','PERYIN42','SAVAINTL','TDJINTL','TORYINTL42','TRBCINTL','WESINT42','WILLIAM')
or TAG_128 in('ANDRINTL','ARTHINTL','BLKSIN40','BOSTINTL','BOSTINTL','BRCINTL','BROOINTL','FARANYFX',
'FRNKINTL','GEOSINTL','INDSIN42','INGINT42','KINGINTL','LBTYINTL','MERCINTL','NRTHINTL','OSPRINTL',
'PARTINTL','PEQTINTL','PERYIN42','SAVAINTL','TDJINTL','TORYINTL42','TRBCINTL','WESINT42','WILLIAM')
or   TAG_49 in('CFGLOBAL','DUQ','ENSO','FRONTP','IMPAL','INDUS','OAKTREE','VIKIN')
)


===================================================================================================
Korea orders (Korea order) from January ~ Jun, and they need detail below
===================================================================================================

SELECT T1.CL_ENTERED_DATETIME "Order Entered Date",    
       T1.CL_ORDER_ID "Order Id",
       T1.CL_INSTRUMENT_CODE "View Code",
       T1.CL_COUNTERPARTY_CODE "Client",
       isnull(T1.CUST_EXCHANGE_ACCOUNT_CODE,'') "Exchange Account Code",
       isnull(T1.MARKET_ID,'') "Market",
       CASE 
        WHEN T1.BUY_SELL_QUALIFIER <> '' THEN
         'Short Sell'
        ELSE
          CASE
            WHEN T1.CL_BUY_SELL = 'B' THEN
                "Buy"
            WHEN T1.CL_BUY_SELL = 'S' THEN
                "Sell"
          END
        END "Buy/Sell/Short Sell",
       T1.CL_ENTERED_BY "Entered By",   
       CASE
        WHEN UPPER(T1.CL_ENTERED_BY) LIKE '%DMA%' THEN
            "Y"
        ELSE
           ""
        END "DMA Order",
       CASE
        WHEN (UPPER(T1.CL_ENTERED_BY) LIKE '%DMA%' OR UPPER(T1.CL_ENTERED_BY) LIKE '%FIX_ORD%') THEN
            "Y"
        ELSE
            ""
        END "FIX Order",
       CASE
        WHEN UPPER(T1.CL_ENTERED_BY) LIKE '%_PT' THEN
            "Y"     
        ELSE
            ""
        END "Program Trading",
       CASE
        WHEN NOT(UPPER(T1.CL_ENTERED_BY) LIKE '%DMA%' OR UPPER(T1.CL_ENTERED_BY) LIKE '%FIX_ORD%' OR UPPER(T1.CL_ENTERED_BY) LIKE '%_PT') THEN
            "Y"     
        ELSE
            ""
        END "Manual Order"         
FROM TB_ORDER T1,TB_CURRENT_ORDER T2,TB_ORDER_DETAIL T3
WHERE T1.CL_ORDER_ID = T2.CL_ORDER_ID
AND T1.CL_ORDER_ID = T3.CL_ORDER_ID
AND T1.CL_VERSION = T2.CL_VERSION
AND T1.CL_ORDER_CURRENCY='KRW'
AND T1.CL_ENTERED_DATETIME > '20080101'
AND T1.CL_ENTERED_DATETIME < '20080201'



===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================




===================================================================================================

===================================================================================================



===================================================================================================

===================================================================================================