select
  (select count(*) from districts where status = 0) as districts,
  (select count(*) from users where access >= 0) as users,
  (select count(distinct user_id) from notices) as active,
  (select count(*) from notices where status = 3) as shared,
  (select count(*) from active_storage_attachments where record_type = 'Notice') as photos;
