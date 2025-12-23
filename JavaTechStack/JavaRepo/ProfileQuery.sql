SELECT prfl.profile_id, prfl.alt_email, prfl.date_of_birth, prfl.years_of_exp, prfl.address1, 
prfl.address2, prfl.city, prfl.state, prfl.country, prfl.zipcode, 
prfl.workarea_lkup_id, 
prfl.flag_profile_info, prfl.flag_education, prfl.flag_license_lkup_id,prfl.flag_certify_lkup_id, 
prfl.flag_emr, prfl.flag_wrkexp, prfl.flag_reference, prfl.flag_profile_complete, 
prfl.resume_aws_key, prfl.bg_legal, prfl.bg_denied, prfl.bg_investigation,prfl.bg_defendant, 
prfl.bg_terminated, prfl.bg_performance, prfl.flag_license, prfl.flag_certify, prfl.flag_preference
	FROM eq.profile prfl where user_id in(139,143)
	
-- 	select COALESCE( prfl.flag_license_lkup_id, 0) 
-- 	from eq.profile prfl where user_id in(139,143)