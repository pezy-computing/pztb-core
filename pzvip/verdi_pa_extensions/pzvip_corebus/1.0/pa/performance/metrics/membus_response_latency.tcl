perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_latency \
  -type instance \
  -description {
    this metric computes begin and end latency for each response transactions
  } \
  -dependent \
  -definition {
    SELECT
      (response.begin_time - command.begin_time) AS begin_latency,
      (response.end_time - command.begin_time) AS end_latency,
      response.begin_time AS begin_time,
      response.end_time AS end_time,
      response.event AS event,
      response.parent_event AS parent_event
    FROM
      $inst__Response_Item AS response,
      $inst__Command_Item AS command
    WHERE
      response.parent_event = command.parent_event
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_latency \
  -column begin_latency \
  -type Time \
  -unit fsdb time unit

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_latency \
  -column end_latency \
  -type Time \
  -unit fsdb time unit

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_latency \
  -column begin_time \
  -type Time \
  -unit fsdb time unit

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_latency \
  -column end_time \
  -type Time \
  -unit fsdb time unit

perfSetChart \
  -protocol PZVIP_COREBUS \
  -name membus_response_latency \
  -x begin_time \
  -y begin_latency \
  -type line
