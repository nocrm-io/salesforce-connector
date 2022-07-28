module Mappings
  class NocrmFieldTypesController < ApplicationController
    before_action :find_mapping, only: [:edit, :update, :destroy]

    def new
      @mapping = Mapping.new
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("remote_modal", partial: "mappings/nocrm_field_types/form_modal", locals: { mapping: @mapping })
        end
        format.html
      end
    end

    def create
      if @mapping = Mapping.create(field_type_params)
        @new_mapped_field = field_type_params['salesforce_object_id']
        respond_to do |format|
          format.turbo_stream
        end
      end
    end

    def edit
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("remote_modal", partial: "mappings/nocrm_field_types/form_modal", locals: { mapping: @mapping })
        end
        format.html
      end
    end

    def update
      if @mapping.update(field_type_params)
        @new_mapped_field = @mapping.salesforce_object.id
        respond_to do |format|
          format.turbo_stream
        end
      end
    end

    def destroy
      @mapping.destroy
      respond_to { |format| format.turbo_stream }
    end

    private

    def field_type_params
      params.require(:mapping).permit(:nocrm_object_gid, :salesforce_object_id, :salesforce_object_type)
    end

    def find_mapping
      @mapping = Mapping.find(params[:id])
    end
  end  
end
