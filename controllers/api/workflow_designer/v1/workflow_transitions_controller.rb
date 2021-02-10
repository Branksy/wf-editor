module Apis::WorkflowDesigner::V1

  class WorkflowTransitionsController < Apis::ApiController
    before_action :set_transition, only: [:edit, :update]

    def new
      transition = WorkflowTransition.new(workflow_type: 'Application', workflow_subtype: 'selection')
      render json: form_fields(transition)
    end

    def create
      transition = WorkflowTransition.new(transition_params)
      if transition.save
        render json: {  actions: WorkflowTransition.actions.as_json(only: transition_fields),
                        progressions: WorkflowTransition.progressions.as_json(only: transition_fields) }
      else
        render json: transition.errors.messages, status: :unprocessable_entity
      end
    end

    def edit
      render json: form_fields(@transition)
    end

    def update
      if @transition.update(transition_params)
        render json: {  actions: WorkflowTransition.actions.as_json(only: transition_fields),
                        progressions: WorkflowTransition.progressions.as_json(only: transition_fields) }
      else
        render json: @transition.errors.messages, status: :unprocessable_entity
      end
    end

    def refresh
      transition = WorkflowTransition.find_by(id: params[:id]) || WorkflowTransition.new
      transition.attributes = transition_params
      render json: form_fields(transition)
    end

    private

    def transition_fields
      [:id, :name, :title, :reference, :destination_type]
    end

    def form_fields(transition)
      { transition: transition.as_json(
                            except: [:created_at, :updated_at],
                            methods: [:access_role_ids, :primary_communication_template_id, :secondary_communication_template_id, :tertiary_communication_template_id]),
        form: {
          available_actions: transition.available_actions,
          action_definition_help: transition.action_definition[:help],
          display_comms_selector_primary: transition.display_comms_selector?(:primary),
          display_comms_selector_secondary: transition.display_comms_selector?(:secondary),
          display_comms_selector_tertiary: transition.display_comms_selector?(:tertiary),
          communication_template_choices_primary: transition.communication_template_choices(:primary),
          communication_template_choices_secondary: transition.communication_template_choices(:secondary),
          communication_template_choices_tertiary: transition.communication_template_choices(:tertiary),

          available_destination_types: transition.available_destination_types,
          available_destination_stages: transition.available_destination_stages.pluck(:name, :id),
          available_destination_states: transition.available_destination_states.pluck(:name, :id),
          available_alternate_destination_types: transition.available_alternate_destination_types,

          destination_workflow_stage_id_required: transition.destination_workflow_stage_id_required?,
          destination_workflow_state_id_required: transition.destination_workflow_state_id_required?,
          destination_hint: transition.action_definition[:destination_hint],
          alternate_destination_type_required: transition.alternate_destination_type_required?,
          alternate_destination_workflow_stage_id_required: transition.alternate_destination_workflow_stage_id_required?,
          alternate_destination_workflow_state_id_required: transition.alternate_destination_workflow_state_id_required?,
          alternate_destination_hint: transition.action_definition[:alternate_destination_hint],

          available_as_scheduled_action: transition.available_as_scheduled_action?,
          scheduled_trigger_options: WorkflowTransition.scheduled_trigger_options,
          scheduled_delay_minutes_required: transition.scheduled_delay_minutes_required?,

          available_as_bulk_action: transition.available_as_bulk_action?,
          lock_system_action: transition.lock_system_action?,
          access_roles: AccessRole.except_sys_admin.as_json(only: [:id, :title]),

          action_fields_with_options: action_fields_with_options(transition.action)
        }
      }
    end

    def form_action_parameters(action_name)
      Application.workflow_actions.dig(action_name.to_sym, :action_parameters)
    end

    def action_fields_with_options(action_name)
      if action_name && form_action_parameters(action_name)
        fields = []
        form_action_parameters(action_name).each do |field|
          fields << { label: field.keys[0].to_s.titleize,
                      name: field.keys[0],
                      options: field_options(field.values[0]),
                      multiple: field.values[0].dig(:html_options, :multiple),
                      required: field.values[0][:required],
                      if: field.values[0][:if],
                      hint: field.values[0][:hint],
                      format: field_format(field) }
        end
        fields
      end
    end

    def field_format(field)
      if field_options(field.values[0])
        'Dropdown'
      else
        'Textbox'
      end
    end

    def field_options(field)
      if field[:options_method]
        field[:options_method][:class].constantize.send(field[:options_method][:method])
      else
        field[:options].try(:call) || field[:options]
      end
    end

    def set_transition
      @transition = WorkflowTransition.find(params[:id])
    end

    def transition_params
      params[:workflow_transition]
        .merge!(workflow_type: 'Application', workflow_subtype: 'selection')
        .except(:uuid, :created_at, :updated_at, :id, :reference, :restricted_access, :selection_process_id,
                :primary_communication_template_id, :secondary_communication_template_id, :tertiary_communication_template_id)
    end
  end
end