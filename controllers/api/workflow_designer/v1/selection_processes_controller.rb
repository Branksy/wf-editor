
module Apis::WorkflowDesigner::V1

  class SelectionProcessesController < Apis::ApiController
    before_action :set_selection_process, only: [:edit, :update_tree, :update]

    def sidebar
      stages = WorkflowStage.all.as_json(only: fields, include: {
        workflow_states: { only: fields, include: {
          actions: { only: transition_fields },
          progressions: { only: transition_fields }
        }}
      })
      states = WorkflowState.all.as_json(only: fields, include: {
        actions: { only: transition_fields },
        progressions: { only: transition_fields }
      })
      actions = WorkflowTransition.actions.as_json(only: transition_fields)
      progressions = WorkflowTransition.progressions.as_json(only: transition_fields)

      render json: {
        stages: stages,
        states: states,
        actions: actions,
        progressions: progressions
      }
    end

    def index
      render json: @selection_processes = paginate_with_prefs_and_filters(SelectionProcess.all, :order => 'name ASC')
    end

    def edit
      render json: {
        selection_process_tree: selection_process_tree,
        selection_process: @selection_process.as_json(only: [
          :id,
          :name,
          :title,
          :abbreviation,
          :description,
          :status,
          :talent_workflow_stage_id,
          :talent_workflow_stage_name,
          :complete_workflow_stage_id,
          :complete_workflow_stage_name
        ]),
        form: {
          available_talent_stages: @selection_process.available_talent_stages,
          available_complete_stages: @selection_process.available_complete_stages
        }
      }
    end

    def update
      @selection_process.attributes = selection_params
      if @selection_process.save
        render json: @selection_process
      else
        render json: @selection_process.errors.messages, status: :unprocessable_entity
      end
    end

    def update_tree
      stages = params[:workflow_tree].each_with_index do |stage, index|
        if stage[:workflow_states]
          stage[:workflow_states].each_with_index do |state, index|
            ws_ws = WorkflowStagesWorkflowState.where(workflow_stage_id: stage[:id], workflow_state_id: state[:id]).first_or_create(position: index + 1)
            update_position(ws_ws, index)

            state[:workflow_transitions] = [state[:actions], state[:progressions]].compact.reduce([], :|)
            if state[:workflow_transitions]
              state[:workflow_transitions].each_with_index do |transition, index|
                ws_wt = WorkflowStatesWorkflowTransition.where(workflow_state_id: state[:id], workflow_transition_id: transition[:id]).first_or_create(position: index + 1)
                update_position(ws_wt, index)
              end
              transition_ids = state[:workflow_transitions].map {|m| m['id']}
              WorkflowState.find(state['id']).workflow_transitions = WorkflowTransition.where(id: transition_ids)
            end
          end
          state_ids = stage[:workflow_states].map {|m| m['id'] }
          WorkflowStage.find(stage['id']).workflow_states = WorkflowState.where(id: state_ids)
        end
      end
      stage_references = stages.map { |stage| { :class_name => 'WorkflowStage', :reference => stage[:reference] } }

      if @selection_process.workflow_steps != stage_references
        @selection_process.update(workflow_steps: stage_references)
      end

      if WorkflowProcess.all.map { |wp| wp.save }
        render json: { status: :updated }
      else
        render json: { status: :unprocessable_entity }
      end
    end

    def new
      selection_process = SelectionProcess.new
      render json: {  form: { available_talent_stages: selection_process.available_talent_stages,
                      available_complete_stages: selection_process.available_complete_stages }}
    end

    def create
      selection_process = SelectionProcess.new(selection_params)
      if selection_process.save
        @selection_processes = paginate_with_prefs_and_filters(SelectionProcess.all, :order => 'name ASC')
        render json: @selection_processes
      else
        render json: selection_process.errors.messages, status: :unprocessable_entity
      end
    end



  private

    def selection_params
      params[:selection_process].merge(workflow_type: 'Application', workflow_subtype: 'selection')
                                .except!(:id, :form)
    end

    def set_selection_process
      @selection_process = SelectionProcess.find(params[:id])
    end

    def update_position(object, index)
      if object[:position] != index + 1
        object[:position] = index + 1
        object.save
      end
    end

    def selection_process_tree
      @selection_process.workflow_tree.each do |stage|
        stage.merge!(show: false, reference: WorkflowStage.find(stage['id']).reference)
        stage['workflow_states'] = stage['states'].each do |state|
          transitions = WorkflowState.find(state['id']).workflow_transitions
          state.merge!(actions: transitions.actions)
          state.merge!(progressions: transitions.progressions)
        end
        stage.delete(:states)
      end
    end

    def fields
      [:id, :name, :title, :reference]
    end

    def transition_fields
      fields + [:destination_type]
    end

  end
end