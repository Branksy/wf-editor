
module Apis::WorkflowDesigner::V1

  class WorkflowStagesController < Apis::ApiController
    before_action :set_stage, only: [:edit, :update]

    def index
      render json: workflow_stages = paginate_with_prefs_and_filters(WorkflowStage.all, :order => 'name ASC')
    end

    def new
      stage = WorkflowStage.new(workflow_type: 'Application')
      render json: form_fields(stage)
    end

    def create
      stage = WorkflowStage.new(stage_params)
      if stage.save
        stages = WorkflowStage.all.as_json(only: fields, include: {
          workflow_states: { only: fields, include: {
            actions: { only: transition_fields },
            progressions: { only: transition_fields }
          }}
        })
        render json: stages
      else
        render json: stage.errors.messages, status: :unprocessable_entity
      end
    end

    def edit
      render json:  @stage.as_json(methods: [:offer_template_ids, :report_key_ids]).merge(form_fields(@stage))
    end

    def update
      if @stage.update(stage_params)
        stages = WorkflowStage.all.as_json(only: fields, include: {
          workflow_states: { only: fields, include: {
            actions: { only: transition_fields },
            progressions: { only: transition_fields }
          }}
        })
        render json: { stages: stages }
      else
        render json: @stage.errors.messages, status: :unprocessable_entity
      end
    end

    private

    def set_stage
      @stage = WorkflowStage.find(params[:id])
    end

    def stage_params
      params[:workflow_stage].merge(workflow_type: 'Application', workflow_subtype: 'selection')
    end

    def form_fields(stage)
      { form: {
          activity_types: stage.available_activity_types,
          appointment_templates: AppointmentTemplate.active.map {|at| [at.name, at.id]},
          assessment_templates: AssessmentTemplate.active.map {|at| [at.name, at.id]},
          offer_templates: OfferTemplate.active.map {|at| {name: at.name, id: at.id}},
          report_key_options: ReportKey.workflow.map {|at| {name: at.name, id: at.id}}
        }
      }
    end

    def fields
      [:id, :name, :title, :reference]
    end

    def transition_fields
      fields + [:destination_type]
    end

  end
end