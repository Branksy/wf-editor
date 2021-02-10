<template lang='pug'>
div(style="position:relative;width:600px" v-if='form.available_destination_states.length')
  tag-form(ref='form' @submit='save' submit-button-text='Save' submit-button-icon='Save' submit-button-icon-accent='white' submit-button-accent='viridiangreen' submit-button-align='right')
    tag-form-group
      tag-edit-field(name='name' label='Name*' :value='tr.name' @valueChange='tr.name = $event.detail.value')
        tag-validation(rule='required')
      .hint Internal name
    tag-form-group
      tag-edit-field(name='title' label='Title*' :value='tr.title' @valueChange='tr.title = $event.detail.value')
        tag-validation(rule='required')
      .hint Title as it appears in the workflow.
    tag-form-group
      tag-edit-field(name='desc' label='Description' editor='multilinetextbox' :value='tr.description' @valueChange='tr.description = $event.detail.value')
    tag-form-group
      tag-edit-field(name='action' label='Action' editor='Dropdown' :value='tr.action' @valueChange='tr.action = $event.detail.value; tr.action_parameters = {}')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='action in form.available_actions' :value='action[1]' :key='action[1]') {{ action[0] }}

    div(v-for='field in form.action_fields_with_options' :key="field.name")
      tag-form-group(v-if="checkConditional(field)")
        template(v-if='field.multiple')
          .mb5 {{ field.label }}
          multiselect(:max-height='200' v-model='tr.action_parameters[field.name]' placeholder='Select...' hideSelected=true :custom-label="opt => field.options.find(_ => _[1] == opt)[0]" :options="(field.options || []).map(_ => _[1])" :multiple='true' open-direction="bottom")
        tag-edit-field(v-else :name="field.name" :label="field.label" :editor="field.format" :value='tr.action_parameters[field.name]' @valueChange="setActionParameter(field, $event)")
          tag-validation(rule='required' v-if="field.required")
          tag-edit-field-option(v-for="option in field.options" :value='option[1]' :key='option[1]') {{ option[0] }}
        .hint(v-if="field.required") *Required
        .hint(v-html="field.hint")

    tag-form-group(v-if='dcsp && form.communication_template_choices_primary.length')
      tag-edit-field(:name='dcsp.label' :label='dcsp.label' editor='Dropdown' :value='tr.primary_communication_template' @valueChange='tr.primary_communication_template = $event.detail.value')
        tag-validation(rule='required' v-if='dcsp.required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='choice in form.communication_template_choices_primary' :value='choice[1]' :key='choice[1]') {{ choice[0] }}
      .hint(v-if='dcsp.required') *Required
      .hint(v-html='dcsp.hint')

    tag-form-group(v-if='dcss')
      tag-edit-field(:name='dcss.label' :label='dcss.label' editor='Dropdown' :value='tr.secondary_communication_template' @valueChange='tr.secondary_communication_template = $event.detail.value')
        tag-validation(rule='required' v-if='dcss.required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='choice in form.communication_template_choices_secondary' :value='choice[1]' :key='choice[1]') {{ choice[0] }}
      .hint(v-if='dcss.required') *Required
      .hint(v-html='dcss.hint')

    tag-form-group(v-if='dcst')
      tag-edit-field(:name='dcst.label' :label='dcst.label' editor='Dropdown' :value='tr.tertiary_communication_template' @valueChange='tr.tertiary_communication_template = $event.detail.value')
        tag-validation(rule='required' v-if='dcst.required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='choice in form.communication_template_choices_tertiary' :value='choice[1]' :key='choice[1]') {{ choice[0] }}
      .hint(v-if='dcst.required') *Required
      .hint(v-html='dcst.hint')

    tag-form-group(v-if='form.available_destination_types')
      tag-edit-field(:disabled='form.available_destination_types.length < 2' name='destination' label='Destination*' editor='Dropdown' :value='tr.destination_type' @valueChange='tr.destination_type = $event.detail.value;refreshForm()')
        tag-validation(rule='required')
        tag-edit-field-option(value='' v-if='form.available_destination_types.length > 1') --Select--
        tag-edit-field-option(v-for='destination in form.available_destination_types' :value='destination[1]' :key='destination[1]') {{ destination[0] }}
      .hint(v-html='form.destination_hint')
    tag-form-group(v-if='form.destination_workflow_stage_id_required')
      tag-edit-field(name='destination_stage' label='Destination Stage*' editor='Dropdown' :value='tr.destination_workflow_stage_id' @valueChange='tr.destination_workflow_stage_id = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='destination in form.available_destination_stages' :value='destination[1]' :key='destination[1]') {{ destination[0] }}
    tag-form-group(v-if='form.destination_workflow_state_id_required')
      tag-edit-field(name='destination_state' label='Destination State*' editor='Dropdown' :value='tr.destination_workflow_state_id' @valueChange='tr.destination_workflow_state_id = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='destination in form.available_destination_states' :value='destination[1]' :key='destination[1]') {{ destination[0] }}

    tag-form-group(v-if='form.alternate_destination_type_required')
      tag-edit-field(:disabled='form.available_alternate_destination_types.length < 2' name='alt_destination' label='Secondary Destination*' editor='Dropdown' :value='tr.alternate_destination_type' @valueChange='tr.alternate_destination_type = $event.detail.value;refreshForm()')
        tag-validation(rule='required')
        tag-edit-field-option(value='' v-if='form.available_alternate_destination_types.length > 1') --Select--
        tag-edit-field-option(v-for='destination in form.available_alternate_destination_types' :value='destination[1]' :key='destination[1]') {{ destination[0] }}
      .hint(v-html='form.alternate_destination_hint')
    tag-form-group(v-if='form.alternate_destination_workflow_stage_id_required')
      tag-edit-field(name='alt_destination_stage' label='Secondary Destination Stage' editor='Dropdown' :value='tr.alternate_destination_workflow_stage_id' @valueChange='tr.alternate_destination_workflow_stage_id = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='destination in form.available_destination_stages' :value='destination[1]' :key='destination[1]') {{ destination[0] }}
    tag-form-group(v-if='form.alternate_destination_workflow_state_id_required')
      tag-edit-field(name='alt_destination_state' label='Secondary Destination State' editor='Dropdown' :value='tr.alternate_destination_workflow_state_id' @valueChange='tr.alternate_destination_workflow_state_id = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='destination in form.available_destination_states' :value='destination[1]' :key='destination[1]') {{ destination[0] }}

    tag-form-group
      tag-checkbox(:disabled="!form.available_as_scheduled_action" name='scheduled_action' text-align='right' label='Scheduled action' :checked='tr.scheduled_action' :value='tr.scheduled_action' @valueChange='tr.scheduled_action = $event.detail.value;refreshForm()')
    tag-form-group(v-if='tr.scheduled_action')
      tag-edit-field(name='scheduled_trigger' label='Trigger*' editor='Dropdown' :value='tr.scheduled_trigger' @valueChange='tr.scheduled_trigger = $event.detail.value;refreshForm()')
        tag-validation(rule='required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='option in form.scheduled_trigger_options' :value='option[1]' :key='option[1]') {{ option[0] }}

    tag-form-group(v-if='form.scheduled_delay_minutes_required')
      tag-validation(rule='required')
      tag-edit-field(name='scheduled_delay_minutes' label='Delay(minutes)*' :value='tr.scheduled_delay_minutes' @valueChange='tr.scheduled_delay_minutes = $event.detail.value')
      .hint Enter the delay in minutes (checked on workflow change then HOURLY). NOTE: Entering "Time in State" with 0 minutes results in "execute on enter and then retry every hour"

    tag-form-group
      tag-checkbox(name='bulk_action' :disabled='!form.available_as_bulk_action' text-align='right' label='Bulk action' :checked='tr.bulk_action' :value='tr.bulk_action' @valueChange='tr.bulk_action = $event.detail.value')
    tag-form-group
      tag-checkbox(name='system_action' :disabled='form.lock_system_action' text-align='right' label='System action' :checked='tr.system_action' :value='tr.system_action' @valueChange='tr.system_action = $event.detail.value')
    br
    tag-form-group(v-if='form.access_roles')
      .mb5 Restrict access to selected roles
      multiselect(v-model="tr.access_role_ids" :max-height='400' placeholder='Select...' hideSelected=true :custom-label="opt => form.access_roles.find(_ => _.id == opt).title" :options="form.access_roles.map(_=>_.id)" :multiple='true' open-direction="bottom")
      .hint *If no roles are selected access is available to all.
    div(style='height:400px')
</template>


<script>
import { mapState } from 'vuex'
import formMixin from '../../helpers/mixins/form_mixin'
export default {
  mixins: [formMixin],
  props: ['prog_or_act'],
  data() {
    return {
      tr: {
        id: '',
        name: '',
        title: '',
        description: '',
        action: '',
        action_parameters: {},
        destination_type: '',
        destination_workflow_stage_id: '',
        destination_workflow_state_id: '',
        scheduled_action: false,
        scheduled_trigger: false,
        scheduled_delay_minutes: '',
        bulk_action: false,
        system_action: false,
        access_role_ids: [],
        primary_communication_template: '',
        secondary_communication_template: '',
        tertiary_communication_template: ''
      },
      form: {
        available_actions: [],
        action_definition_help: '',

        display_comms_selector_primary: {},
        display_comms_selector_secondary: {},
        display_comms_selector_tertiary: {},

        communication_template_choices_primary: [],
        communication_template_choices_secondary: [],
        communication_template_choices_tertiary: [],

        available_destination_types: [],
        available_destination_states: [],
        available_destination_stages: [],
        available_alternate_destination_types: [],

        destination_workflow_stage_id_required: false,
        destination_workflow_state_id_required: false,
        destination_hint: '',

        alternate_destination_type_required: false,
        alternate_destination_workflow_stage_id_required: false,
        alternate_destination_workflow_state_id_required: false,
        alternate_destination_hint: '',

        available_as_scheduled_action: '',
        scheduled_delay_minutes_required: '',
        scheduled_trigger_options: [],
        available_as_bulk_action: '',
        access_roles: [],
        action_fields_with_options: []
      }
    }
  },
  computed: {
    ...mapState(['status']),
    action() {
      return this.tr.action
    },
    available_destination_types() {
      return this.form.available_destination_types
    },
    available_destination_states() {
      return this.form.available_destination_states
    },
    available_destination_stages() {
      return this.form.available_destination_stages
    },
    dcsp() {
      return this.form.display_comms_selector_primary
    },
    dcss() {
      return this.form.display_comms_selector_secondary
    },
    dcst() {
      return this.form.display_comms_selector_tertiary
    }
  },
  methods: {
    save() {
      this.$store.dispatch('create_transition', this.$data.tr)
      this.reenableForm()
    },
    refreshForm() {
      this.axios.post('/workflow_transitions/refresh', { workflow_transition: this.tr })
      .then(response => {
        if(response.status = 200) {
          this.tr = response.data.transition
          this.tr.primary_communication_template = response.data.transition.primary_communication_template_id
          this.tr.secondary_communication_template = response.data.transition.secondary_communication_template_id
          this.tr.tertiary_communication_template = response.data.transition.tertiary_communication_template_id
          this.form = response.data.form
          this.tr.selection_process_id = this.$route.params.id
        }
      })
    },
    checkConditional(field) {
      if(field['if']) {
        var key = Object.keys(field.if[0])[0]
        var value = Object.values(field.if[0])[0]
        if(this.tr.action_parameters.hasOwnProperty(key) && this.tr.action_parameters[key] == value) {
          return true;
        } else return false;
      } else return true
    },
    setActionParameter(field, event) {
      this.$set(this.tr.action_parameters, field.name, event.detail.value);
      this.refreshForm();
    }
  },
  watch: {
    status() {
      if(this.status == 200) {
        this.clearForm();
        this.$parent.$refs.newable.hide();
      }
    },
    action(newVal, oldVal) {
      if(newVal != "") this.refreshForm()
    },
    destination_type() {
      this.refreshForm()
    },
    available_destination_types(newVal, oldVal) {
      if(newVal.length) {
        if(newVal.length == 1) this.tr.destination_type = newVal[0][1]
      }
    }
  },
  created() {
    this.axios.get('/workflow_transitions/new')
    .then(response => {
      if(response.status = 200) {
        this.form = response.data.form
      }
    })
  }
}
</script>
