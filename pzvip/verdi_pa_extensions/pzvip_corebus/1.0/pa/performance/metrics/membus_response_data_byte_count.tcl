perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_byte_count \
  -type instance \
  -description {
    this metric computes total byte count of each response data transactions
  } \
  -dependent \
  -definition {
    SELECT
      (COUNT(*) * bus_info.data_width / 8) AS byte_count,
      response.begin_time AS time,
      response.event AS event,
      response.parent_event AS parent_event
    FROM
      $inst__response_item AS bus_activity,
      $inst__response_item AS response,
      $inst__bus_info AS bus_info
    WHERE
      bus_activity.parent_event = response.event
    AND
      response.response_type = 'PZVIP_COREBUS_RESPONSE_WITH_DATA'
    GROUP BY
      bus_activity.parent_event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_byte_count \
  -column byte_count \
  -type Data \
  -unit Byte

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_data_byte_count \
  -column time \
  -type Time \
  -unit fsdb time unit
