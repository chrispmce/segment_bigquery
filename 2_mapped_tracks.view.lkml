view: mapped_tracks {
  derived_table: {
    sql_trigger_value: select count(*) from ${aliases_mapping.SQL_TABLE_NAME} ;;
    sql: select *
        ,timestamp_diff(received_at, lag(received_at) over(partition by looker_visitor_id order by received_at), minute) as idle_time_minutes
      from (
        select CONCAT(cast(t.received_at AS string), t.anonymous_id) as event_id
          ,t.anonymous_id
          ,a2v.looker_visitor_id
          ,t.received_at
          ,t.event as event
        from android.tracks as t
        inner join ${aliases_mapping.SQL_TABLE_NAME} as a2v
        on a2v.alias = coalesce(t.user_id, t.anonymous_id)
        )
       ;;
  }

  dimension: anonymous_id {
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: event_id {
    sql: ${TABLE}.event_id ;;
  }

  dimension: looker_visitor_id {
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension_group: received_at {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.received_at ;;
  }

  dimension: event {
    sql: ${TABLE}.event ;;
  }

  dimension: idle_time_minutes {
    type: number
    sql: ${TABLE}.idle_time_minutes ;;
  }

  set: detail {
    fields: [event_id, looker_visitor_id, event, idle_time_minutes]
  }
}
