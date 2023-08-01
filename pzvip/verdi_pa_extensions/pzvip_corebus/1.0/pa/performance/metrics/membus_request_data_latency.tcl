perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_latency \
  -type instance \
  -description {
    this metric computes begin and end latency for each reques data transactions
  } \
  -dependent \
  -definition {
    SELECT
      (request_data.begin_time - command.begin_time) AS begin_latency,
      (request_data.end_time - command.begin_time) AS end_latency,
      request_data.begin_time AS begin_time,
      request_data.end_time AS end_time,
      request_data.event AS event,
      request_data.parent_event AS parent_event
    FROM
      $inst__Request_Data_Item AS request_data,
      $inst__Command_Item AS command
    WHERE
      request_data.parent_event = command.parent_event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_latency \
  -column begin_latency \
  -type Time \
  -unit fsdb time unit

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_latency \
  -column end_latency \
  -type Time \
  -unit fsdb time unit

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_latency \
  -column begin_time \
  -type Time \
  -unit fsdb time unit

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_latency \
  -column end_time \
  -type Time \
  -unit fsdb time unit

perfSetChart \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_latency \
  -x begin_time \
  -y begin_latency \
  -type line
