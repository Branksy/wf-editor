<template lang='pug'>
div(style="position:relative;width:600px" v-if='form.activity_types.length')
  tag-form(ref='form' @submit='save' submit-button-text='Save' submit-button-icon='Save' submit-button-icon-accent='white' submit-button-accent='viridiangreen' submit-button-align='right')
    .row
      .col-sm-6
        tag-form-group
          tag-edit-field(name='name' label='Name*' :value='name' @valueChange='name = $event.detail.value')
            tag-validation(rule='required')
          .hint Internal name
      .col-sm-6
        tag-form-group
          tag-edit-field(name='title' label='Title*' :value='title' @valueChange='title = $event.detail.value')
            tag-validation(rule='required')
          .hint Title as it appears in the workflow
    tag-form-group
      tag-edit-field(name='desc' label='Description'  editor='multilinetextbox' :value='description' @valueChange='description = $event.detail.value')
    .row
      .col-sm-6
        tag-form-group
          tag-edit-field(name='activity_type' label='Activity type*' editor='Dropdown' :value='activity_type' @valueChange='activity_type = $event.detail.value')
            tag-validation(rule='required')
            tag-edit-field-option(value='') --Select--
            tag-edit-field-option(v-for='activity in form.activity_types' :value='activity[1]' :key='activity[1]') {{ activity[0] }}
      .col-sm-6
        tag-form-group
          tag-edit-field(name='activity_by' label='Activity by*' editor='Dropdown' :value='activity_by' @valueChange='activity_by = $event.detail.value')
            tag-validation(rule='required')
            tag-edit-field-option(value='') --Select--
            tag-edit-field-option(v-for='activity in form.activity_bys' :value='activity[1]' :key='activity[1]') {{ activity[0] }}
    tag-form-group(v-if='systemWaitState')
      tag-edit-field(name='delay_minutes' label='Delay minutes' :value='delay_minutes' @valueChange='delay_minutes = $event.detail.value')
      .hint Time (in minutes) to wait before the next transition
    tag-form-group(v-if='systemWaitState || appointmentWaitState || assessmentRequestWaitState || approvalWaitState || systemActionState')
      tag-edit-field(name='auto_transition' label='Auto Transition' editor='Dropdown' :value='auto_transition_id' @valueChange='auto_transition_id = $event.detail.value')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='transition in transitions' :value='transition.id' :key='transition.id') {{ transition.title }}
      .hint The Workflow Transition to trigger after "Wait Delay", the Appointment due date/time has passed or the Assessment Request is complete.
    tag-form-group
      tag-checkbox(:disabled="activity_by == 'system'" name='reentry' text-align='right' label='Inhibit re-entry' :checked='inhibit_re_entry' :value='inhibit_re_entry' @valueChange='inhibit_re_entry = $event.detail.value')
      .hint Prevent re-assign or re-consider using this State as an entry point to the workflow

    tag-form-group
      tag-edit-field(name='before_enter' label='Before enter' editor='Dropdown' :value='before_enter' @valueChange='before_enter = $event.detail.value' )
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='action in form.before_enter_actions' :value='action[1]' :key='action[1]') {{ action[0] }}
      .hint Executed before the start of any Workflow Action method that enters this State

    tag-form-group
      tag-edit-field(name='on_enter' label='On enter' editor='Dropdown' :value='on_enter' @valueChange='on_enter = $event.detail.value' )
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='action in form.on_enter_actions' :value='action[1]' :key='action[1]') {{ action[0] }}
      .hint Executed when a Workflow Action method enters this State, after the Workflow Action itself

    tag-form-group
      tag-edit-field(name='before_exit' label='Before exit' editor='Dropdown' :value='before_exit' @valueChange='before_exit = $event.detail.value' )
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='action in form.before_exit_actions' :value='action[1]' :key='action[1]') {{ action[0] }}
      .hint Executed before the start of any Workflow Action method that exits this State

    tag-form-group
      tag-edit-field(name='on_exit' label='On exit' editor='Dropdown' :value='on_exit' @valueChange='on_exit = $event.detail.value' )
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='action in form.on_exit_actions' :value='action[1]' :key='action[1]') {{ action[0] }}
      .hint Executed when a Workflow Action method exits this State, immediately before the Workflow Action itself
    tag-form-group
      .mb5 Report key ids
      multiselect(v-model="report_key_ids" placeholder='Select...' :custom-label="opt => form.report_key_options.find(_ => _.id == opt).name" :options="form.report_key_options.map(_=>_.id)" :multiple='true' open-direction="bottom" hideSelected=true)
    .row
      .col-sm-6
        tag-form-group
          tag-edit-field(name='days_in_state' label='Days in state until overdue' :value='days_in_state_until_overdue' @valueChange='days_in_state_until_overdue = $event.detail.value')
      .col-sm-6
        tag-form-group
          tag-edit-field(name='days_since_last' label='Days since last activity until overdue' :value='days_since_last_activity_until_overdue' @valueChange='days_since_last_activity_until_overdue = $event.detail.value')
</template>


<script>
import { mapState } from 'vuex'
import formMixin from '../../helpers/mixins/form_mixin'
export default {
  mixins: [formMixin],
  data() {
    return {
      id: '',
      name: '',
      title: '',
      description: '',
      on_enter: '',
      on_exit: '',
      before_enter: '',
      before_exit: '',
      days_in_state_until_overdue: null,
      days_since_last_activity_until_overdue: null,
      activity_by: '',
      activity_type: '',
      delay_minutes: '',
      auto_transition_id: '',
      inhibit_re_entry: false,
      report_key_ids: [],
      form: {
        activity_types: [],
        activity_bys: [],
        before_enter_actions: [],
        on_enter_actions: [],
        before_exit_actions: [],
        on_exit_actions: [],
        report_key_options: []
      }
    }
  },
  computed: {
    ...mapState(['status', 'actions', 'progressions']),
    transitions() {
      return [...this.actions, ...this.progressions].sort( (a, b) =>  {
        var textA = a.title.toUpperCase();
        var textB = b.title.toUpperCase();
        return (textA < textB) ? -1 : (textA > textB) ? 1 : 0;
      })
    },
    systemWaitState() {
      return  this.activity_type == 'wait' && this.activity_by == 'system'
    },
    appointmentWaitState() {
      return this.activity_type == 'appointment' && this.activity_by == 'system'
    },
    approvalWaitState() {
      return this.activity_type == 'approval' && this.activity_by == 'system'
    },
    assessmentRequestWaitState() {
      return this.activity_type == 'assessment_request'
    },
    systemActionState() {
      return this.activity_type == 'action' && this.activity_by == 'system'
    }
  },
  methods: {
    save() {
      this.$store.dispatch('create_state', this.$data)
      this.reenableForm()
    }
  },
  watch: {
    status() {
      if(this.status == 200) {
        this.clearForm();
        this.$parent.$refs.newable.hide();
      }
    },
    days_in_state_until_overdue(newVal, oldVal) {
      if(newVal == 0) this.days_in_state_until_overdue = null
    },
    days_since_last_activity_until_overdue(newVal, oldVal) {
      if(newVal == 0) this.days_since_last_activity_until_overdue = null
    }
  },
  created() {
    this.axios.get('/workflow_states/new')
    .then(response => {
      if(response.status = 200) {
        this.form = response.data.form
      }
    })
  }
}
</script>
