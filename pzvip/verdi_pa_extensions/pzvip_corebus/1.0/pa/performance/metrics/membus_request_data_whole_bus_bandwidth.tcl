perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_whole_bus_bandwidth \
  -type instance \
  -description {
    this metric computes bus bandwidth for request data transction on the given port
  } \
  -dependent {
    membus_request_data_byte_count
  } \
  -definition {
    SELECT
      CAST(SUM(byte_count.byte_count) AS real) / (CAST((MAX(request_data.end_time) - MIN(request_data.begin_time)) AS real) * $timeunit_factor) AS bandwidth
    FROM
      $inst__membus_request_data_byte_count byte_count,
      $inst__Request_Data_Item AS request_data
    WHERE
      byte_count.event = request_data.event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_whole_bus_bandwidth \
  -column bandwidth \
  -type Bandwidth \
  -unit GB/s
