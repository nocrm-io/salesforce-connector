// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import { flash } from "./src/flash"
import "./src/fontawesome.js"

import * as bootstrap from "bootstrap"
window.bootstrap = bootstrap
window.flash = flash
