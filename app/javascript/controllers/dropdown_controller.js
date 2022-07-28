import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['menu']

  connect() {
    this.toggleClass = this.data.get('class') || 'd-none'
  }

  toggle() {
    var hide = () => {this.menuTarget.classList.add('d-none')}

    if (this.menuTarget.classList.contains('d-none')) {
      this.menuTarget.classList.remove('fadeOut')
      this.menuTarget.classList.add('fadeIn')
      this.menuTarget.classList.remove('d-none')
    } else {
      this.menuTarget.classList.remove('fadeIn')
      this.menuTarget.classList.add('fadeOut')
      setTimeout(hide, 150)
    }
  }

  hide(event) {
    var hide = () => {this.menuTarget.classList.add('d-none')}

    if (
      this.element.contains(event.target) === false &&
      !this.menuTarget.classList.contains(this.toggleClass)
    ) {
      this.menuTarget.classList.remove('fadeIn')
      this.menuTarget.classList.add('fadeOut')
      setTimeout(hide, 150)
    }
  }
}