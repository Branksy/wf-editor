<template lang='pug'>
div(style="position:relative;width:600px" v-if='form.activity_types')
  tag-form(ref='form' @submit='save' submit-button-text='Save' submit-button-icon='Save' submit-button-icon-accent='white' submit-button-accent='viridiangreen' submit-button-align='right')
    tag-form-group
      tag-edit-field(name='name' label='Name*' :value='name' @valueChange='name = $event.detail.value')
        tag-validation(rule='required')
      .hint Internal name
    tag-form-group
      tag-edit-field(name='title' label='Title*' :value='title' @valueChange='title = $event.detail.value')
        tag-validation(rule='required')
        tag-validation(rule='maxLength', args='1000')
      .hint Title as it appears in the workflow
    tag-form-group
      tag-edit-field(name='desc' label='Description' :value='description' @valueChange='description = $event.detail.value')
        tag-validation(rule='maxLength' args='100')
    tag-form-group
      tag-edit-field(name='activity' label='Activity type*' editor='Dropdown' :value='activity_type' @valueChange='activity_type = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='activity in form.activity_types' :value='activity[1]' :key='activity[1]') {{ activity[0] }}
    tag-form-group(v-if="['appointment', 'appointment_assessment'].include(activity_type)")
      tag-edit-field(name='appoint' label='Appointment template*' editor='Dropdown', :value='appointment_template_id' @valueChange='appointment_template_id = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='') -- None --
        tag-edit-field-option(v-for='template in form.appointment_templates' :value='template[1]' :key='template[1]') {{ template[0] }}
    tag-form-group(v-if="['online_assessment', 'appointment_assessment'].include(activity_type)")
      tag-edit-field(name='assessment' label='Assessment template*' editor='Dropdown' :value='assessment_template_id' @valueChange='assessment_template_id = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='') -- None --
        tag-edit-field-option(v-for='template in form.assessment_templates' :value='template[1]' :key='template[1]') {{ template[0] }}
    div(v-if="['offer'].include(activity_type)")
      .mb5 Offer template ids*
      multiselect(v-model="offer_template_ids" :custom-label="opt => form.offer_templates.find(_ => _.id == opt).name" :options="form.offer_templates.map(_=>_.id)" :multiple='true' open-direction="bottom" hideSelected=true)
    tag-form-group
      tag-checkbox(name='reentry' text-align='right' label='Inhibit re-entry', :checked='inhibit_re_entry' :value='inhibit_re_entry' @valueChange='inhibit_re_entry = $event.detail.value')
      .hint Prevent re-assign or re-consider using this Stage as an entry point to the workflow
    tag-form-group
      .mb5 Report key ids
      multiselect(v-model="report_key_ids" :custom-label="opt => form.report_key_options.find(_ => _.id == opt).name" :options="form.report_key_options.map(_=>_.id)" :multiple='true' open-direction="bottom" hideSelected=true)
    tag-form-group
      tag-edit-field(name='days_in_stage' data-type='integer' label='Days in stage until overdue' :value='days_in_stage_until_overdue' @valueChange='days_in_stage_until_overdue = $event.detail.value')
        tag-validation(rule='maxLength', args='100')
    tag-form-group
      tag-checkbox(name='anonymise' text-align='right' label='Anonymise?' :checked='anonymise' :value='anonymise' @valueChange='anonymise = $event.detail.value')
      .hint Enable to anonymise applications while they are in this workflow stage
    br
</template>


<script>
import { mapState } from 'vuex'
import formMixin from '../../helpers/mixins/form_mixin'
export default {
  mixins: [formMixin],
  data() {
    return {
      name: '',
      title: '',
      description: '',
      activity_type: '',
      appointment_template_id: '',
      assessment_template_id: '',
      offer_template_ids: [],
      report_keys: [],
      report_key_ids: [],
      inhibit_re_entry: false,
      days_in_stage_until_overdue: '',
      anonymise: false,
      form: {
        activity_types: [],
        appointment_templates: [],
        assessment_templates: [],
        offer_templates: [],
        report_key_options: []
      }
    }
  },
  computed: {
    ...mapState(['status'])
  },
  methods: {
    save() {
      this.$store.dispatch('create_stage', this.$data)
      this.reenableForm()
    }
  },
  watch: {
    status() {
      if(this.status == 200) {
        this.clearForm();
        this.$parent.$refs.newable.hide();
      }
    }
  },
  created() {
    this.axios.get('/workflow_stages/new')
    .then(response => {
      if(response.status = 200) {
        this.form = response.data.form
      }
    })
  }
}
</script>