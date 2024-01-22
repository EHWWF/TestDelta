create or replace
VIEW prj_cost_probabilities_vw AS
SELECT prob.*,
       ROUND(100 * (preclinical/100) *
                   (phase1/100) *
                   (phase2/100) *
                   (phase3/100) *
                   (submission/100)) total
FROM (
SELECT project_id,
       SUM(CASE WHEN phase_code = '1' THEN probability END) preclinical,
       SUM(CASE WHEN phase_code = '2' THEN probability END) phase1,
       SUM(CASE WHEN phase_code = '34' THEN probability END) phase2,
       SUM(CASE WHEN phase_code = '5' THEN probability END) phase3,
       SUM(CASE WHEN phase_code = '6' THEN probability END) submission
FROM costs_probability
WHERE phase_code IN ('1', '2', '34', '5', '6')
GROUP BY project_id
) prob;