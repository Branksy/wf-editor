
module Apis::WorkflowDesigner::V1

  class WorkflowStatesController < Apis::ApiController
    before_action :set_state, only: [:edit, :update]

    def index
      render json: workflow_states = paginate_with_prefs_and_filters(WorkflowState.all, :order => 'name ASC')
    end

    def new
      state = WorkflowState.new(workflow_type: 'Application', workflow_subtype: 'selection')
      render json: form_fields(state)
    end

    def create
      state = WorkflowState.new(state_params)
      if state.save
        states = WorkflowState.all.as_json(only: fields, include: {
          actions: { only: transition_fields },
          progressions: { only: transition_fields }
        })
        render json: states
      else
        render json: state.errors.messages, status: :unprocessable_entity
      end
    end

    def edit
      render json:  @state.as_json(methods: [:offer_template_ids, :report_key_ids]).merge(form_fields(@state))
    end

    def update
      if @state.update(state_params)
        states = WorkflowState.all.as_json(only: fields, include: {
          actions: { only: transition_fields },
          progressions: { only: transition_fields }
        })

        render json: { states: states }
      else
        render json: @state.errors.messages, status: unprocessable_entity
      end
    end

    private

    def set_state
      @state = WorkflowState.find(params[:id])
    end

    def state_params
      params[:workflow_state].merge(workflow_type: 'Application', workflow_subtype: 'selection')
    end

    def form_fields(state)
      { form: {
          activity_types: state.available_activity_types,
          activity_bys: state.available_activity_bys,
          before_enter_actions: state.available_before_enter_actions,
          on_enter_actions: state.available_on_enter_actions,
          before_exit_actions: state.available_before_exit_actions,
          on_exit_actions: state.available_on_exit_actions,
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