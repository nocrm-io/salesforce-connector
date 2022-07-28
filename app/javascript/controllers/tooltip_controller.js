import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static values = { options: Object }

  initialize() {
    this.tooltip = new bootstrap.Tooltip(this.element, this.optionsValue)
  }
}
