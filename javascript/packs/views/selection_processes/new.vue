<template lang='pug'>
div(style="position:relative;width: 600px")
  tag-form(ref='form' @submit='save' submit-button-text='Save' submit-button-icon='Save' submit-button-icon-accent='white' submit-button-accent='viridiangreen' submit-button-align='right')
    tag-form-group
      tag-edit-field(class='edit-field' name='name' label='Name*' :value='name' @valueChange='name = $event.detail.value')
        tag-validation(rule='required')
    tag-form-group
      tag-edit-field(name='title' label='Title*' editor='multilinetextbox' :value='title' @valueChange='title = $event.detail.value')
        tag-validation(rule='required')
    tag-form-group
      tag-edit-field(name='abbr' label='Abbreviation*' :value='abbreviation' @valueChange='abbreviation = $event.detail.value')
        tag-validation(rule='required')
    tag-form-group
      tag-edit-field(name='desc' label='Description' :value='description' @valueChange='description = $event.detail.value')
    tag-form-group
      tag-edit-field(name='status' label='Status*' editor='dropdown' :value='status' @valueChange='status = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='active') Active
        tag-edit-field-option(value='inactive') Inactive
    tag-form-group
      tag-edit-field(name='talent' label='Talent Stage*', editor='dropdown', :value='talent_workflow_stage_id' @valueChange='talent_workflow_stage_id = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='talent_stage in form.available_talent_stages' :value='talent_stage[1]' :key='talent_stage[1]') {{ talent_stage[0] }}
    tag-form-group
      tag-edit-field(name='complete' label='Complete Stage*', editor='dropdown', :value='complete_workflow_stage_id' @valueChange='complete_workflow_stage_id = $event.detail.value')
        tag-validation(rule='required')
        tag-edit-field-option(value='') --Select--
        tag-edit-field-option(v-for='complete_stage in form.available_complete_stages' :value='complete_stage[1]' :key='complete_stage[1]') {{ complete_stage[0] }}
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
      abbreviation: '',
      description: '',
      status: '',
      talent_workflow_stage_id: '',
      complete_workflow_stage_id: '',
      form: {
        available_talent_stages: [],
        available_complete_stages: []
      }
    }
  },
  computed: {
    ...mapState({
      responseStatus: 'status'
    })
  },
  methods: {
    save() {
      this.$store.dispatch('create', this.$data)
      this.reenableForm()
    }
  },
  watch: {
    responseStatus() {
      if(this.responseStatus <= 202) {
        this.clearForm()
        this.$parent.$refs.new_workflow.hide();
      }
    }
  },
  created() {
    this.axios.get('selection_processes/new')
    .then(response => {
      if(response.status == 200) {
        this.form = response.data.form
      }
    })
  }
}
</script>