import Axios from 'axios'

const API_URL = window.location.href.split('/configuration/workflow_designer')[0] + '/apis/workflow_designer/v1'

const axios = Axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
})

export default axios;