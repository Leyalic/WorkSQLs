SELECT A.EMPLID,
   A.INSTITUTION,
   A.AID_YEAR,
   A.ACAD_CAREER,
   A.NAME
FROM PS_SFA_BPKG_BIND A,
   PS_SFA_BNSV_BIND B,
   PS_STDNT_FA_TERM C,
   PS_ISIR_CONTROL D,
   PS_STDNT_AID_ATRBT G,
   PS_ISIR_STUDENT H,
   PS_STDNT_BUDGET_IT J
WHERE (
      A.EMPLID = B.EMPLID
      AND A.INSTITUTION = B.INSTITUTION
      AND A.AID_YEAR = B.AID_YEAR
      AND A.EMPLID = C.EMPLID
      AND A.INSTITUTION = C.INSTITUTION
      AND A.AID_YEAR = C.AID_YEAR
      AND A.ACAD_CAREER = C.ACAD_CAREER
      AND C.EFFDT = (
         SELECT MAX(C_ED.EFFDT)
         FROM PS_STDNT_FA_TERM C_ED
         WHERE C.EMPLID = C_ED.EMPLID
            AND C.INSTITUTION = C_ED.INSTITUTION
            AND C.STRM = C_ED.STRM
            AND C_ED.EFFDT <= SYSDATE
      )
      AND C.EFFSEQ = (
         SELECT MAX(C_ES.EFFSEQ)
         FROM PS_STDNT_FA_TERM C_ES
         WHERE C.EMPLID = C_ES.EMPLID
            AND C.INSTITUTION = C_ES.INSTITUTION
            AND C.STRM = C_ES.STRM
            AND C.EFFDT = C_ES.EFFDT
      )
      AND C.STRM = '1' || SUBSTR(:1, -2) || '6'
      AND C.AID_YEAR = :1
      AND C.EFF_STATUS = 'A'
      AND (
         (
            C.ACADEMIC_LOAD <> 'N'
            AND C.TERM_SRC = 'T'
         )
         OR C.FORM_OF_STUDY = 'SMS'
      )
      AND C.ACAD_PLAN <> 'NON'
      AND C.EMPLID = D.EMPLID
      AND D.AID_YEAR = C.AID_YEAR
      AND D.EFFDT = (
         SELECT MAX(D_ED.EFFDT)
         FROM PS_ISIR_CONTROL D_ED
         WHERE D.EMPLID = D_ED.EMPLID
            AND D.INSTITUTION = D_ED.INSTITUTION
            AND D.AID_YEAR = D_ED.AID_YEAR
            AND D_ED.EFFDT <= SYSDATE
      )
      AND D.EFFSEQ = (
         SELECT MAX(D_ES.EFFSEQ)
         FROM PS_ISIR_CONTROL D_ES
         WHERE D.EMPLID = D_ES.EMPLID
            AND D.INSTITUTION = D_ES.INSTITUTION
            AND D.AID_YEAR = D_ES.AID_YEAR
            AND D.EFFDT = D_ES.EFFDT
      )
      AND D.EFC_STATUS = 'O'
      AND C.EMPLID = G.EMPLID
      AND G.AID_YEAR = C.AID_YEAR
      AND CASE
         WHEN (
            G.SSN_MATCH = ANY('0', '1', '2', '3', '5', '8', '9')
            AND G.SSA_CITIZEN_OVRD <> 'Y'
         ) THEN 0
         WHEN (
            G.SSA_CITIZENSHP_IND = ANY('E', 'F', 'N', 'D')
            AND G.SSA_CITIZEN_OVRD <> 'Y'
         ) THEN 0
         WHEN (
            (
               G.INS_MATCH = ANY('L', 'N', 'Z')
               OR G.ISIR_SEC_INS_MATCH = ANY('C', 'X', 'N', 'P')
            )
            AND G.INS_MATCH_OVRD <> 'Y'
         ) THEN 0
         WHEN (
            G.VA_MATCH = ANY('8', '2', '3')
            AND G.VA_MATCH_OVRD <> 'Y'
         ) THEN 0
         WHEN (
            G.NSLDS_MATCH = ANY('0', '2', '3', '4', '5', '8', '9')
            AND G.NSLDS_OVRD <> 'Y'
         ) THEN 0
         WHEN (
            (
               G.FATHER_SSN_MATCH = ANY('1', '2', '3', '5', '8')
               OR G.MOTHER_SSN_MATCH = ANY('1', '2', '3', '5', '8')
            )
            AND G.PAR_SSN_MATCH_OVRD <> 'Y'
            AND H.DEPNDNCY_STAT <> 'I'
         ) THEN 0
         ELSE 1
      END = '1'
      AND D.EMPLID = H.EMPLID
      AND D.INSTITUTION = H.INSTITUTION
      AND D.AID_YEAR = H.AID_YEAR
      AND D.EFFSEQ = H.EFFSEQ
      AND H.EFFDT = (
         SELECT MAX(H_ED.EFFDT)
         FROM PS_ISIR_STUDENT H_ED
         WHERE H.EMPLID = H_ED.EMPLID
            AND H.INSTITUTION = H_ED.INSTITUTION
            AND H.AID_YEAR = H_ED.AID_YEAR
            AND H_ED.EFFDT <= SYSDATE
      )
      AND H.EFFSEQ = (
         SELECT MAX(H_ES.EFFSEQ)
         FROM PS_ISIR_STUDENT H_ES
         WHERE H.EMPLID = H_ES.EMPLID
            AND H.INSTITUTION = H_ES.INSTITUTION
            AND H.AID_YEAR = H_ES.AID_YEAR
            AND H.EFFDT = H_ES.EFFDT
      )
      AND (
         EXISTS (
            SELECT 'X'
            FROM PS_STDNT_ENRL I
            WHERE I.EMPLID = A.EMPLID
               AND I.ACAD_CAREER = A.ACAD_CAREER
               AND I.STRM = C.STRM
         )
         OR C.FORM_OF_STUDY = 'SMS'
      )
      AND C.EMPLID = J.EMPLID
      AND C.STRM = J.STRM
      AND J.AID_YEAR = C.AID_YEAR
      AND J.ACAD_CAREER = C.ACAD_CAREER
      AND J.EFFDT = (
         SELECT MAX(J_ED.EFFDT)
         FROM PS_STDNT_BUDGET_IT J_ED
         WHERE J.EMPLID = J_ED.EMPLID
            AND J.INSTITUTION = J_ED.INSTITUTION
            AND J.AID_YEAR = J_ED.AID_YEAR
            AND J.ACAD_CAREER = J_ED.ACAD_CAREER
            AND J.STRM = J_ED.STRM
            AND J_ED.EFFDT <= SYSDATE
      )
      AND J.EFFSEQ = (
         SELECT MAX(J_ES.EFFSEQ)
         FROM PS_STDNT_BUDGET_IT J_ES
         WHERE J.EMPLID = J_ES.EMPLID
            AND J.INSTITUTION = J_ES.INSTITUTION
            AND J.AID_YEAR = J_ES.AID_YEAR
            AND J.ACAD_CAREER = J_ES.ACAD_CAREER
            AND J.STRM = J_ES.STRM
            AND J.EFFDT = J_ES.EFFDT
      )
      AND J.BUDGET_ITEM_AMOUNT > 0
      AND J.BGT_ITEM_CATEGORY = 'TUIT'
      AND NOT EXISTS (
         SELECT 'X'
         FROM PS_SRVC_IND_DATA K
         WHERE K.EMPLID = A.EMPLID
            AND K.SRVC_IND_CD = 'FST'
      )
      AND NOT EXISTS (
         SELECT 'X'
         FROM PS_PERSON_CHECKLST L,
            PS_VAR_DATA_FINA M
         WHERE L.COMMON_ID = A.EMPLID
            AND L.COMMON_ID = M.COMMON_ID
            AND M.VAR_DATA_SEQ = L.VAR_DATA_SEQ
            AND M.AID_YEAR = A.AID_YEAR
            AND L.CHECKLIST_CD = ANY('FCLREG', 'FCLVER')
            AND L.CHECKLIST_STATUS = 'I'
      )
      AND NOT EXISTS (
         SELECT 'X'
         FROM PS_COMMUNICATION E,
            PS_VAR_DATA_FINA F
         WHERE E.COMMON_ID = A.EMPLID
            AND E.SCC_LETTER_CD = ANY('FAU', 'FUF', 'FUL')
            AND E.COMMON_ID = F.COMMON_ID
            AND F.VAR_DATA_SEQ = E.VAR_DATA_SEQ
            AND F.AID_YEAR = A.AID_YEAR
      )
      AND NOT EXISTS (
         SELECT 'X'
         FROM PS_STDNT_AGGR_LIFE N,
            PS_STDNT_FA_TERM O
         WHERE N.AGGREGATE_AREA = 'PELL'
            AND N.SFA_LEU_NSLDS >= 450
            AND O.ACAD_CAREER = 'U'
            AND N.EMPLID = A.EMPLID
            AND N.AID_YEAR = A.AID_YEAR
            AND N.EMPLID = O.EMPLID
            AND N.AID_YEAR = O.AID_YEAR
            AND O.EFFDT = (
               SELECT MAX(O_ED.EFFDT)
               FROM PS_STDNT_FA_TERM O_ED
               WHERE O.EMPLID = O_ED.EMPLID
                  AND O.INSTITUTION = O_ED.INSTITUTION
                  AND O.STRM = O_ED.STRM
                  AND O_ED.EFFDT <= SYSDATE
            )
            AND O.EFFSEQ = (
               SELECT MAX(O_ES.EFFSEQ)
               FROM PS_STDNT_FA_TERM O_ES
               WHERE O.EMPLID = O_ES.EMPLID
                  AND O.INSTITUTION = O_ES.INSTITUTION
                  AND O.STRM = O_ES.STRM
                  AND O.EFFDT = O_ES.EFFDT
            )
            AND O.STRM = C.STRM
      )
      AND NOT EXISTS (
         SELECT 'X'
         FROM PS_STDNT_FA_MSGS P
         WHERE P.EMPLID = A.EMPLID
            AND P.AID_YEAR = A.AID_YEAR
            AND P.EDIT_MSG_CD = ANY('ISIRVW', 'NOPKG')
      )
      AND NOT EXISTS (
         SELECT 'X'
         FROM PS_STDNT_AWD_PER Q
         WHERE Q.EMPLID = A.EMPLID
            AND Q.AID_YEAR = A.AID_YEAR
            AND Q.AWARD_PERIOD = 'N'
            AND Q.FED_OVRAWD_AMT > 0
      )
   )