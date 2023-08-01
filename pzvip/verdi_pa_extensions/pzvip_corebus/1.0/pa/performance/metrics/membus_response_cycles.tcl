perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_cycles \
  -type instance \
  -description {
    this metric collects active, valid, stall and idle cycles for each response transactions
  } \
  -dependent \
  -definition {
    SELECT
      SUM(1 + bus_activity.stall_cycles + bus_activity.gap_cycles) AS active_cycles,
      SUM(1 + bus_activity.stall_cycles) AS valid_cycles,
      SUM(bus_activity.stall_cycles) AS stall_cycles,
      SUM(bus_activity.gap_cycles) AS idle_cycles,
      response.begin_time AS time,
      response.event AS event,
      response.parent_event AS parent_event
    FROM
      $inst__Response_Item AS bus_activity,
      $inst__Response_Item AS response
    WHERE
      bus_activity.parent_event = response.event
    GROUP BY
      bus_activity.parent_event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_cycles \
  -column time \
  -type Time \
  -unit fsdb time unit
