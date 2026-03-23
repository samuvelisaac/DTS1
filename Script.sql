--UI
select * from clarity.client; --20-apr-2026
select * from clarity.bin;
select * from clarity.limit;
--trigger-> Development in progress
select * from clarity.job_master; --Triggering Every monday
--trigger-> 
select * from clarity.job_workflow;


select client_id, inhouse_datacenter, core_processor from clarity.client; --20-apr-2026


update clarity.job_master
   set planned_date = CURRENT_TIMESTAMP, --2026-02-23 00:00:00.000
       time_of_day = '00:05:00' --20:00:00
-- where client_id = (select MAX(client_id) from clarity.job_master);
 where client_id in(170,171,174,175);

alter table clarity.test_job_master
  add column day_of_week TEXT CHECK (UPPER(day_of_week) IN ('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY')),
  add column time_of_day TIME,
  add column planned_date TIMESTAMP,
  add column action_date TIMESTAMP
;

select * from clarity.weekly_forms where ticket_name = 'Go-Live';
--insert into clarity.weekly_forms select week_no, 'APCNFCOM NRC_HORIZON.xlsx' as form_name, ticket_name from clarity.weekly_forms where form_name = 'AppConfig with internal notes.xlsx';
select * from clarity.weekly_tickets;

				    SELECT MAX(time_of_day) as time_of_day
                      FROM clarity.job_master
                     WHERE planned_date::date = CURRENT_DATE
--                       and action_date::date is null
					   and scheduled_week = EXTRACT(WEEK FROM CURRENT_DATE)-9
                       AND client_id = (select max(client_id) from clarity.job_master)
;

        SELECT jw.file_name,
               jm.scheduled_week,
               jm.job_id,
               jm.client_id,
               jm.client_name,
               jm.sn_ticket_system,
               jw.workflow_id,
               jw.workflow_input
          FROM clarity.job_master jm
          JOIN clarity.job_workflow jw
            ON jm.job_id = jw.job_id
           AND jm.client_name = jw.client_name
         WHERE jm.planned_date::date = CURRENT_DATE
--           AND jm.action_date::date is null
--           AND jw.workflow_id = 102
--           AND jw.file_name = 'SN_TICKET13'
           AND jm.scheduled_week = EXTRACT(WEEK FROM CURRENT_DATE)-9
           AND jm.client_id = (select max(client_id) from clarity.job_master)
           AND jw.file_name = '2025_Wave Online Template.xlsx'
         ORDER BY jm.client_id, jm.scheduled_week, CASE WHEN jw.workflow_id = 102 THEN 2 ELSE 1 END, jw.file_name
		;


        select sn_ticket_system,
            container_name,
            input_blob_path,
            output_blob_path
        FROM clarity.io_blob_file_path
        WHERE mapped_template_file = '2025_Wave Online Template.xlsx'
          AND (
              sn_ticket_system = ''
              OR LOWER(sn_ticket_system) = LOWER('Go-Live')
          )
        ORDER BY
            CASE WHEN sn_ticket_system IS NULL THEN 2 ELSE 1 end;


with res as(
      SELECT wf.form_name --string_agg(wf.form_name, ', ')
        FROM clarity.weekly_forms wf
        WHERE /*wf.week_no = 'Week-' || 4
          AND wf.ticket_name = 'Go-Live'
          AND*/ -- CASE 1: Pre-Add / Go-Live → APPLY FILTER
              (
              (
               (
                 wf.form_name ILIKE '%Pre%Add%'
                 OR wf.form_name ILIKE '%Go%Live%'
               )
               -- CORE PROCESSOR FILTER
               AND wf.form_name ILIKE '%Horizon%'
               -- DATACENTER FILTER
               AND wf.form_name ILIKE '%In%house%'
              )
              -- CASE 2: All OTHER forms → NO FILTER
              OR
              (
                  wf.form_name NOT ILIKE '%Pre%Add%'
                  AND wf.form_name NOT ILIKE '%Go%Live%'
              )
          )
)
select output_blob_path
  from res
  join clarity.io_blob_file_path
    on res.form_name = mapped_template_file
;

update clarity.job_master
   set planned_date = current_timestamp,
       day_of_week = 'MONDAY',
       time_of_day = '12:05 am'
 where client_id = (select max(client_id) from clarity.job_master)
;

update clarity.job_master
   set planned_date = current_timestamp,
       action_date = current_timestamp
 where client_id = (select max(client_id) from clarity.job_master)
;

client wise week need to be find based on the date given

select * from clarity.io_blob_file_path;

--drop table clarity.io_blob_file_path;
CREATE TABLE clarity.io_blob_file_path
(
serno				 INT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
week				 TEXT,
sn_ticket_system     TEXT,
mapped_template_file TEXT,
input_blob_Path      TEXT NOT NULL,
output_blob_Path     TEXT NOT NULL,
container_name 		 TEXT NOT NULL
);

insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('Go LIVE Template for Horizon DataCenter Offline.docx',
 'forms/Group2/Go LIVE Template for Horizon DataCenter Offline.docx',
 'forms/Group2/Go LIVE Template for Horizon DataCenter Offline_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('Go Live Template for Horizon In house Offline.docx',
 'forms/Group2/Go Live Template for Horizon In house Offline.docx',
 'forms/Group2/Go Live Template for Horizon In house Offline_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('GO LIVE Template for Horizon Inhouse FISC Offline.docx',
 'forms/Group2/GO LIVE Template for Horizon Inhouse FISC Offline.docx',
 'forms/Group2/GO LIVE Template for Horizon Inhouse FISC Offline_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('Go LIVE Template for Horizon DataCenter Online.docx',
 'forms/Group2/Go LIVE Template for Horizon DataCenter Online.docx',
 'forms/Group2/Go LIVE Template for Horizon DataCenter Online_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('2025_Wave Online Template.xlsx',
 'forms/Group6/2025_Wave Online Template.xlsx',
 'forms/Group6/2025_Wave Online Template_updated.xlsx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('OFLS V300 SURCHARGE FORM v5.docx',
 'forms/Group9/OFLS V300 SURCHARGE FORM v5.docx',
 'forms/Group9/OFLS V300 SURCHARGE FORM v5_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('Updated-OFLS V300 RGNL REPORT DIST v7.2.docx',
 'forms/Group10/Updated-OFLS V300 RGNL REPORT DIST v7.2.docx',
 'forms/Group10/Updated-OFLS V300 RGNL REPORT DIST v7.2_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('OFLS V250 GTWY REPORT  DN FORM-v9.docx',
 'forms/Group14/OFLS V250 GTWY REPORT  DN FORM-v9.docx',
 'forms/Group14/OFLS V250 GTWY REPORT  DN FORM-v9_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('OFLS V300 CUSTOMER SETUP V6.1 (003) - Norcross.docx',
 'forms/Group13/OFLS V300 CUSTOMER SETUP V6.1 (003) - Norcross.docx',
 'forms/Group13/OFLS V300 CUSTOMER SETUP V6.1 (003) - Norcross_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('OFLS V300 REPORT DIST v7.4.docx',
 'forms/Group11/OFLS V300 REPORT DIST v7.4.docx',
 'forms/Group11/OFLS V300 REPORT DIST v7.4_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('OFLS V300 STD POSTING FILE v4.docx',
 'forms/Group12/OFLS V300 STD POSTING FILE v4.docx',
 'forms/Group12/OFLS V300 STD POSTING FILE v4_updated.docx',
 'fis-forms');
insert into clarity.io_blob_file_path(mapped_template_file, input_blob_Path, output_blob_Path, container_name)
 values('SN_TICKET4',
 '',
 'forms/Group2/Go LIVE Template for Horizon DataCenter Offline_updated.docx, forms/Group2/Go Live Template for Horizon In house Offline_updated.docx, forms/Group2/GO LIVE Template for Horizon Inhouse FISC Offline_updated.docx, forms/Group6/2025_Wave Online Template_updated.xlsx, forms/Group9/OFLS V300 SURCHARGE FORM v5_updated.docx, forms/Group10/Updated-OFLS V300 RGNL REPORT DIST v7.2_updated.docx, forms/Group2/Go LIVE Template for Horizon DataCenter Online_updated.docx, forms/Group14/OFLS V250 GTWY REPORT  DN FORM-v9_updated.docx, forms/Group13/OFLS V300 CUSTOMER SETUP V6.1 (003) - Norcross_updated.docx, forms/Group11/OFLS V300 REPORT DIST v7.4_updated.docx, forms/Group12/OFLS V300 STD POSTING FILE v4_updated.docx',
 'fis-forms');

--output
update clarity.io_blob_file_path
   set output_blob_Path = 'forms/Group1/Pre Add Template for Horizon Data center Offline_updated.docx, forms/Group1/Pre-Add Template Third Party Core Online_updated.docx, forms/Group1/PreAdd Template for Horizon DataCenter Online_updated.docx, forms/Group1/Pre-Add Template Horizon In House Online_updated.docx, forms/Group2/Go LIVE Template for Horizon DataCenter Offline_updated.docx, forms/Group2/Go Live Template for Horizon In house Offline_updated.docx, forms/Group2/GO LIVE Template for Horizon Inhouse FISC Offline_updated.docx, forms/Group6/2025_Wave Online Template_updated.xlsx'
 where mapped_template_file = 'SN_TICKET4'
;

--output
update clarity.io_blob_file_path
   set output_blob_Path = 'forms/Group2/Go Live Template for Horizon In house Offline_updated.docx, forms/Group2/GO LIVE Template for Horizon Inhouse FISC Offline_updated.docx, forms/Group6/2025_Wave Online Template_updated.xlsx, forms/Group9/OFLS V300 SURCHARGE FORM v5_updated.docx, forms/Group10/Updated-OFLS V300 RGNL REPORT DIST v7.2_updated.docx, forms/Group14/OFLS V250 GTWY REPORT  DN FORM-v9_updated.docx, forms/Group13/OFLS V300 CUSTOMER SETUP V6.1 (003) - Norcross_updated.docx, forms/Group11/OFLS V300 REPORT DIST v7.4_updated.docx, forms/Group12/OFLS V300 STD POSTING FILE v4_updated.docx, forms/output/PaymentsOne Funds Movement Worksheet V1.2 - Georgia Banking Company- AAL completed 8.20.25 (003).docx, forms/output/Change Management Client Approval - Georgia Banking Company.pdf, forms/output/Change Questions document -  Georgia Banking Company.docx, forms/output/Change Approval Request - Georgia Banking Company Go-Live.msg'
 where mapped_template_file = 'SN_TICKET4'
;
--input
update clarity.io_blob_file_path
   set output_blob_Path = 'forms/Group1/Pre Add Template for Horizon Data center Offline.docx, forms/Group1/Pre-Add Template Third Party Core Online.docx, forms/Group1/PreAdd Template for Horizon DataCenter Online.docx, forms/Group1/Pre-Add Template Horizon In House Online.docx, forms/Group2/Go LIVE Template for Horizon DataCenter Offline.docx, forms/Group2/Go Live Template for Horizon In house Offline.docx, forms/Group2/GO LIVE Template for Horizon Inhouse FISC Offline.docx, forms/Group6/2025_Wave Online Template.xlsx'
 where mapped_template_file = 'SN_TICKET4'
;

update clarity.test_job_workflow jw
   set workflow_input = '{"{{Key_Vault}}": "key_vault_content", "{{n}}": "1", "{{file_details}}": "file_details", "{{ticket_details}}": "ticket_details"}'
 where job_id = 9 and workflow_id = 102
;
--insert into clarity.incident_ticket_details
select serno, caller, category, subcategory, service, service_offering, configuration_item, short_description, description, channel, state,	impact,	urgency, priority, assignment_group, assigned_to, 195 from clarity.incident_ticket_details
;

if visa_mastercard_both column in client table is having value of master card or both then only ABU ticket for 3rd week

select * from clarity.billingaccount order by account_id desc; --client_id, being default 522

select * from clarity.servicenow_tickets;
SELECT * FROM clarity.incident_ticket_details;--clarity.client

select * from clarity.application_logs
 order by log_id desc;--1357
select log_id, logged_at, workflow_id, client_id, client_name, job_id,	file_name from clarity.application_logs where log_id > 945 order by log_id desc; --882

select * from clarity.application_logs
 where log_id >= 1160
  and log_level = 'ERROR'
--  and log_id not in(1085, 1079, 1071)
order by log_id desc;

select * from clarity.business_message_workflow_log;

create table clarity.business_message_workflow_log
(
log_id int,
logs text,
raw_output text
);

SELECT logged_at,
    LAG(logged_at) OVER (ORDER BY logged_at DESC) as previous_timestamp,
    EXTRACT(EPOCH FROM (LEAD(logged_at) OVER (ORDER BY logged_at DESC) - logged_at)) / 60 AS minutes_difference
FROM clarity.application_logs
WHERE log_id > 945
ORDER BY logged_at DESC;
--delete from clarity.application_logs where log_id between 4 and 600;
 clarity.application_logs;
   add column ticket_status
success
failed
not submitted -> 


--drop TABLE clarity.application_logs;
create TABLE clarity.application_logs
(
    log_id         BIGSERIAL PRIMARY KEY,
    logged_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    log_level      VARCHAR(10) CHECK (log_level IN ('DEBUG','INFO','WARN','ERROR', NULL)),
    workflow_id    INT,   --Added newly
    workflow_name  TEXT,
    client_id      INT,
    client_name    TEXT,  --Added newly
    job_id         INT,
    file_name      TEXT,
    message        TEXT,
    logs           TEXT,
    raw_output     TEXT
);

INSERT INTO clarity.application_logs
(log_level, workflow_id, workflow_name, client_id, client_name, job_id, file_name, message, logs, raw_output)
VALUES
(
    'INFO',
    58,
    'Pipeline_Execution',
    1,
    'Acme Corp',
    9,
    'GO_LIVE_TEMPLATE.docx',
    'Pipeline execution started',
    '
       "step": "initialization",
       "status": "started",
       "execution_id": "fis-58-uuid"
    ',
    '
	{
		"id": "1",
		"name": "GO_LIVE_TEMPLATE",
		"status": "Success"
	}
	'
);

INSERT INTO clarity.application_logs
(log_level, workflow_id, workflow_name, client_id, client_name, job_id, file_name, message, logs, raw_output)
VALUES
(
    'ERROR',
    102,
    'Blob_Attach_Agent',
    1,
    'Acme Corp',
    9,
    'Horizon_Form.xlsx',
    'Failed to upload blob',
    '
       "error_code": "BLOB_500",
       "reason": "Network timeout",
       "retry_attempt": 2
    ',
    '
	{
		"id": "2",
		"name": "Horizon_Form",
		"status": "Failed",
		"Error": "Unable to connect DB"
	}
	'
);

INSERT INTO clarity.application_logs
(log_level, workflow_id, workflow_name, client_id, client_name, job_id, file_name, message, logs, raw_output)
VALUES
(
    'DEBUG',
    108,
    'CMI_Data_Mapper',
    1,
    'Acme Corp',
    9,
    'Input_Form.docx',
    'Field mapping completed',
    '
       "mapped_fields": 28,
       "unmapped_fields": 2,
       "duration_ms": 430
    ',
    '
	{
		"id": "3",
		"name": "Input_Form",
		"status": "Failed",
		"Error": "Error while fetching records from table"
	}
	'
);



3 agent - form
3 - ticket

