 WITH t1 AS (
         SELECT row_number() OVER (PARTITION BY pt.id ORDER BY m.create_date DESC) AS last_3_rank_status,
            pt.id,
            pt.name AS task_name,
            date(pt.create_date) AS task_create_date,
            date(m.create_date) AS msg_create_date,
            replace(replace(replace(replace(replace(replace(replace(replace(replace(m.body, '<p>'::text, ''::text), '</p>'::text, ''::text), '<span>'::text, ''::text), '</span>'::text, ''::text), '<b>'::text, ''::text), '</b>'::text, ''::text), '</div>'::text, ''::text), '<div>'::text, ''::text), 'amp;'::text, ''::text) AS msg_body,
            p.display_name AS msg_create_by,
            st.name AS sequence,
            pt.date_deadline,
            ptt.name AS stage,
            date(pt.date_last_stage_update) AS last_stage_update_date,
            u.name AS task_assign_to,
            u2.name AS reviewer
           FROM project_task pt
             LEFT JOIN mail_message m ON pt.name::text = m.record_name::text
             LEFT JOIN ir_sequence_type st ON pt.sequence = st.id
             LEFT JOIN project_task_type ptt ON pt.stage_id = ptt.id
             LEFT JOIN res_partner p ON m.author_id = p.id
             JOIN view_cjpl_user_name u ON u.id = pt.user_id
             JOIN view_cjpl_user_name u2 ON u2.id = pt.reviewer_id
          ORDER BY pt.id, date(m.create_date) DESC
        )
 SELECT t1.last_3_rank_status,
    t1.id,
    t1.task_name,
    t1.task_create_date,
    t1.msg_create_date,
    t1.msg_body,
    t1.msg_create_by,
    t1.sequence,
    t1.date_deadline,
    t1.stage,
    t1.last_stage_update_date,
    t1.task_assign_to,
    t1.reviewer
   FROM t1
  WHERE t1.last_3_rank_status < 4;