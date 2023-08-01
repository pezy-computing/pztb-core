perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_throughput \
  -typ instance \
  -description { \
    this metric computes throughput for each response transactions which have response data
  } \
  -dependent {
    membus_response_cycles
  } \
  -definition {
    SELECT
      (CAST((cycles.valid_cycles - cycles.stall_cycles) as real) / CAST(cycles.active_cycles AS real)) * 100.0 AS throughput,
      cycles.time AS time,
      cycles.event AS event,
      cycles.parent_event AS parent_event
    FROM
      $inst__membus_response_cycles AS cycles,
      $inst__Response_Item AS response
    WHERE
      cycles.event = response.event
    AND
      response.response_type = 'PZVIP_COREBUS_RESPONSE_WITH_DATA'
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_throughput \
  -column time \
  -type Time \
  -unit fsdb time unit

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_throughput \
  -column throughput \
  -type Customize \
  -unit "%"

perfSetChart \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_throughput \
  -x time \
  -y throughput \
  -type line
