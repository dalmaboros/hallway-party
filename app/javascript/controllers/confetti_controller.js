import { Controller } from "@hotwired/stimulus"

const COLORS = ["bg-party-lavender", "bg-party-green", "bg-party-red", "bg-party-cyan", "bg-party-orchid"]
const PIECE_COUNT = 25

export default class extends Controller {
  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    for (let i = 0; i < PIECE_COUNT; i++) {
      this.element.appendChild(this.buildPiece())
    }
  }

  buildPiece() {
    const piece = document.createElement("span")
    const duration = 3 + Math.random() * 3
    const delay = Math.random() * 5

    piece.className = `confetti-piece ${COLORS[Math.floor(Math.random() * COLORS.length)]}`
    piece.style.left = `${Math.random() * 100}vw`
    piece.style.animationDuration = `${duration}s`
    piece.style.animationDelay = `-${delay}s`

    return piece
  }
}
