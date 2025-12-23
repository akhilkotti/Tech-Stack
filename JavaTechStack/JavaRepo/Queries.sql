SELECT lookup_id, field_name, field_value, descr, disp_descr, status, sort_order, create_dt, create_by, update_dt, update_by
	FROM eq.lookup order by field_name

SELECT distinct field_name FROM eq.lookup order by field_name

SELECT field_name,field_value
	FROM eq.lookup where field_name in('USER_TYPE')
	and status = 'A'
  
===========================================================
SELECT certificate_id, certificate_name, descr, isactive, create_dt, create_by, update_dt, update_by
	FROM eq.certification;
	
SELECT contact_id, first_name, last_name, org_name, email, create_dt, create_by, update_dt, update_by, phone
	FROM eq.contact_us;
	
SELECT contact_id, first_name, last_name, org_name, org_role, email, phone, org_website, org_size, comments, create_dt, create_by, reason
	FROM eq.equitek_contact_us;
	
SELECT license_id, profession_lkup_id, license_type, descr, isactive, create_dt, create_by, update_dt, update_by
	FROM eq.license;
	
SELECT lookup_id, field_name, field_value, descr, disp_descr, status, sort_order, create_dt, create_by, update_dt, update_by
	FROM eq.lookup;
	
SELECT user_id, user_name, user_type_lkup_id, first_name, last_name, isactive, orig_id, hearus_lkup_id, referral, terms_accepted, create_dt, create_by, update_dt, update_by, phone_nbr, profession_lkup_id, profilepic_aws_key
	FROM eq.myshift_user;
	
SELECT org_id, org_name, parent_org_id, org_type_lkup_id, org_size, email, phone1, phone1_ext, phone2, phone2_ext, web_url, time_zone, pref_language, is_active, address1, address2, city, state, country, zipcode, create_dt, create_by, update_dt, update_by
	FROM eq.org;	
	
SELECT org_parent_id, org_parent_name, org_descr, zone, create_dt, create_by, update_dt, update_by
	FROM eq.org_parent;
	
SELECT org_unit_id, org_id, unit_id, isactive, create_dt, create_by, update_dt, update_by, unit_name, descr
	FROM eq.org_unit;
	
SELECT prof_certificate_id, user_id, certificate_id, cert_exp_date, create_dt, create_by, update_dt, update_by, cert_aws_key, is_verified
	FROM eq.prof_certification;
	
SELECT prof_education_id, user_id, degree_name, school_name, city, state, zipcode, start_date, graduation_date, create_dt, create_by, update_dt, update_by, country	FROM eq.prof_education;

SELECT prof_emr_id, user_id, emr_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.prof_emr;
	
SELECT prof_exp_id, user_id, start_date, end_date, position_title, empl_type_lkup_id, facility_name, facility_type, facility_location, unit, prim_specialty, charge_exp, shift_type_lkup_id, iscurrent, hrs_per_week, float_specialty, supervisor, exp_descr, create_dt, create_by, update_dt, update_by
	FROM eq.prof_experience;	
	
SELECT profpref_jobtype_id, user_id, jobtype_lkup_id
	FROM eq.prof_jobtype;	
	
SELECT prof_license_id, user_id, license_id, state, license_num, expiration_date, iscompact, create_dt, create_by, update_dt, update_by, license_aws_key, is_verified
	FROM eq.prof_license;	
	
SELECT prof_onboard_id, user_id, vaccination, "TB_test", create_dt, create_by, update_dt, update_by
	FROM eq.prof_onboard;	
	
SELECT prof_ref_id, user_id, ref_name, ref_position, ref_phone, ref_email, ref_relation, facility_name, start_date, end_date, create_dt, create_by, update_dt, update_by
	FROM eq.prof_references;	
	
SELECT prof_specialty_id, user_id, specialty_id, create_dt, create_by, update_dt, update_by
	FROM eq.prof_speciality;	
	
SELECT profile_id, user_id, member_id, phone_nbr, alt_email, date_of_birth, years_of_exp, address1, address2, city, state, country, zipcode, workarea_lkup_id, flag_profile_info, flag_education, flag_license_lkup_id, flag_certify_lkup_id, flag_emr, flag_wrkexp, flag_reference, flag_profile_complete, create_dt, create_by, update_dt, update_by, resume_aws_key, bg_legal, bg_denied, bg_investigation, bg_defendant, bg_terminated, bg_performance, flag_license, flag_certify, flag_preference
	FROM eq.profile;	
	
SELECT profpref_cntrctdue_id, user_id, cntrctdur_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_cntrct_dur;
	
SELECT profpref_shiftsched_id, user_id, shift_sched_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_shift_sched;
	
SELECT profpref_shifttype_id, user_id, shifttype_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_shift_type;
	
SELECT profpref_wrkhrs_id, user_id, wrkhrs_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_wrkhrs;	
	
SELECT role_id, role_name, disp_name, org_descr, sort_order, create_dt, create_by, update_dt, update_by
	FROM eq.role;

SELECT shift_applied_id, user_id, shift_id, shift_apply_status_lkup_id, create_dt, createby_id, update_dt, updateby_id, reviewed_user_id, comments
	FROM eq.shift_applied;

SELECT shift_bydate_id, shift_id, shift_date, create_dt, createby_id, update_dt, updateby_id
	FROM eq.shift_bydate;

SELECT shift_id, org_id, org_unit_id, shift_sched_lkup_id, start_date, dur_lkup_id, profession_lkup_id, specialty_id, pay_rate, shift_count, descr, start_time, end_time, "position", create_dt, create_by, update_dt, update_by, shift_type_lkup_id, pay_freq_lkup_id, shift_mon, shift_tue, shift_wed, shift_thu, shift_fri, shift_sat, shift_sun, createby_id, updateby_id, end_date, shift_status_lkup_id
	FROM eq.shift_defn;

SELECT shift_swap_id, shift_user_id, shift_bydate_id, swapto_user_id, swapto_user_status, swap_reason, create_dt, createby_id, update_dt, updateby_id, swap_status, approved_manager_id
	FROM eq.shift_swap;

SELECT shift_worked_id, shift_bydate_id, user_id, seq_nbr, shift_work_status_lkup_id, checkin_time, checkout_time, hrs_worked, pay_rate, pay_freq_lkup_id, pay_amount, pay_status_flag, create_dt, createby_id, update_dt, updateby_id, comments
	FROM eq.shift_worked;

SELECT specialty_id, profession_lkup_id, specialty_name, descr, isactive, create_dt, create_by, update_dt, update_by
	FROM eq.specialty;

SELECT swap_accept_id, swap_id, receiver_user_id, swap_recv_status_lkup_id, createby_id, create_dt, updateby_id, update_dt, status_update_id, status_update_dt, receiver_accept_dt
	FROM eq.swap_accept;

SELECT swap_receiver_id, swap_id, receiver_user_id, swap_recv_status_lkup_id, createby_id, create_dt, updateby_id, update_dt
	FROM eq.swap_receiver;

SELECT swap_id, swap_user_id, shift_date_id, shift_id, request_date, swap_status_lkup_id, swap_reason_lkup_id, swap_reason, create_dt, createby_id, update_dt, updateby_id
	FROM eq.swap_request;

SELECT unit_id, unit_name, descr, isactive, create_dt, create_by, updte_dt, update_by
	FROM eq.unit;

SELECT user_role_id, user_id, role_id, org_id, create_dt, create_by, update_dt, update_by
	FROM eq.user_role;

SELECT shift_applied_id, user_id, shift_id, shift_apply_status_lkup_id, create_dt, create_by, update_dt, update_by, update_user_id
	FROM eq.xx_shift_apply;
=================================================================================================================================
Shift Queries---------------------------------------------------------------

SELECT shift_applied_id, user_id, shift_id, shift_apply_status_lkup_id, create_dt, createby_id, update_dt, updateby_id, reviewed_user_id, comments
	FROM eq.shift_applied where user_id in(143)	
	
SELECT shift_bydate_id, shift_id, shift_date, create_dt, createby_id, update_dt, updateby_id
	FROM eq.shift_bydate where shift_id in(146)

SELECT shift_id, org_id, org_unit_id, shift_sched_lkup_id, start_date, dur_lkup_id, profession_lkup_id, specialty_id, pay_rate, shift_count, descr, start_time, end_time, "position", create_dt, create_by, update_dt, update_by, shift_type_lkup_id, pay_freq_lkup_id, shift_mon, shift_tue, shift_wed, shift_thu, shift_fri, shift_sat, shift_sun, createby_id, updateby_id, end_date, shift_status_lkup_id
	FROM eq.shift_defn where shift_id in(146)

SELECT shift_swap_id, shift_user_id, shift_bydate_id, swapto_user_id, swapto_user_status, swap_reason, create_dt, createby_id, update_dt, updateby_id, swap_status, approved_manager_id
	FROM eq.shift_swap;

SELECT shift_worked_id, shift_bydate_id, user_id, seq_nbr, shift_work_status_lkup_id, checkin_time, checkout_time, hrs_worked, pay_rate, pay_freq_lkup_id, pay_amount, pay_status_flag, create_dt, createby_id, update_dt, updateby_id, comments
	FROM eq.shift_worked;
	
SELECT swap_accept_id, swap_id, receiver_user_id, swap_recv_status_lkup_id, createby_id, create_dt, updateby_id, update_dt, status_update_id, status_update_dt, receiver_accept_dt
	FROM eq.swap_accept;

SELECT swap_receiver_id, swap_id, receiver_user_id, swap_recv_status_lkup_id, createby_id, create_dt, updateby_id, update_dt
	FROM eq.swap_receiver;

SELECT swap_id, swap_user_id, shift_date_id, shift_id, request_date, swap_status_lkup_id, swap_reason_lkup_id, swap_reason, create_dt, createby_id, update_dt, updateby_id
	FROM eq.swap_request;

SELECT unit_id, unit_name, descr, isactive, create_dt, create_by, updte_dt, update_by
	FROM eq.unit;

SELECT user_role_id, user_id, role_id, org_id, create_dt, create_by, update_dt, update_by
	FROM eq.user_role;

SELECT shift_applied_id, user_id, shift_id, shift_apply_status_lkup_id, create_dt, create_by, update_dt, update_by, update_user_id
	FROM eq.xx_shift_apply;	
	
Profile Queries---------------------------------------------------------------
	
	SELECT profile_id, user_id, member_id, phone_nbr, alt_email, date_of_birth, years_of_exp, address1, address2, city, state, country, zipcode, workarea_lkup_id, flag_profile_info, flag_education, flag_license_lkup_id, flag_certify_lkup_id, flag_emr, flag_wrkexp, flag_reference, flag_profile_complete, create_dt, create_by, update_dt, update_by, resume_aws_key, bg_legal, bg_denied, bg_investigation, bg_defendant, bg_terminated, bg_performance, flag_license, flag_certify, flag_preference
	FROM eq.profile where user_id in(143)	
	
SELECT prof_specialty_id, user_id, specialty_id, create_dt, create_by, update_dt, update_by
	FROM eq.prof_speciality where user_id in(143)
	
SELECT specialty_id, profession_lkup_id, specialty_name, descr, isactive, create_dt, create_by, update_dt, update_by
	FROM eq.specialty;	
	
SELECT certificate_id, certificate_name, descr, isactive, create_dt, create_by, update_dt, update_by
	FROM eq.certification;	
	
SELECT prof_certificate_id, user_id, certificate_id, cert_exp_date, create_dt, create_by, update_dt, update_by, cert_aws_key, is_verified
	FROM eq.prof_certification where user_id in(143)
	
SELECT prof_education_id, user_id, degree_name, school_name, city, state, zipcode, start_date, graduation_date, create_dt, create_by, update_dt, update_by, country	
FROM eq.prof_education where user_id in(143)

SELECT prof_emr_id, user_id, emr_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.prof_emr where user_id in(143)
	
SELECT prof_exp_id, user_id, start_date, end_date, position_title, empl_type_lkup_id, facility_name, facility_type, facility_location, unit, prim_specialty, charge_exp, shift_type_lkup_id, iscurrent, hrs_per_week, float_specialty, supervisor, exp_descr, create_dt, create_by, update_dt, update_by
	FROM eq.prof_experience where user_id in(143)
	
SELECT profpref_jobtype_id, user_id, jobtype_lkup_id
	FROM eq.prof_jobtype where user_id in(143)
	
SELECT prof_license_id, user_id, license_id, state, license_num, expiration_date, iscompact, create_dt, create_by, update_dt, update_by, license_aws_key, is_verified
	FROM eq.prof_license where user_id in(143)	
	
SELECT license_id, profession_lkup_id, license_type, descr, isactive, create_dt, create_by, update_dt, update_by
	FROM eq.license;	
	
SELECT prof_onboard_id, user_id, vaccination, "TB_test", create_dt, create_by, update_dt, update_by
	FROM eq.prof_onboard where user_id in(143)	
	
SELECT prof_ref_id, user_id, ref_name, ref_position, ref_phone, ref_email, ref_relation, facility_name, start_date, end_date, create_dt, create_by, update_dt, update_by
	FROM eq.prof_references where user_id in(143)	
	
SELECT prof_specialty_id, user_id, specialty_id, create_dt, create_by, update_dt, update_by
	FROM eq.prof_speciality where user_id in(143)	
	
SELECT profpref_cntrctdue_id, user_id, cntrctdur_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_cntrct_dur where user_id in(143)
	
SELECT profpref_shiftsched_id, user_id, shift_sched_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_shift_sched where user_id in(143)
	
SELECT profpref_shifttype_id, user_id, shifttype_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_shift_type where user_id in(143)
	
SELECT profpref_wrkhrs_id, user_id, wrkhrs_lkup_id, create_dt, create_by, update_dt, update_by
	FROM eq.profpref_wrkhrs where user_id in(143)	
	
	-----------------------------------------------
	
	SELECT user_id, user_name, user_type_lkup_id, first_name, last_name, isactive, orig_id, hearus_lkup_id, referral, terms_accepted, create_dt, create_by, update_dt, update_by, phone_nbr, profession_lkup_id, profilepic_aws_key
	FROM eq.myshift_user where user_name like 'ak%'	

	SELECT user_id, user_name, user_type_lkup_id, first_name, last_name, isactive, orig_id, hearus_lkup_id, referral, terms_accepted, create_dt, create_by, update_dt, update_by, phone_nbr, profession_lkup_id, profilepic_aws_key
	FROM eq.myshift_user where user_id=142
	
SELECT splty.profession_lkup_id, profsplty.user_id,
		string_agg(splty.specialty_name::text, ', ') AS spclty_name_list,
		string_agg(splty.descr::text, ', ') AS spclty_descr_list
		FROM eq.specialty splty,eq.prof_speciality profsplty
		where splty.specialty_id = profsplty.specialty_id
		and profsplty.user_id = 139
		GROUP  BY splty.profession_lkup_id,profsplty.user_id
		
	
		
	
	
















	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	