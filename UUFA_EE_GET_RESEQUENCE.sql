SELECT ITEM_TYPE,
    ACAD_CAREER,
    PKG_SEQ_NBR,
    NEW_SEQ
FROM (
        SELECT A.ITEM_TYPE,
            A.ACAD_CAREER,
            A.PKG_SEQ_NBR,
            (
                (
                    RANK() OVER (
                        PARTITION BY A.AID_YEAR
                        ORDER BY CASE
                                WHEN A.ACAD_CAREER = 'U' THEN 1
                                WHEN A.ACAD_CAREER = 'G' THEN 2
                                WHEN A.ACAD_CAREER = 'D' THEN 3
                                WHEN A.ACAD_CAREER = 'L' THEN 4
                                ELSE 5
                            END,
                            CASE
                                WHEN A.OFFER_AMOUNT > 0 THEN 1
                                ELSE 2
                            END,
                            CASE
                                WHEN A.DISBURSEMENT_PLAN IN (
                                    SELECT DISTINCT DP1.DISBURSEMENT_PLAN
                                    FROM PS_DISB_ID_TBL DP1
                                    WHERE (
                                            DP1.STRM = '1' || SUBSTR(A.AID_YEAR, -2) -1 || '8'
                                        )
                                ) THEN 1
                                WHEN A.DISBURSEMENT_PLAN IN (
                                    SELECT DISTINCT DP2.DISBURSEMENT_PLAN
                                    FROM PS_DISB_ID_TBL DP2
                                    WHERE (DP2.STRM = '1' || SUBSTR(A.AID_YEAR, -2) || '4')
                                ) THEN 1
                                WHEN A.DISBURSEMENT_PLAN IN (
                                    SELECT DISTINCT DP3.DISBURSEMENT_PLAN
                                    FROM PS_DISB_ID_TBL DP3
                                    WHERE (DP3.STRM = '1' || SUBSTR(A.AID_YEAR, -2) || '6')
                                ) THEN 3
                                ELSE 4
                            END,
                            CASE
                                WHEN B.FIN_AID_TYPE = 'V' THEN 1
                                WHEN B.FIN_AID_TYPE = 'A' THEN 5
                                WHEN B.FEDERAL_ID = 'PELL' THEN 10
                                WHEN B.FIN_AID_TYPE = 'S' THEN 15
                                WHEN B.FIN_AID_TYPE = 'G' THEN 20
                                WHEN B.FIN_AID_TYPE = 'W' THEN 25
                                WHEN B.FEDERAL_ID = 'STFS' THEN 30
                                WHEN B.FIN_AID_TYPE = 'L' AND B.NEED_BASED = 'Y' THEN 35
                                WHEN B.FIN_AID_TYPE = 'L' AND B.FA_SOURCE = 'I' THEN 40
                                WHEN B.FEDERAL_ID = 'STFU' THEN 45
                                WHEN B.FEDERAL_ID = 'PLUS' THEN 50
                                WHEN B.FEDERAL_ID = 'GPLS' THEN 55
                                WHEN B.FIN_AID_TYPE = 'L' AND B.FA_SOURCE = 'P' THEN 60
                                ELSE 100
                            END,
                            A.PKG_SEQ_NBR / 10
                    )
                ) * 10
            ) as NEW_SEQ
        FROM PS_STDNT_AWARDS A,
            PS_ITEM_TYPE_FA B
        WHERE (
                A.AID_YEAR = B.AID_YEAR
                AND A.ITEM_TYPE = B.ITEM_TYPE
                AND B.EFFDT = (
                    SELECT MAX(B_ED.EFFDT)
                    FROM PS_ITEM_TYPE_FA B_ED
                    WHERE B.SETID = B_ED.SETID
                        AND B.ITEM_TYPE = B_ED.ITEM_TYPE
                        AND B.AID_YEAR = B_ED.AID_YEAR
                        AND B_ED.EFFDT <= SYSDATE
                )
                AND A.EMPLID = :1
                AND A.AID_YEAR = :2
            )
    )