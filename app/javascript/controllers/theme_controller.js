import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { default: { type: String, default: "dark" } }

  connect() {
    const saved = localStorage.getItem("dispatch-theme") || this.defaultValue
    this.applyTheme(saved)
    this.updateToggle(saved)
  }

  toggle(event) {
    const current = document.documentElement.dataset.bsTheme || "dark"
    const next = current === "dark" ? "light" : "dark"
    this.applyTheme(next)
    localStorage.setItem("dispatch-theme", next)
  }

  applyTheme(theme) {
    document.documentElement.dataset.bsTheme = theme
  }

  updateToggle(theme) {
    const toggle = document.querySelector("[data-theme-toggle]")
    if (toggle) toggle.checked = theme === "light"
  }
}
