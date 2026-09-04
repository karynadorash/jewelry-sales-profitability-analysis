WITH RankedProducts AS (
    SELECT
        p.GrupaTowarowa AS ProductCategory,
        p.NazwaTowaru AS ProductName,
        COUNT(DISTINCT f.ID_Transakcji) AS TransactionCount,
        ROUND(
            SUM(f.LacznaKwota),
            2
        ) AS RevenuePLN,
        ROUND(
            SUM(f.LacznaKwota - f.KosztWlasny),
            2
        ) AS GrossProfitPLN,
        DENSE_RANK() OVER (
            PARTITION BY p.GrupaTowarowa
            ORDER BY SUM(f.LacznaKwota - f.KosztWlasny) DESC
        ) AS CategoryRank
    FROM FactSprzedaz f
    JOIN DimProdukty p
        ON f.ID_Produktu = p.ID_Produktu
    GROUP BY
        p.GrupaTowarowa,
        p.NazwaTowaru
)
SELECT
    ProductCategory,
    CategoryRank,
    ProductName,
    TransactionCount,
    RevenuePLN,
    GrossProfitPLN
FROM RankedProducts
WHERE CategoryRank <= 3
ORDER BY
    ProductCategory,
    CategoryRank,
    GrossProfitPLN DESC;