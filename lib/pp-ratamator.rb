module PPRatamator

  # environment parameter constants
  API_ENVIRONMENTS = {"production" => "https://www.performance.service.gov.uk/data/","preview" => "https://www.preview.performance.service.gov.uk/data/"}
  PRODUCTION = "production"
  PREVIEW = "preview"

  # input parameter constants
  UPLOAD_MANUAL = "manual"
  UPLOAD_AUTO = "auto"

  # Query constants
  RECORD_PERIOD_DEFAULT = 7
  DEFAULT_PERIOD = "day"

  QUERY_DATASET = "consular-appointments/service-utilisation"
  FIXED_QUERY_PARAMETERS = "?flatten=true&collect=available_hours%3Asum&collect=used_hours%3Asum&group_by=consulate&group_by=service"
  PERIOD_TEXT = "&period="
  DURATION_TEXT = "&duration="
  QUERY_ISO_TIME_EXTENSION = "T00%3A00%3A00Z"

  # Data processing constants
  DATASET_HEADER = ["_timestamp","period","consulate","service","available_hours","used_hours","rate"]
  ID_SEPARATOR ="."
  AGGREGATE_PERIOD = "day"
  CALENDAR_WEEK_START_DAY = 1 #assumes monday start date - 1
  WEEK_DAYS = 7
  START_KEY = "data"

  # csv output constants
  APP_NAME_TEXT = "pp-ratamator"
  FILENAME_SEPARATOR = "-"
  DATA_DIRECTORY = "./data/"
  RATAMATOR_TEXT ="rate"
  CSV_FILE_EXTENSION = ".csv"

  #json output constants
  BEARER_ID = "foo"
  MEDIA_TYPE = "application/json"
  JSON_FILE_EXTENSION = ".json"
  WRITE_DATASET = "consular-appointments/service-utilisation-rate"
  BLANK_BEARER = "foo"

end
