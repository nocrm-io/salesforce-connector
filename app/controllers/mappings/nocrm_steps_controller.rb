module Mappings
  class NocrmStepsController < ApplicationController
    before_action :find_nocrm_step, only: [:update]
  
    def update
      if @step.stage_id = step_params[:stage_id]
        respond_to do |format|
          format.turbo_stream
        end
      end
    end

    private
  
    def step_params
      params.require(:nocrm_step).permit(:stage_id)
    end
  
    def find_nocrm_step
      @step = NocrmStep.find(params[:id])
    end
  end  
end
