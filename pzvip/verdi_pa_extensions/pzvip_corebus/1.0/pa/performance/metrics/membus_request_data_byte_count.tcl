perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_byte_count \
  -type instance \
  -description {
    this metric computes total byte count of each request data transactions
  } \
  -dependent \
  -definition {
    SELECT
      (COUNT(*) * bus_info.data_width / 8) AS byte_count,
      request_data.begin_time AS time,
      request_data.event AS event,
      request_data.parent_event AS parent_event
    FROM
      $inst__Request_Data_Item AS bus_activity,
      $inst__Request_Data_Item AS request_data,
      $inst__bus_info AS bus_info
    WHERE
      bus_activity.parent_event = request_data.event
    GROUP BY
      bus_activity.parent_event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_byte_count \
  -column byte_count \
  -type Data \
  -unit Byte

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_byte_count \
  -column time \
  -type Time \
  -unit fsdb time unit
