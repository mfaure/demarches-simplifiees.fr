class API::V2::GraphqlController < API::V2::BaseController
  include GraphqlOperationLogConcern

  def execute
    variables = ensure_hash(params[:variables])

    result = API::V2::Schema.execute(params[:query],
      variables: variables,
      context: context,
      operation_name: params[:operationName])

    render json: result
  rescue GraphQL::ParseError => exception
    handle_parse_error(exception)
  rescue => exception
    if Rails.env.production?
      handle_error_in_production(exception)
    else
      handle_error_in_development(exception)
    end
  end

  private

  def append_info_to_payload(payload)
    super

    payload.merge!({
      graphql_operation: operation_log(params[:query], params[:operationName], params[:variables]&.to_unsafe_h)
    })
  end

  def process_action(*args)
    super
  rescue ActionDispatch::Http::Parameters::ParseError => exception
    render json: {
      errors: [
        { message: exception.cause.message }
      ],
      data: nil
    }, status: 400
  end

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def handle_parse_error(exception)
    render json: {
      errors: [
        { message: exception.message }
      ],
      data: nil
    }, status: 400
  end

  def handle_error_in_development(exception)
    logger.error exception.message
    logger.error exception.backtrace.join("\n")

    render json: {
      errors: [
        { message: exception.message, backtrace: exception.backtrace }
      ],
      data: nil
    }, status: 500
  end

  def handle_error_in_production(exception)
    id = SecureRandom.uuid
    Sentry.capture_exception(exception, extra: { exception_id: id })

    render json: {
      errors: [
        {
          message: "Internal Server Error",
          extensions: {
            exception: { id: id }
          }
        }
      ],
      data: nil
    }, status: 500
  end
end
