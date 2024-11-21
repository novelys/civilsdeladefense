import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import { patch } from '@rails/request.js'

export default class extends Controller {
  static values = { url: String }

  connect() {
    new Sortable(this.element, {
      animation: 150,
      handle: ".grabbable",
      filter: ".no-drag",
      ghostClass: "grabbed",
      direction: "vertical",
      onMove: (event) => {
        return event.related.classList.contains('grabbable');
      },
      onEnd: this.persistNewPosition
    })
  }

  // Private

  persistNewPosition = (event) => {
    const newIndex = event.newIndex

    const url = "/admin/parametres/positions"
    const data = new FormData
    data.append("position", newIndex + 1)
    data.append("resource_class", event.item.getAttribute("data-resource-class"))
    data.append("resource_id", event.item.getAttribute("data-id"))

    const next = event.to.children[newIndex + 1]
    if (next !== undefined) {
      data.append("sibling_resource_id", next.getAttribute("data-id"))
    }

    const response = patch(url, { body: data })
    if (response.ok) {
      window.location.reload(true)
    }
  }
}
