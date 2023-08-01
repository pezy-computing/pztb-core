perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_whole_bus_bandwidth \
  -type instance \
  -description {
    this metric computes bus bandwidth for response data transction on the given port
  } \
  -dependent {
    membus_response_data_byte_count
  } \
  -definition {
    SELECT
      CAST(SUM(byte_count.byte_count) AS real) / (CAST((MAX(response.end_time) - MIN(response.begin_time)) AS real) * $timeunit_factor) AS bandwidth
    FROM
      $inst__membus_response_data_byte_count byte_count,
      $inst__Response_Item AS response
    WHERE
      byte_count.event = response.event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_whole_bus_bandwidth \
  -column bandwidth \
  -type Bandwidth \
  -unit GB/s
