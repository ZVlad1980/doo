create or replace view xxsl.xxsl_dc_db_events2_v as
select e.event_id,
       e.deal_number,
       count(e.deal_number) over(partition by e.deal_number) deal_cnt,
       row_number() over(partition by e.deal_number order by e.deal_max_date desc, e.deal_number, e.shipment_num, e.operation_id desc, e.creation_date desc, e.event_id desc) deal_row_num,
       e.shipment_num,
       count(e.shipment_num) over(partition by e.deal_number, e.shipment_num) shipment_cnt,
       row_number() over(partition by e.deal_number, e.shipment_num order by e.deal_max_date desc, e.deal_number, e.shipment_num, e.operation_id desc, e.creation_date desc, e.event_id desc) shipment_row_num,
       e.operation_id,
       count(e.operation_id) over(partition by e.deal_number, e.shipment_num, e.operation_id) operation_cnt,
       row_number() over(partition by e.deal_number, e.shipment_num, e.operation_id order by e.deal_max_date desc, e.deal_number, e.shipment_num, e.operation_id desc, e.creation_date desc, e.event_id desc) operation_row_num,
       e.creation_date,
       e.company_code,
       e.event_name,
       e.request_id,
       e.last_update_date,
       e.status,
       e.state,
       e.cancel_yn,
       e.canceling_event_id,
       e.parsed
from   xxsl.xxsl_dc_db_events_v e
order  by e.deal_max_date desc,
          e.deal_number,
          e.shipment_num,
          e.operation_id  desc,
          e.creation_date desc,
          e.event_id      desc
/
