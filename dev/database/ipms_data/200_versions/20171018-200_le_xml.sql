alter table latest_estimate add (
	study_name nvarchar2(180),
	study_phase nvarchar2(90),
	study_fpfv date,
	study_lplv date,
	curr_forecast nvarchar2(20),
	curr_act_det number,--act_det
	curr_bgt_det number,--bgt_det
	curr_fct_det number,--fct_det
	curr_rr_det number,--rr_det
	curr_bgt_prob number,--bgt_prob
	curr_fct_prob number,--fct_prob
	curr_cfct_prob number,--cfct_prob
	curr_fps_est_c number,--fps_est_c
	curr_fps_est_u number,--fps_est_u
	curr_fps_est_t number,--fps_est_t
	next_forecast nvarchar2(20),--
	next_bgt_det number,--bgt_det
	next_fct_det number,--fct_det
	next_bgt_prob number,--bgt_prob
	next_fct_prob number,--fct_prob
	next_cfct_prob number,--cfct_prob
	next_fps_est_c number,--fps_est_c
	next_fps_est_u number,--fps_est_u
	next_fps_est_t number--fps_est_t
);
update latest_estimate le set 
	le.study_name = extractvalue(le.details,'//study/name'),
	le.study_phase = extractvalue(le.details,'//study/phase'),
	le.study_fpfv = to_date(extractvalue(le.details,'//study/fpfv'),'yyyy-mm-dd"T"hh24:mi:ss'),
	le.study_lplv = to_date(extractvalue(le.details,'//study/lplv'),'yyyy-mm-dd"T"hh24:mi:ss'),
	le.curr_forecast = extractvalue(le.details,'//costs/current/@forecast'),
	le.curr_act_det = get_number(extractvalue(le.details,'//costs/current/act_det')),--act_det
	le.curr_bgt_det = get_number(extractvalue(le.details,'//costs/current/bgt_det')),--bgt_det
	le.curr_fct_det = get_number(extractvalue(le.details,'//costs/current/fct_det')),--fct_det
	le.curr_rr_det = get_number(extractvalue(le.details,'//costs/current/rr_det')),--rr_det
	le.curr_bgt_prob = get_number(extractvalue(le.details,'//costs/current/bgt_prob')),--bgt_prob
	le.curr_fct_prob = get_number(extractvalue(le.details,'//costs/current/fct_prob')),--fct_prob
	le.curr_cfct_prob = get_number(extractvalue(le.details,'//costs/current/cfct_prob')),--cfct_prob
	le.curr_fps_est_c = get_number(extractvalue(le.details,'//costs/current/fps_est_c')),--fps_est_c
	le.curr_fps_est_u = get_number(extractvalue(le.details,'//costs/current/fps_est_u')),--fps_est_u
	le.curr_fps_est_t = get_number(extractvalue(le.details,'//costs/current/fps_est_t')),--fps_est_t
	le.next_forecast = extractvalue(le.details,'//costs/next/@forecast'),
	le.next_bgt_det = get_number(extractvalue(le.details,'//costs/next/bgt_det')),--bgt_det
	le.next_fct_det = get_number(extractvalue(le.details,'//costs/next/fct_det')),--fct_det
	le.next_bgt_prob = get_number(extractvalue(le.details,'//costs/next/bgt_prob')),--bgt_prob
	le.next_fct_prob = get_number(extractvalue(le.details,'//costs/next/fct_prob')),--fct_prob
	le.next_cfct_prob = get_number(extractvalue(le.details,'//costs/next/cfct_prob')),--cfct_prob
	le.next_fps_est_c = get_number(extractvalue(le.details,'//costs/next/fps_est_c')),--fps_est_c
	le.next_fps_est_u = get_number(extractvalue(le.details,'//costs/next/fps_est_u')),--fps_est_u
	le.next_fps_est_t = get_number(extractvalue(le.details,'//costs/next/fps_est_t'))--fps_est_t
;
commit;