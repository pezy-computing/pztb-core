perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_bus_bandwidth \
  -type instance \
  -description {
    this metric computes bus bandwidth for each request data transactions
  } \
  -dependent {
    membus_request_data_byte_count
  } \
  -definition {
    SELECT
      CAST(byte_count.byte_count AS real) / (CAST((request_data.end_time - request_data.begin_time) AS real) * $timeunit_factor) AS bandwidth,
      request_data.begin_time AS time,
      request_data.event AS event,
      request_data.parent_event AS parent_event
    FROM
      $inst__membus_request_data_byte_count AS byte_count,
      $inst__Request_Data_Item AS request_data
    WHERE
      byte_count.event = request_data.event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_bus_bandwidth \
  -column bandwidth \
  -type Bandwidth \
  -unit GB/s

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_bus_bandwidth \
  -column time \
  -type Time \
  -unit fsdb time unit

perfSetChart \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_bus_bandwidth \
  -x time \
  -y bandwidth \
  -type line
