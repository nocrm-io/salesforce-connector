import { Controller } from "@hotwired/stimulus"
import SlimSelect from 'slim-select'

export default class extends Controller {
  static values = { options: Object, optionsList: Array }

  connect() {
    this.select = new SlimSelect(Object.assign({select: this.element}, this.optionsValue || {}))
    if(this.optionsListValue.length) {
      this.select.setData(this.optionsListValue)
    }
  }

  disconnect() {
    this.select.destroy()
  }
}
