SELECT
    f.KategoriaWagowa AS WeightCategory,
    p.TypMetalu AS MetalType,
    COUNT(DISTINCT f.ID_Transakcji) AS TransactionCount,
    ROUND(
        SUM(f.Waga),
        2
    ) AS TotalWeightGrams,
    ROUND(
        SUM(f.LacznaKwota) /
        NULLIF(SUM(f.Waga), 0),
        2
    ) AS RevenuePerGramPLN,
    ROUND(
        SUM(f.LacznaKwota),
        2
    ) AS RevenuePLN,
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
JOIN DimProdukty p
    ON f.ID_Produktu = p.ID_Produktu
WHERE f.Waga > 0
GROUP BY
    f.KategoriaWagowa,
    p.TypMetalu
ORDER BY
    MetalType,
    GrossMarginPct DESC;