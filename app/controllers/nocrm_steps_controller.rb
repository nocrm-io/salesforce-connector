class NocrmStepsController < ApplicationController
  before_action :find_nocrm_step, only: [:update]
  def index
  end

  def create
    # salesforce_object_type: "SalesforceStage"
    @mapping = Mapping.new(step_params)
    if @mapping.save
      respond_to do |format|
        format.turbo_stream
      end
    else
    end
  end

  def edit
  end

  def update
    @step.stage_ids = step_params[:stage_ids].compact_blank
  end

  def destroy
  end

  private

  def step_params
    params.require(:nocrm_step).permit(stage_ids: [])
  end

  def find_nocrm_step
    @step = NocrmStep.find(params[:id])
  end
end
