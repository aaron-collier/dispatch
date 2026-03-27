import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer"]

  open() {
    const offcanvas = bootstrap.Offcanvas.getOrCreateInstance(this.drawerTarget)
    offcanvas.show()
  }

  close() {
    const offcanvas = bootstrap.Offcanvas.getInstance(this.drawerTarget)
    offcanvas?.hide()
  }
}
