<template lang='pug'>
div(style="position: relative;min-width: 600px" v-if='form.activity_types.length')
  tag-form(ref='form' @submit='save' submit-button-text='Save' submit-button-icon='Save' submit-button-icon-accent='white' submit-button-accent='viridiangreen' submit-button-align='right')
    .row
      .col-sm-6
        tag-form-group()
          tag-edit-field(name='name' label='Name', :value='name' @valueChange='name = $event.detail.value')
            tag-validation(rule='required')
      .col-sm-6
        tag-form-group
          tag-edit-field(name='title' label='Title', :value='title' @valueChange='title = $event.detail.value')
            tag-validation(rule='required')
            tag-validation(rule='maxLength', args='1000')
    tag-form-group
      tag-edit-field(name='desc' label='Description'  editor='multilinetextbox', :value='description' @valueChange='description = $event.detail.value')
        tag-validation(rule='required')
        tag-validation(rule='maxLength', args='100')
    .row
      .col-sm-6
        tag-form-group
          tag-edit-field(name='activity_type' label='Activity type', editor='Dropdown', :value='activity_type' @valueChange='activity_type = $event.detail.value')
            tag-validation(rule='required')
            tag-edit-field-option(value='') Please select
            tag-edit-field-option(v-for='activity in form.activity_types' :value='activity[1]' :key='activity[1]') {{ activity[0] }}
      .col-sm-6
        tag-form-group
          tag-edit-field(name='activity_by' label='Activity by', editor='Dropdown', :value='activity_by' @valueChange='activity_by = $event.detail.value')
            tag-validation(rule='required')
            tag-edit-field-option(value='') Please select
            tag-edit-field-option(v-for='activity in form.activity_bys' :value='activity[1]' :key='activity[1]') {{ activity[0] }}
    tag-form-group(v-if='systemWaitState')
      tag-edit-field(name='delay_minutes' data-type='integer' label='Delay minutes', :value='delay_minutes' @valueChange='delay_minutes = $event.detail.value')
        tag-validation(rule='maxLength', args='100')
    tag-form-group(v-if='systemWaitState || appointmentWaitState || assessmentRequestWaitState || approvalWaitState || systemActionState')
      tag-edit-field(name='auto_transition' data-type='integer' label='Auto transition' editor='Dropdown' @valueChange='auto_transition_id = $event.detail.value')
        tag-edit-field-option(v-for='transition in transitions' :value='transition.id' :key='transition.id') {{ transition.title }}
    tag-form-group
      tag-checkbox(:disabled="activity_by == 'system'" name='reentry' text-align='right' label='Inhibit re-entry', :checked='inhibit_re_entry' :value='inhibit_re_entry' @valueChange='inhibit_re_entry = $event.detail.value')
    .row
      .col-sm-6
        tag-form-group
          tag-edit-field(name='before_enter' label='Before enter' editor='Dropdown', :value='before_enter' @valueChange='before_enter = $event.detail.value' )
            tag-edit-field-option(value='') Please select
            tag-edit-field-option(v-for='action in form.before_enter_actions' :value='action[1]' :key='action[1]') {{ action[0] }}
      .col-sm-6
        tag-form-group
          tag-edit-field(name='on_enter' label='On enter' editor='Dropdown', :value='on_enter' @valueChange='on_enter = $event.detail.value' )
            tag-edit-field-option(value='') Please select
            tag-edit-field-option(v-for='action in form.on_enter_actions' :value='action[1]' :key='action[1]') {{ action[0] }}
    .row
      .col-sm-6
        tag-form-group
          tag-edit-field(name='before_exit' label='Before exit' editor='Dropdown', :value='before_exit' @valueChange='before_exit = $event.detail.value' )
            tag-edit-field-option(value='') Please select
            tag-edit-field-option(v-for='action in form.before_exit_actions' :value='action[1]' :key='action[1]') {{ action[0] }}
      .col-sm-6
        tag-form-group
          tag-edit-field(name='on_exit' label='On exit' editor='Dropdown', :value='on_exit' @valueChange='on_exit = $event.detail.value' )
            tag-edit-field-option(value='') Please select
            tag-edit-field-option(v-for='action in form.on_exit_actions' :value='action[1]' :key='action[1]') {{ action[0] }}
    tag-form-group
      .mb5 Report key ids
      multiselect(v-model="report_key_ids" placeholder='Please select' hideSelected=true, :custom-label="opt => form.report_key_options.find(_ => _.id == opt).name" :options="form.report_key_options.map(_=>_.id)" :multiple='true' open-direction="bottom")
    .row
      .col-sm-6
        tag-form-group
          tag-edit-field(name='days_in_state' data-type='integer' label='Days in state until overdue', :value='days_in_state_until_overdue' @valueChange='days_in_state_until_overdue = $event.detail.value')
      .col-sm-6
        tag-form-group
          tag-edit-field(name='days_since_last' data-type='integer' label='Days since last activity until overdue', :value='days_since_last_activity_until_overdue' @valueChange='days_since_last_activity_until_overdue = $event.detail.value')
</template>

<script>
export default {
  data() {
    return this.$store.state.form.state
  }
}
</script>