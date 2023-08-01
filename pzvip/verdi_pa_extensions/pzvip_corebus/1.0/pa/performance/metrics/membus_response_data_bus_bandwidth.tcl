perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_bus_bandwidth \
  -type instance \
  -description {
    this metric computes bus bandwidth for each response data transactions
  } \
  -dependent {
    membus_response_data_byte_count
  } \
  -definition {
    SELECT
      CAST(byte_count.byte_count AS real) / (CAST((response.end_time - response.begin_time) AS real) * $timeunit_factor) AS bandwidth,
      response.begin_time AS time,
      response.event AS event,
      response.parent_event AS parent_event
    FROM
      $inst__membus_response_data_byte_count AS byte_count,
      $inst__Response_Item AS response
    WHERE
      byte_count.event = response.event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_bus_bandwidth \
  -column bandwidth \
  -type Bandwidth \
  -unit GB/s

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_bus_bandwidth \
  -column time \
  -type Time \
  -unit fsdb time unit

perfSetChart \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_bus_bandwidth \
  -x time \
  -y bandwidth \
  -type line
