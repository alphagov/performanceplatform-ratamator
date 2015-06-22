require 'pp-ratamator'
require 'jsongetter'
require "logging"
require 'base64'
require 'csvwriter'
require 'jsonwriter'

module PPRatamator

  class Runner

    include Logging

    def initialize(verbose) 
      @verbose = verbose
      @verbose ? logger.level=Logger::INFO : logger.level=Logger::ERROR
      @json_data = Hash.new()
      @query_data = Array.new()
      @record_list = Array.new()
    end

    def go(config)
      logger.info "PPRatamator::Runner:go:environment: #{config[:environment]} record period: #{config[:recordperiod]}"

      # for write  api calls check bearer set or exit before wasting time
      if (config[:upload] == UPLOAD_AUTO) && (config[:bearer] == BLANK_BEARER)
        logger.error "PPRatamator::Runner:go:bearer token must be set for auto upload"
        return
      end

      # Get the data

      # build query string based on environment
      query_url = build_query_url config
      puts query_url

      # query the dataset
      json_getter = JsonGetter.new @verbose
      @json_data = json_getter.go query_url
      return unless json_getter.success?

      #get dataset as single processed array of hash
      @query_data = @json_data[START_KEY]

      # run the specific transform
      process_data_records

      # output the records
      config[:upload] == UPLOAD_MANUAL ? output_to_csv(config) : output_to_json(config)

    end

    def success?
      return @success
    end

    private

    # Generics
    
    def build_query_url(config)
      logger.info "PPRatamator::Runner:build_query_url"
      query_url = API_ENVIRONMENTS[config[:environment]] + QUERY_DATASET + FIXED_QUERY_PARAMETERS + PERIOD_TEXT + DEFAULT_PERIOD + DURATION_TEXT + config[:recordperiod].to_s    
    end

    def process_data_records
      logger.info "PPRatamator::Runner:process_data_records"
      build_rate_records
    end

    # Transform specifics

    def build_rate_records
      logger.info "PPRatamator::Runner:build_record_hash"
      #create array of records with data, create _id, _timestamp and rate
      @query_data.each do | record |
        if record["_count"] > 0
          #generate rate
          utilisation_rate = calculate_rate record["used_hours:sum"], record["available_hours:sum"]
          #create record
          @record_list << build_record_hash(record, utilisation_rate)
        end
      end
    end

    def calculate_rate(used_hours,available_hours)
      begin
        #if used_hours.zero? && available_hours.zero? # not strict ... provides readable output 
        #  rate = 0.0
        #else
          rate = used_hours/available_hours
          rate = nil if rate.nan?
          rate = nil if rate.infinite?
          #end
      rescue => ex
        # just absorb any exceptions
        rate = nil
      end
      return rate
    end

    def build_record_hash(record, rate)
      readable_id = record["_start_at"] + ID_SEPARATOR + DEFAULT_PERIOD + ID_SEPARATOR + record["consulate"]+ ID_SEPARATOR + record["service"]
      return {
        "_id" => Base64.urlsafe_encode64(readable_id),
        "_timestamp" => record["_start_at"], 
        "period" => DEFAULT_PERIOD,
        "consulate" => record["consulate"],
        "service" => record["service"],
        "available_hours" => record["available_hours:sum"],
        "used_hours" => record["used_hours:sum"],
        "utilisation_rate" => rate
      }
    end

    # Outputs

    def output_to_csv(config)
      logger.info "PPRatamator::Runner:output_to_csv"

      # build csv contents
      out_arr = Array.new()
      out_arr << DATASET_HEADER
      @record_list.each do | record |
        out_arr << [record["_timestamp"],record["period"],record["consulate"],record["service"],record["available_hours"],record["used_hours"],record["utilisation_rate"]]
      end
      # generate filename
      filename = build_output_filename CSV_FILE_EXTENSION
      # write csv out
      csv_out = CsvWriter.new(@verbose)
      csv_out.go(out_arr,filename,config[:dryrun])
      @success = csv_out.success?

    end

    def output_to_json(config)
      logger.info "PPRatamator::Runner:output_to_json"
      # set write api endpoint
      write_endpoint = build_write_endpoint config[:environment]
      # write json out
      json_out = JsonWriter.new(@verbose)
      json_out.go(@record_list,write_endpoint,config[:bearer],config[:dryrun])
      @success = json_out.success?
    end

    def build_output_filename(extension)
      return DATA_DIRECTORY + WRITE_DATASET.gsub("/","-") + FILENAME_SEPARATOR + Time.now.utc.iso8601.gsub(/\W/, '') + extension
    end

    def build_write_endpoint(environment)
      return API_ENVIRONMENTS[environment] + WRITE_DATASET
    end

  end

end
