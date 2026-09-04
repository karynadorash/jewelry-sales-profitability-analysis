SELECT
    CASE
        WHEN LacznyRabat = 0 THEN '01. No discount (0%)'
        WHEN LacznyRabat <= 10 THEN '02. Low discount (1-10%)'
        WHEN LacznyRabat <= 25 THEN '03. Medium discount (11-25%)'
        ELSE '04. High discount (>25%)'
    END AS DiscountLevel,
    COUNT(DISTINCT ID_Transakcji) AS TransactionCount,
    ROUND(
        SUM(LacznaKwota) /
        NULLIF(COUNT(DISTINCT NumerParagonu), 0),
        2
    ) AS AverageBasketValuePLN,
    ROUND(SUM(LacznaKwota), 2) AS TotalRevenuePLN,
    ROUND(
        SUM(LacznaKwota - KosztWlasny),
        2
    ) AS GrossProfitPLN,
    ROUND(
        SUM(LacznaKwota - KosztWlasny) /
        NULLIF(SUM(LacznaKwota), 0) * 100,
        2
    ) AS GrossMarginPct
FROM FactSprzedaz
GROUP BY
    CASE
        WHEN LacznyRabat = 0 THEN '01. No discount (0%)'
        WHEN LacznyRabat <= 10 THEN '02. Low discount (1-10%)'
        WHEN LacznyRabat <= 25 THEN '03. Medium discount (11-25%)'
        ELSE '04. High discount (>25%)'
    END
ORDER BY DiscountLevel;