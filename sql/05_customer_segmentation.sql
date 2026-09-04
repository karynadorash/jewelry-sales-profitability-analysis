SELECT
    COALESCE(
        f.SegmentKlienta,
        'Unspecified'
    ) AS CustomerSegment,
    COUNT(DISTINCT f.NumerParagonu) AS UniqueReceiptCount,
    COUNT(DISTINCT f.ID_Transakcji) AS TransactionCount,
    ROUND(
        SUM(f.LacznaKwota) /
        NULLIF(COUNT(DISTINCT f.NumerParagonu), 0),
        2
    ) AS AverageBasketValuePLN,
    ROUND(
        SUM(f.LacznaKwota),
        2
    ) AS TotalRevenuePLN,
    ROUND(
        SUM(f.LacznaKwota - f.KosztWlasny),
        2
    ) AS GrossProfitPLN,
    ROUND(
        SUM(f.LacznaKwota - f.KosztWlasny) /
        NULLIF(SUM(f.LacznaKwota), 0) * 100,
        2
    ) AS GrossMarginPct
FROM FactSprzedaz f
GROUP BY
    f.SegmentKlienta
ORDER BY
    TotalRevenuePLN DESC;