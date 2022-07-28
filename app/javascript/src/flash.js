import * as bootstrap from "bootstrap"

var flash = function(message, options = {}) {

  toast_classes = "toast align-items-center text-white border-0 mb-2 bg-"+ options.color;

  var toast_body = document.createElement('div');
  toast_body.className = "toast-body";
  toast_body.textContent = message;

  var toast_button = document.createElement('button');
  toast_button.className = 'btn-close btn-close-white me-2 m-auto'
  toast_button.setAttribute('data-bs-dismiss', 'toast');

  var dflex = document.createElement('div');
  dflex.className = "d-flex";

  var toast = document.createElement('div');
  toast.className = toast_classes

  dflex.appendChild(toast_body);
  dflex.appendChild(toast_button);
  toast.appendChild(dflex)

  var container = document.getElementById('toast-container') || document.body
  container.appendChild(toast)

  toast = new bootstrap.Toast(toast, {})
  toast.show();
}

export { flash }
