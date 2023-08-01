perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_cycles \
  -type instance \
  -description {
    this metric collects active, valid, stall and idle cycles for each reqest data transactions
  } \
  -dependent \
  -definition {
    SELECT
      SUM(1 + bus_activity.stall_cycles + bus_activity.gap_cycles) AS active_cycles,
      SUM(1 + bus_activity.stall_cycles) AS valid_cycles,
      SUM(bus_activity.stall_cycles) AS stall_cycles,
      SUM(bus_activity.gap_cycles) AS idle_cycles,
      request_data.begin_time AS time,
      request_data.event AS event,
      request_data.parent_event AS parent_event
    FROM
      $inst__Request_Data_Item AS bus_activity,
      $inst__Request_Data_Item AS request_data
    WHERE
      bus_activity.parent_event = request_data.event
    GROUP BY
      bus_activity.parent_event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_cycles \
  -column time \
  -type Time \
  -unit fsdb time unit
