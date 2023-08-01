perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_min_begin_latency \
  -type instance \
  -description {
    this metric computes minmum begin latency of response transactions on the given port
  } \
  -dependent {
    membus_response_latency
  } \
  -definition {
    SELECT
      begin_latency AS min_begin_latency,
      event AS event,
      parent_event AS parent_event
    FROM
      $inst__membus_response_latency
    ORDER BY
      begin_latency ASC LIMIT 1
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_min_begin_latency \
  -column min_begin_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_max_begin_latency \
  -type instance \
  -description {
    this metric computes maximum begin latency of response transactions on the given port
  } \
  -dependent {
    membus_response_latency
  } \
  -definition {
    SELECT
      begin_latency AS max_begin_latency,
      event AS event,
      parent_event AS parent_event
    FROM
      $inst__membus_response_latency
    ORDER BY
      begin_latency DESC LIMIT 1
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_max_begin_latency \
  -column max_begin_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_avg_begin_latency \
  -type instance \
  -description {
    this metric computes average begin latency of response transactions on the given port
  } \
  -dependent {
    membus_response_latency
  } \
  -definition {
    SELECT
      AVG(begin_latency) AS avg_begin_latency
    FROM
      $inst__membus_response_latency
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_avg_begin_latency \
  -column avg_begin_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_min_end_latency \
  -type instance \
  -description {
    this metric computes minmum end latency of response transactions on the given port
  } \
  -dependent {
    membus_response_latency
  } \
  -definition {
    SELECT
      end_latency AS min_end_latency,
      event AS event,
      parent_event AS parent_event
    FROM
      $inst__membus_response_latency
    ORDER BY
      end_latency ASC LIMIT 1
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_min_end_latency \
  -column min_end_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_max_end_latency \
  -type instance \
  -description {
    this metric computes maximum end latency of response transactions on the given port
  } \
  -dependent {
    membus_response_latency
  } \
  -definition {
    SELECT
      end_latency AS max_end_latency,
      event AS event,
      parent_event AS parent_event
    FROM
      $inst__membus_response_latency
    ORDER BY
      end_latency DESC LIMIT 1
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_max_end_latency \
  -column max_end_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_response_avg_end_latency \
  -type instance \
  -description {
    this metric computes average end latency of response transactions on the given port
  } \
  -dependent {
    membus_response_latency
  } \
  -definition {
    SELECT
      AVG(end_latency) AS avg_end_latency
    FROM
      $inst__membus_response_latency
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_response_avg_end_latency \
  -column avg_end_latency \
  -type Time \
  -unit fsdb time unit
