perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_min_begin_latency \
  -type instance \
  -description {
    this metric computes minmum begin latency of request data transactions on the given port
  } \
  -dependent {
    membus_request_data_latency
  } \
  -definition {
    SELECT
      begin_latency AS min_begin_latency,
      event AS event,
      parent_event AS parent_event
    FROM
      $inst__membus_request_data_latency
    ORDER BY
      begin_latency ASC LIMIT 1
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_min_begin_latency \
  -column min_begin_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_max_begin_latency \
  -type instance \
  -description {
    this metric computes maximum begin latency of request data transactions on the given port
  } \
  -dependent {
    membus_request_data_latency
  } \
  -definition {
    SELECT
      begin_latency AS max_begin_latency,
      event AS event,
      parent_event AS parent_event
    FROM
      $inst__membus_request_data_latency
    ORDER BY
      begin_latency DESC LIMIT 1
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_max_begin_latency \
  -column max_begin_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_avg_begin_latency \
  -type instance \
  -description {
    this metric computes average begin latency of request data transactions on the given port
  } \
  -dependent {
    membus_request_data_latency
  } \
  -definition {
    SELECT
      AVG(begin_latency) AS avg_begin_latency
    FROM
      $inst__membus_request_data_latency
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_avg_begin_latency \
  -column avg_begin_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_min_end_latency \
  -type instance \
  -description {
    this metric computes minmum end latency of request data transactions on the given port
  } \
  -dependent {
    membus_request_data_latency
  } \
  -definition {
    SELECT
      end_latency AS min_end_latency,
      event AS event,
      parent_event AS parent_event
    FROM
      $inst__membus_request_data_latency
    ORDER BY
      end_latency ASC LIMIT 1
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_min_end_latency \
  -column min_end_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_max_end_latency \
  -type instance \
  -description {
    this metric computes maximum end latency of request data transactions on the given port
  } \
  -dependent {
    membus_request_data_latency
  } \
  -definition {
    SELECT
      end_latency AS max_end_latency,
      event AS event,
      parent_event AS parent_event
    FROM
      $inst__membus_request_data_latency
    ORDER BY
      end_latency DESC LIMIT 1
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_max_end_latency \
  -column max_end_latency \
  -type Time \
  -unit fsdb time unit

perfCreateMetric \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_avg_end_latency \
  -type instance \
  -description {
    this metric computes average end latency of request data transactions on the given port
  } \
  -dependent {
    membus_request_data_latency
  } \
  -definition {
    SELECT
      AVG(end_latency) AS avg_end_latency
    FROM
      $inst__membus_request_data_latency
  }

perfSetColumnType \
  -protocol PZVIP_COREBUS \
  -name membus_request_data_avg_end_latency \
  -column avg_end_latency \
  -type Time \
  -unit fsdb time unit
