perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_throughput \
  -type instance \
  -description {
    this metric computes throughput for each request data transactions
  } \
  -dependent {
    membus_request_data_cycles
  } \
  -definition {
    SELECT
      (CAST((cycles.valid_cycles - cycles.stall_cycles) AS real) / CAST(cycles.active_cycles AS real)) * 100.0 AS throughput,
      cycles.time AS time,
      cycles.event AS event,
      cycles.parent_event AS parent_event
    FROM
      $inst__membus_request_data_cycles AS cycles
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_throughput \
  -column time \
  -type Time \
  -unit fsdb time unit

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_throughput \
  -column throughput \
  -type Customize \
  -unit "%"

perfSetChart \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_throughput \
  -x time \
  -y throughput \
  -type line
