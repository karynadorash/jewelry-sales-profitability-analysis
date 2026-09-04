WITH ProductSales AS (
    SELECT
        p.NazwaTowaru AS ProductName,
        p.GrupaTowarowa AS ProductCategory,
        ROUND(SUM(f.LacznaKwota), 2) AS RevenuePLN
    FROM FactSprzedaz f
    JOIN DimProdukty p
        ON f.ID_Produktu = p.ID_Produktu
    GROUP BY
        p.NazwaTowaru,
        p.GrupaTowarowa
),
CumulativeShare AS (
    SELECT
        ProductName,
        ProductCategory,
        RevenuePLN,
        ROUND(
            SUM(RevenuePLN) OVER (
                ORDER BY RevenuePLN DESC, ProductName
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
            / SUM(RevenuePLN) OVER () * 100,
            2
        ) AS CumulativeRevenueSharePct
    FROM ProductSales
)
SELECT
    ProductName,
    ProductCategory,
    RevenuePLN,
    CumulativeRevenueSharePct,
    CASE
        WHEN CumulativeRevenueSharePct <= 80
            THEN 'Class A (Key 80%)'
        WHEN CumulativeRevenueSharePct <= 95
            THEN 'Class B (Next 15%)'
        ELSE 'Class C (Final 5%)'
    END AS ABCClass
FROM CumulativeShare
ORDER BY RevenuePLN DESC;