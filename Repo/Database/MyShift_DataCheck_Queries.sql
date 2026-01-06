SELECT * --lookup_id, field_name, field_value, descr, disp_descr, status, sort_order, create_dt, create_by, update_dt, update_by
	FROM eq.lookup

SELECT * --user_id, user_name, user_type_lkup_id, first_name, last_name, isactive, orig_id, hearus_lkup_id, referral, terms_accepted, create_dt, create_by, update_dt, update_by, phone_nbr, profession_lkup_id, profilepic_aws_key
	FROM eq.myshift_user
	where user_id in(177)
	
----------------------	
--Profile Tables Check
----------------------
SELECT * --profile_id, user_id, member_id, phone_nbr, alt_email, date_of_birth, years_of_exp, address1, address2, city, state, country, zipcode, workarea_lkup_id, flag_profile_info, flag_education, flag_license_lkup_id, flag_certify_lkup_id, flag_emr, flag_wrkexp, flag_reference, flag_profile_complete, create_dt, create_by, update_dt, update_by, resume_aws_key, bg_legal, bg_denied, bg_investigation, bg_defendant, bg_terminated, bg_performance, flag_license, flag_certify, flag_preference
	FROM eq.profile
	where user_id in(177)
	
SELECT * --prof_specialty_id, user_id, specialty_id, create_dt, create_by, update_dt, update_by
	FROM eq.prof_speciality
	where user_id in(177)
	
SELECT * --specialty_id, profession_lkup_id, specialty_name, descr, isactive, create_dt, create_by, update_dt, update_by
	FROM eq.specialty;	
	
SELECT * --prof_exp_id, user_id, start_date, end_date, position_title, empl_type_lkup_id, facility_name, facility_type, facility_location, unit, prim_specialty, charge_exp, shift_type_lkup_id, iscurrent, hrs_per_week, float_specialty, supervisor, exp_descr, create_dt, create_by, update_dt, update_by
	FROM eq.prof_experience
	where user_id in(177)
	
SELECT * --prof_education_id, user_id, degree_name, school_name, city, state, zipcode, start_date, graduation_date, create_dt, create_by, update_dt, update_by, country	
	FROM eq.prof_education
	where user_id in(177)	
	
SELECT * --prof_certificate_id, user_id, certificate_id, cert_exp_date, create_dt, create_by, update_dt, update_by, cert_aws_key, is_verified
	FROM eq.prof_certification
	where user_id in(177)	
	
SELECT * --certificate_id, certificate_name, descr, isactive, create_dt, create_by, update_dt, update_by
	FROM eq.certification	
	
SELECT * --prof_license_id, user_id, license_id, state, license_num, expiration_date, iscompact, create_dt, create_by, update_dt, update_by, license_aws_key, is_verified
	FROM eq.prof_license
	where user_id in(177)
	
SELECT * --license_id, profession_lkup_id, license_type, descr, isactive, create_dt, create_by, update_dt, update_by
	FROM eq.license;	
	
SELECT * --prof_emr_id, user_id, emr_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.prof_emr
	where user_id in(177)

SELECT * --prof_ref_id, user_id, ref_name, ref_position, ref_phone, ref_email, ref_relation, facility_name, start_date, end_date, create_dt, create_by, update_dt, update_by
	FROM eq.prof_references
	where user_id in(177)
		
SELECT * --profpref_cntrctdue_id, user_id, cntrctdur_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_cntrct_dur
	where user_id in(177)
	
SELECT * --profpref_shiftsched_id, user_id, shift_sched_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_shift_sched
	where user_id in(177)
	
SELECT * --profpref_shifttype_id, user_id, shifttype_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_shift_type
	where user_id in(177)
	
SELECT * --profpref_wrkhrs_id, user_id, wrkhrs_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_wrkhrs
	where user_id in(177)	
	
-- Not in use	
SELECT * --profpref_jobtype_id, user_id, jobtype_lkup_id
	FROM eq.prof_jobtype
	where user_id in(177)	
	
-- Not in use		
SELECT * --prof_onboard_id, user_id, vaccination, "TB_test", create_dt, create_by, update_dt, update_by
	FROM eq.prof_onboard
	where user_id in(177)	
	
----------------------	
--Shift Tables check
----------------------
SELECT * --shift_applied_id, user_id, shift_id, shift_apply_status_lkup_id, create_dt, createby_id, update_dt, updateby_id, reviewed_user_id, comments
	FROM eq.shift_applied 
	where user_id in(177)	
	
SELECT * --shift_bydate_id, shift_id, shift_date, create_dt, createby_id, update_dt, updateby_id
	FROM eq.shift_bydate 
	where shift_id in(177)	
	
SELECT * --shift_id, org_id, org_unit_id, shift_sched_lkup_id, start_date, dur_lkup_id, profession_lkup_id, specialty_id, pay_rate, shift_count, descr, start_time, end_time, "position", create_dt, create_by, update_dt, update_by, shift_type_lkup_id, pay_freq_lkup_id, shift_mon, shift_tue, shift_wed, shift_thu, shift_fri, shift_sat, shift_sun, createby_id, updateby_id, end_date, shift_status_lkup_id
	FROM eq.shift_defn 
	where shift_id in(146)

SELECT * --shift_swap_id, shift_user_id, shift_bydate_id, swapto_user_id, swapto_user_status, swap_reason, create_dt, createby_id, update_dt, updateby_id, swap_status, approved_manager_id
	FROM eq.shift_swap
	where shift_user_id in(177)	

SELECT * --shift_worked_id, shift_bydate_id, user_id, seq_nbr, shift_work_status_lkup_id, checkin_time, checkout_time, hrs_worked, pay_rate, pay_freq_lkup_id, pay_amount, pay_status_flag, create_dt, createby_id, update_dt, updateby_id, comments
	FROM eq.shift_worked 
	where user_id in(177)		
	
SELECT * --swap_accept_id, swap_id, receiver_user_id, swap_recv_status_lkup_id, createby_id, create_dt, updateby_id, update_dt, status_update_id, status_update_dt, receiver_accept_dt
	FROM eq.swap_accept;

SELECT swap_receiver_id, swap_id, receiver_user_id, swap_recv_status_lkup_id, createby_id, create_dt, updateby_id, update_dt
	FROM eq.swap_receiver;

SELECT * --swap_id, swap_user_id, shift_date_id, shift_id, request_date, swap_status_lkup_id, swap_reason_lkup_id, swap_reason, create_dt, createby_id, update_dt, updateby_id
	FROM eq.swap_request;

SELECT * --unit_id, unit_name, descr, isactive, create_dt, create_by, updte_dt, update_by
	FROM eq.unit;

SELECT * --user_role_id, user_id, role_id, org_id, create_dt, create_by, update_dt, update_by
	FROM eq.user_role;	